import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenken_engiflow/data/models/user_model.dart';
import 'package:tenken_engiflow/data/models/system_config_model.dart';

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
  
  // Statistics Getters
  int get totalUsers => _allUsers.length;
  int get totalEngineers => _allUsers.where((u) => u.isEngineer).length;
  int get totalSupervisors => _allUsers.where((u) => u.isSupervisor).length;
  int get totalAdmins => _allUsers.where((u) => u.isAdmin).length;
  int get activeUsers => _allUsers.where((u) => u.uid.isNotEmpty).length;
  
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
  
  /// Create new user (Admin only)
  Future<bool> createNewUser({
    required String email,
    required String password,
    required String displayName,
    required String role,
    required String department,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Create Firebase Auth user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        department: department,
        createdAt: DateTime.now(),
        managedDepartments: role == 'supervisor' ? [department] : null,
        teamMemberIds: role == 'supervisor' ? [] : null,
      );
      
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toMap());
      
      _allUsers.add(newUser);
      _filteredUsers = List.from(_allUsers);
      
      _successMessage = 'User created successfully: $displayName';
      return true;
      
    } on FirebaseAuthException catch (e) {
      _error = 'Auth error: ${e.message}';
      print('❌ Auth error: $e');
      return false;
    } catch (e) {
      _error = 'Failed to create user: $e';
      print('❌ Error creating user: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
  
  /// Delete user (Admin only)
  Future<bool> deleteUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Delete user document from Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .delete();
      
      // Remove from local list
      _allUsers.removeWhere((u) => u.uid == userId);
      _filteredUsers = List.from(_allUsers);
      
      _successMessage = 'User deleted successfully';
      return true;
      
    } catch (e) {
      _error = 'Failed to delete user: $e';
      print('❌ Error deleting user: $e');
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
  
  /// Clear messages
  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
