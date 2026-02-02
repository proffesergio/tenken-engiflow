import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tenken_engiflow/data/models/task_model.dart';
import 'package:tenken_engiflow/data/models/attendance_model.dart';

class SupervisorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Map<String, dynamic>> _teamMembers = [];
  List<Task> _pendingTasks = [];
  List<AttendanceRecord> _attendanceRecords = [];
  List<Map<String, dynamic>> _pendingApprovals = [];
  bool _isLoading = false;
  
  List<Map<String, dynamic>> get teamMembers => _teamMembers;
  List<Task> get pendingTasks => _pendingTasks;
  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  List<Map<String, dynamic>> get pendingApprovals => _pendingApprovals;
  bool get isLoading => _isLoading;
  
  // Load team members (engineers under this supervisor)
  Future<void> loadTeamMembers() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      // Get users in same department with engineer role
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'engineer')
          .get();
      
      _teamMembers = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      
    } catch (e) {
      print('Error loading team members: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load pending tasks for approval
  Future<void> loadPendingTasks() async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('status', isEqualTo: 'pending_review')
          .orderBy('createdAt', descending: true)
          .get();
      
      _pendingTasks = snapshot.docs.map((doc) {
        return Task.fromFirestore(doc);
      }).toList();
      
      notifyListeners();
    } catch (e) {
      print('Error loading pending tasks: $e');
    }
  }
  
  // Load attendance records for team
  Future<void> loadAttendanceRecords(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final snapshot = await _firestore
          .collection('attendance')
          .where('date', isEqualTo: dateStr)
          .get();
      
      _attendanceRecords = snapshot.docs.map((doc) {
        return AttendanceRecord.fromFirestore(doc);
      }).toList();
      
      notifyListeners();
    } catch (e) {
      print('Error loading attendance: $e');
    }
  }
  
  // Approve a task
  Future<bool> approveTask(String taskId, String comments) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'approved',
        'approvedBy': currentUser.uid,
        'approvedAt': DateTime.now().toIso8601String(),
        'approvalComments': comments,
      });
      
      // Remove from pending list
      _pendingTasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error approving task: $e');
      return false;
    }
  }
  
  // Reject a task
  Future<bool> rejectTask(String taskId, String reason) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'rejected',
        'rejectedBy': currentUser.uid,
        'rejectedAt': DateTime.now().toIso8601String(),
        'rejectionReason': reason,
      });
      
      _pendingTasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
      
      return true;
    } catch (e) {
      print('Error rejecting task: $e');
      return false;
    }
  }
  
  // Assign new task to team member
  Future<bool> assignTask({
    required String title,
    required String description,
    required String assignedTo,
    required String priority,
    required DateTime dueDate,
    String? department,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      final taskId = _firestore.collection('tasks').doc().id;
      
      final task = Task(
        id: taskId,
        title: title,
        description: description,
        assignedTo: assignedTo,
        assignedBy: currentUser.uid,
        priority: priority,
        status: 'pending',
        dueDate: dueDate,
        createdAt: DateTime.now(),
        department: department,
      );
      
      await _firestore.collection('tasks').doc(taskId).set(task.toMap());
      
      return true;
    } catch (e) {
      print('Error assigning task: $e');
      return false;
    }
  }
  
  // Update attendance status
  Future<bool> updateAttendance({
    required String userId,
    required DateTime date,
    required String status,
    String? notes,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return false;
      
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final attendanceId = '${userId}_$dateStr';
      
      await _firestore.collection('attendance').doc(attendanceId).set({
        'id': attendanceId,
        'userId': userId,
        'date': dateStr,
        'status': status,
        'notes': notes,
        'approvedBy': currentUser.uid,
        'updatedAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      print('Error updating attendance: $e');
      return false;
    }
  }
  
  // Get performance metrics for team
  Future<Map<String, dynamic>> getTeamPerformance(DateTime startDate, DateTime endDate) async {
    try {
      // This would be a complex query in real app
      // For now, return mock data
      return {
        'totalTasks': 150,
        'completedTasks': 135,
        'completionRate': 90.0,
        'avgTaskTime': '2.5 days',
        'onTimeRate': 85.0,
        'attendanceRate': 95.0,
      };
    } catch (e) {
      print('Error getting performance: $e');
      return {};
    }
  }
}