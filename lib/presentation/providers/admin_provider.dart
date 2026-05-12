import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenken_engiflow/firebase_options.dart';
import 'package:tenken_engiflow/data/models/user_model.dart';
import 'package:tenken_engiflow/data/models/system_config_model.dart';
import 'package:tenken_engiflow/data/models/task_model.dart';
import 'package:tenken_engiflow/data/models/issue_model.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // User Management
  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  
  // System Configuration
  SystemConfig? _systemConfig;
  List<Department> _departments = [];
  List<Permission> _permissions = [];
  
  // Tasks & Issues (admin-wide view)
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  List<IssueModel> _allIssues = [];
  List<IssueModel> _filteredIssues = [];

  // Analytics (computed from loaded data)
  Map<String, int> _taskStats = {};
  Map<String, int> _issueStats = {};
  List<Map<String, dynamic>> _recentActivity = [];

  // State Management
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  
  // Getters
  List<UserModel> get allUsers => _allUsers;
  List<UserModel> get filteredUsers => _filteredUsers;
  SystemConfig? get systemConfig => _systemConfig;
  List<Department> get departments => _departments;
  List<Permission> get permissions => _permissions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  List<Task> get allTasks => _allTasks;
  List<Task> get filteredTasks => _filteredTasks;
  List<IssueModel> get allIssues => _allIssues;
  List<IssueModel> get filteredIssues => _filteredIssues;
  Map<String, int> get taskStats => _taskStats;
  Map<String, int> get issueStats => _issueStats;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;
  
  // Statistics Getters
  int get totalUsers => _allUsers.length;
  int get totalEngineers => _allUsers.where((u) => u.isEngineer).length;
  int get totalSupervisors => _allUsers.where((u) => u.isSupervisor).length;
  int get totalAdmins => _allUsers.where((u) => u.isAdmin).length;
  int get activeUsers => _allUsers.where((u) => u.isActive).length;
  
  /// Load all users from Firestore
  Future<void> loadAllUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .get();
      
      _allUsers = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
      _filteredUsers = List.from(_allUsers);
      _successMessage = 'Users loaded successfully';
      
    } catch (e) {
      _error = 'Failed to load users: $e';
      print('❌ Error loading users: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Search and filter users
  void searchUsers(String query) {
    if (query.isEmpty) {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((user) {
        return user.displayName.toLowerCase().contains(query.toLowerCase()) ||
               user.email.toLowerCase().contains(query.toLowerCase()) ||
               user.department.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
  
  /// Filter users by role
  void filterUsersByRole(String role) {
    if (role.isEmpty || role == 'all') {
      _filteredUsers = List.from(_allUsers);
    } else {
      _filteredUsers = _allUsers.where((user) => user.role == role).toList();
    }
    notifyListeners();
  }
  
  /// Create new user (Admin only).
  ///
  /// Uses a secondary FirebaseApp instance so the admin's own session is never
  /// interrupted by the createUserWithEmailAndPassword call.
  Future<bool> createNewUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String department,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Unique name avoids collision if called twice in quick succession.
    final appName = 'adminCreate_${DateTime.now().millisecondsSinceEpoch}';
    FirebaseApp? secondaryApp;

    try {
      secondaryApp = await Firebase.initializeApp(
        name: appName,
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final newUser = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        department: department,
        createdAt: DateTime.now(),
        isActive: true,
        managedDepartments: role == 'supervisor' ? [department] : null,
        teamMemberIds: role == 'supervisor' ? [] : null,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toMap());

      _allUsers.add(newUser);
      _filteredUsers = List.from(_allUsers);
      _successMessage = 'User created successfully: $displayName';
      return true;

    } on FirebaseAuthException catch (e) {
      _error = _authErrorMessage(e.code);
      return false;
    } catch (e) {
      _error = 'Failed to create user: $e';
      return false;
    } finally {
      // Always clean up — leaving orphaned apps leaks memory.
      await secondaryApp?.delete();
      _isLoading = false;
      notifyListeners();
    }
  }

  String _authErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      default:
        return 'Auth error: $code';
    }
  }
  
  /// Update user details
  Future<bool> updateUser({
    required String userId,
    String? displayName,
    String? role,
    String? department,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      Map<String, dynamic> updateData = {};
      if (displayName != null) updateData['displayName'] = displayName;
      if (role != null) updateData['role'] = role;
      if (department != null) updateData['department'] = department;
      
      await _firestore
          .collection('users')
          .doc(userId)
          .update(updateData);
      
      // Update local list
      final userIndex = _allUsers.indexWhere((u) => u.uid == userId);
      if (userIndex != -1) {
        final user = _allUsers[userIndex];
        _allUsers[userIndex] = UserModel(
          uid: user.uid,
          email: user.email,
          displayName: displayName ?? user.displayName,
          role: role ?? user.role,
          department: department ?? user.department,
          createdAt: user.createdAt,
          managedDepartments: user.managedDepartments,
          teamMemberIds: user.teamMemberIds,
          supervisorId: user.supervisorId,
        );
        _filteredUsers = List.from(_allUsers);
      }
      
      _successMessage = 'User updated successfully';
      return true;
      
    } catch (e) {
      _error = 'Failed to update user: $e';
      print('❌ Error updating user: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Deactivate a user account (Admin only).
  ///
  /// Sets isActive=false in Firestore — the AuthProvider will force-sign-out
  /// any session that belongs to this user on their next app load.
  /// Full Firebase Auth deletion requires the Admin SDK (a Cloud Function);
  /// this soft-delete is sufficient to block all app access immediately.
  Future<bool> deleteUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _firestore.collection('users').doc(userId).update({
        'isActive': false,
        'deactivatedAt': DateTime.now().toIso8601String(),
      });

      _allUsers.removeWhere((u) => u.uid == userId);
      _filteredUsers = List.from(_allUsers);
      _successMessage = 'User deactivated successfully';
      return true;

    } catch (e) {
      _error = 'Failed to deactivate user: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load system configuration
  Future<void> loadSystemConfig() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final DocumentSnapshot snapshot = await _firestore
          .collection('system_config')
          .doc('default')
          .get();
      
      if (snapshot.exists) {
        _systemConfig = SystemConfig.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        _systemConfig = SystemConfig.defaultConfig();
        // Save default config
        await _firestore
            .collection('system_config')
            .doc('default')
            .set(_systemConfig!.toMap());
      }
      
    } catch (e) {
      _error = 'Failed to load system config: $e';
      _systemConfig = SystemConfig.defaultConfig();
      print('❌ Error loading system config: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update system configuration
  Future<bool> updateSystemConfig(SystemConfig config) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final adminId = _auth.currentUser?.uid ?? 'system';
      final updatedConfig = SystemConfig(
        id: config.id,
        departments: config.departments,
        roles: config.roles,
        permissions: config.permissions,
        companyName: config.companyName,
        companyLogo: config.companyLogo,
        maintenanceMode: config.maintenanceMode,
        lastUpdatedAt: DateTime.now(),
        lastUpdatedBy: adminId,
        emailSettings: config.emailSettings,
        notificationSettings: config.notificationSettings,
      );
      
      await _firestore
          .collection('system_config')
          .doc('default')
          .set(updatedConfig.toMap());
      
      _systemConfig = updatedConfig;
      _successMessage = 'System configuration updated successfully';
      return true;
      
    } catch (e) {
      _error = 'Failed to update system config: $e';
      print('❌ Error updating system config: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load all departments
  Future<void> loadDepartments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final QuerySnapshot snapshot = await _firestore
          .collection('departments')
          .get();
      
      _departments = snapshot.docs
          .map((doc) => Department.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
    } catch (e) {
      _error = 'Failed to load departments: $e';
      print('❌ Error loading departments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Add new department
  Future<bool> addDepartment({
    required String name,
    required String description,
    required List<String> supervisorIds,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final newDept = Department(
        id: _firestore.collection('departments').doc().id,
        name: name,
        description: description,
        supervisorIds: supervisorIds,
        teamSize: 0,
        createdAt: DateTime.now(),
        isActive: true,
      );
      
      await _firestore
          .collection('departments')
          .doc(newDept.id)
          .set(newDept.toMap());
      
      _departments.add(newDept);
      _successMessage = 'Department added successfully';
      return true;
      
    } catch (e) {
      _error = 'Failed to add department: $e';
      print('❌ Error adding department: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update department
  Future<bool> updateDepartment({
    required String departmentId,
    required String name,
    required String description,
    required List<String> supervisorIds,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firestore
          .collection('departments')
          .doc(departmentId)
          .update({
            'name': name,
            'description': description,
            'supervisorIds': supervisorIds,
          });
      
      final deptIndex = _departments.indexWhere((d) => d.id == departmentId);
      if (deptIndex != -1) {
        final dept = _departments[deptIndex];
        _departments[deptIndex] = Department(
          id: dept.id,
          name: name,
          description: description,
          supervisorIds: supervisorIds,
          teamSize: dept.teamSize,
          createdAt: dept.createdAt,
          isActive: dept.isActive,
        );
      }
      
      _successMessage = 'Department updated successfully';
      return true;
      
    } catch (e) {
      _error = 'Failed to update department: $e';
      print('❌ Error updating department: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Load permissions
  Future<void> loadPermissions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final QuerySnapshot snapshot = await _firestore
          .collection('permissions')
          .get();
      
      _permissions = snapshot.docs
          .map((doc) => Permission.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      
    } catch (e) {
      _error = 'Failed to load permissions: $e';
      print('❌ Error loading permissions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Update permission
  Future<bool> updatePermission({
    required String permissionId,
    required List<String> actions,
    required bool canApprove,
    required bool canManage,
    required bool canView,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firestore
          .collection('permissions')
          .doc(permissionId)
          .update({
            'actions': actions,
            'canApprove': canApprove,
            'canManage': canManage,
            'canView': canView,
            'lastModified': DateTime.now().toIso8601String(),
          });
      
      _successMessage = 'Permission updated successfully';
      return true;
      
    } catch (e) {
      _error = 'Failed to update permission: $e';
      print('❌ Error updating permission: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ── Tasks (admin-wide) ────────────────────────────────────────────────────

  Future<void> loadAllTasks() async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();
      _allTasks = snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      _filteredTasks = List.from(_allTasks);
      _computeAnalytics();
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    }
  }

  void filterTasks({String? status, String? priority, String? department}) {
    _filteredTasks = _allTasks.where((t) {
      if (status != null && status != 'all' && t.status != status) return false;
      if (priority != null && priority != 'all' && t.priority != priority) {
        return false;
      }
      if (department != null && department != 'all' && t.department != department) {
        return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  Future<bool> updateAdminTaskStatus(String taskId, String status) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({'status': status, 'updatedAt': DateTime.now().toIso8601String()});
      _allTasks = _allTasks.map((t) {
        return t.id == taskId
            ? Task(
                id: t.id,
                title: t.title,
                description: t.description,
                assignedTo: t.assignedTo,
                assignedBy: t.assignedBy,
                priority: t.priority,
                status: status,
                dueDate: t.dueDate,
                createdAt: t.createdAt,
                department: t.department,
                comments: t.comments,
              )
            : t;
      }).toList();
      filterTasks();
      _computeAnalytics();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Issues (admin-wide) ───────────────────────────────────────────────────

  Future<void> loadAllIssues() async {
    try {
      final snapshot = await _firestore
          .collection('issues')
          .orderBy('createdAt', descending: true)
          .get();
      _allIssues =
          snapshot.docs.map((doc) => IssueModel.fromFirestore(doc)).toList();
      _filteredIssues = List.from(_allIssues);
      _computeAnalytics();
    } catch (e) {
      _error = 'Failed to load issues: $e';
    }
  }

  void filterIssues({String? status, String? severity, String? department}) {
    _filteredIssues = _allIssues.where((i) {
      if (status != null && status != 'all' && i.status != status) return false;
      if (severity != null && severity != 'all' && i.severity != severity) {
        return false;
      }
      if (department != null && department != 'all' && i.department != department) {
        return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  Future<bool> updateAdminIssueStatus(String issueId, String status) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (status == 'resolved' || status == 'closed') {
        updates['resolvedAt'] = DateTime.now().toIso8601String();
      }
      await _firestore.collection('issues').doc(issueId).update(updates);
      _allIssues = _allIssues.map((i) {
        if (i.id != issueId) return i;
        return IssueModel(
          id: i.id,
          reportedBy: i.reportedBy,
          reporterName: i.reporterName,
          department: i.department,
          title: i.title,
          description: i.description,
          severity: i.severity,
          status: status,
          assignedTo: i.assignedTo,
          category: i.category,
          createdAt: i.createdAt,
          updatedAt: DateTime.now(),
          resolvedAt: (status == 'resolved' || status == 'closed')
              ? DateTime.now()
              : i.resolvedAt,
        );
      }).toList();
      filterIssues();
      _computeAnalytics();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Analytics ─────────────────────────────────────────────────────────────

  void _computeAnalytics() {
    _taskStats = {
      'pending': _allTasks.where((t) => t.status == 'pending').length,
      'in_progress': _allTasks.where((t) => t.status == 'in_progress').length,
      'pending_review':
          _allTasks.where((t) => t.status == 'pending_review').length,
      'approved': _allTasks.where((t) => t.status == 'approved').length,
      'rejected': _allTasks.where((t) => t.status == 'rejected').length,
    };
    _issueStats = {
      'open': _allIssues.where((i) => i.status == 'open').length,
      'in_progress':
          _allIssues.where((i) => i.status == 'in_progress').length,
      'resolved': _allIssues.where((i) => i.status == 'resolved').length,
      'closed': _allIssues.where((i) => i.status == 'closed').length,
      'critical': _allIssues.where((i) => i.severity == 'critical').length,
      'high': _allIssues.where((i) => i.severity == 'high').length,
      'medium': _allIssues.where((i) => i.severity == 'medium').length,
      'low': _allIssues.where((i) => i.severity == 'low').length,
    };
    notifyListeners();
  }

  Future<void> loadRecentActivity() async {
    try {
      final List<Map<String, dynamic>> activity = [];

      // Recent user registrations (last 5)
      final userSnap = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();
      for (final doc in userSnap.docs) {
        final d = doc.data();
        activity.add({
          'title': 'New user: ${d['displayName'] ?? 'Unknown'}',
          'sub': (d['role'] as String? ?? 'engineer'),
          'time': d['createdAt'] ?? '',
          'icon': 'person',
          'color': 'blue',
        });
      }

      // Recent task submissions
      final taskSnap = await _firestore
          .collection('tasks')
          .where('status', isEqualTo: 'pending_review')
          .orderBy('createdAt', descending: true)
          .limit(3)
          .get();
      for (final doc in taskSnap.docs) {
        final d = doc.data();
        activity.add({
          'title': 'Task for review: ${d['title'] ?? 'Unknown'}',
          'sub': d['department'] ?? '',
          'time': d['createdAt'] ?? '',
          'icon': 'task',
          'color': 'orange',
        });
      }

      // Recent critical issues
      final issueSnap = await _firestore
          .collection('issues')
          .where('severity', isEqualTo: 'critical')
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();
      for (final doc in issueSnap.docs) {
        final d = doc.data();
        activity.add({
          'title': 'Critical issue: ${d['title'] ?? 'Unknown'}',
          'sub': d['department'] ?? '',
          'time': d['createdAt'] ?? '',
          'icon': 'warning',
          'color': 'red',
        });
      }

      activity.sort((a, b) {
        final ta = a['time'] as String? ?? '';
        final tb = b['time'] as String? ?? '';
        return tb.compareTo(ta);
      });

      _recentActivity = activity.take(8).toList();
      notifyListeners();
    } catch (_) {
      // Non-critical
    }
  }

  /// Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
