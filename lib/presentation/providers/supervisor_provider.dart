import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tenken_engiflow/data/models/task_model.dart';
import 'package:tenken_engiflow/data/models/attendance_model.dart';
import 'package:tenken_engiflow/data/models/issue_model.dart';
import 'package:tenken_engiflow/data/models/work_entry_model.dart';

class SupervisorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Map<String, dynamic>> _teamMembers = [];
  List<Task> _pendingTasks = [];
  List<AttendanceRecord> _attendanceRecords = [];
  List<IssueModel> _departmentIssues = [];
  List<WorkEntry> _pendingWorkEntries = [];
  List<Map<String, dynamic>> _recentActivity = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get teamMembers => _teamMembers;
  List<Task> get pendingTasks => _pendingTasks;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  List<IssueModel> get departmentIssues => _departmentIssues;
  List<IssueModel> get openIssues =>
      _departmentIssues.where((i) => i.isOpen).toList();
  List<WorkEntry> get pendingWorkEntries => _pendingWorkEntries;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Computed attendance stats ─────────────────────────────────────────────

  int get presentTodayCount => _attendanceRecords
      .where((r) => r.status == 'present' || r.status == 'late')
      .length;

  int get absentTodayCount =>
      _attendanceRecords.where((r) => r.status == 'absent').length;

  double get attendanceRateToday {
    if (_teamMembers.isEmpty) return 0;
    return (presentTodayCount / _teamMembers.length) * 100;
  }

  // ── Team members ──────────────────────────────────────────────────────────

  Future<void> loadTeamMembers({String? department}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .where('role', isEqualTo: 'engineer');
      if (department != null && department.isNotEmpty) {
        query = query.where('department', isEqualTo: department);
      }
      final snapshot = await query.get();
      _teamMembers = snapshot.docs.map((doc) {
        return <String, dynamic>{'id': doc.id, ...doc.data()};
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Pending tasks ─────────────────────────────────────────────────────────

  Future<void> loadPendingTasks() async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('status', isEqualTo: 'pending_review')
          .orderBy('createdAt', descending: true)
          .get();
      _pendingTasks =
          snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> approveTask(String taskId, String comments) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'approved',
        'approvedBy': uid,
        'approvedAt': DateTime.now().toIso8601String(),
        'comments': comments,
      });
      _pendingTasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectTask(String taskId, String reason) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'rejected',
        'rejectedBy': uid,
        'rejectedAt': DateTime.now().toIso8601String(),
        'comments': reason,
      });
      _pendingTasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> assignTask({
    required String title,
    required String description,
    required String assignedTo,
    required String priority,
    required DateTime dueDate,
    String? department,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      final taskId = _firestore.collection('tasks').doc().id;
      final task = Task(
        id: taskId,
        title: title,
        description: description,
        assignedTo: assignedTo,
        assignedBy: uid,
        priority: priority,
        status: 'pending',
        dueDate: dueDate,
        createdAt: DateTime.now(),
        department: department,
      );
      await _firestore.collection('tasks').doc(taskId).set(task.toMap());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Attendance ────────────────────────────────────────────────────────────

  Future<void> loadAttendanceRecords(DateTime date) async {
    try {
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final snapshot = await _firestore
          .collection('attendance')
          .where('date', isEqualTo: dateStr)
          .get();
      _attendanceRecords = snapshot.docs
          .map((doc) => AttendanceRecord.fromFirestore(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> updateAttendance({
    required String userId,
    required DateTime date,
    required String status,
    String? notes,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final attendanceId = '${userId}_$dateStr';
      await _firestore
          .collection('attendance')
          .doc(attendanceId)
          .set({
        'id': attendanceId,
        'userId': userId,
        'date': dateStr,
        'status': status,
        'notes': notes,
        'approvedBy': uid,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Department issues ─────────────────────────────────────────────────────

  Future<void> loadDepartmentIssues(String department) async {
    try {
      final snapshot = department.isEmpty
          ? await _firestore
              .collection('issues')
              .orderBy('createdAt', descending: true)
              .limit(100)
              .get()
          : await _firestore
              .collection('issues')
              .where('department', isEqualTo: department)
              .orderBy('createdAt', descending: true)
              .get();
      _departmentIssues =
          snapshot.docs.map((doc) => IssueModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> updateIssueStatus(
    String issueId,
    String status, {
    String? assignedTo,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (assignedTo != null) updates['assignedTo'] = assignedTo;
      if (status == 'resolved' || status == 'closed') {
        updates['resolvedAt'] = DateTime.now().toIso8601String();
      }
      await _firestore.collection('issues').doc(issueId).update(updates);
      _departmentIssues = _departmentIssues.map((issue) {
        if (issue.id != issueId) return issue;
        return IssueModel(
          id: issue.id,
          reportedBy: issue.reportedBy,
          reporterName: issue.reporterName,
          department: issue.department,
          title: issue.title,
          description: issue.description,
          severity: issue.severity,
          status: status,
          assignedTo: assignedTo ?? issue.assignedTo,
          category: issue.category,
          createdAt: issue.createdAt,
          updatedAt: DateTime.now(),
          resolvedAt: (status == 'resolved' || status == 'closed')
              ? DateTime.now()
              : issue.resolvedAt,
        );
      }).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Work entry approvals ──────────────────────────────────────────────────

  Future<void> loadPendingWorkEntries() async {
    try {
      final snapshot = await _firestore
          .collection('work_entries')
          .where('status', isEqualTo: 'submitted')
          .orderBy('createdAt', descending: true)
          .get();
      _pendingWorkEntries =
          snapshot.docs.map((doc) => WorkEntry.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> approveWorkEntry(String entryId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      await _firestore.collection('work_entries').doc(entryId).update({
        'status': 'approved',
        'supervisorId': uid,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      _pendingWorkEntries.removeWhere((e) => e.id == entryId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> rejectWorkEntry(String entryId) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;
      await _firestore.collection('work_entries').doc(entryId).update({
        'status': 'draft',
        'supervisorId': uid,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      _pendingWorkEntries.removeWhere((e) => e.id == entryId);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Recent activity ───────────────────────────────────────────────────────

  Future<void> loadRecentActivity(String department) async {
    try {
      final List<Map<String, dynamic>> activity = [];
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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
          'title': d['title'] ?? 'Task submitted for review',
          'time': d['createdAt'] ?? '',
          'color': 'orange',
          'icon': 'task',
        });
      }

      // Today's check-ins
      final attSnap = await _firestore
          .collection('attendance')
          .where('date', isEqualTo: dateStr)
          .limit(4)
          .get();
      for (final doc in attSnap.docs) {
        final d = doc.data();
        final late = d['isLate'] == true;
        final name = d['userName'] as String? ?? 'Engineer';
        activity.add({
          'title': late ? '$name checked in late' : '$name checked in',
          'time': d['createdAt'] ?? '',
          'color': late ? 'orange' : 'green',
          'icon': late ? 'schedule' : 'check',
        });
      }

      // Recent issues
      final issueSnap = department.isNotEmpty
          ? await _firestore
              .collection('issues')
              .where('department', isEqualTo: department)
              .orderBy('createdAt', descending: true)
              .limit(3)
              .get()
          : await _firestore
              .collection('issues')
              .orderBy('createdAt', descending: true)
              .limit(3)
              .get();
      for (final doc in issueSnap.docs) {
        final d = doc.data();
        final sev = d['severity'] as String? ?? '';
        activity.add({
          'title':
              '${d['reporterName'] ?? 'Engineer'} reported: ${d['title'] ?? 'Issue'}',
          'time': d['createdAt'] ?? '',
          'color': (sev == 'critical' || sev == 'high') ? 'red' : 'blue',
          'icon': 'warning',
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
      // Non-critical — don't surface error
    }
  }
}
