import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenken_engiflow/data/models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  // Filtered views
  List<Task> get pendingTasks =>
      _tasks.where((t) => t.status == 'pending').toList();
  List<Task> get inProgressTasks =>
      _tasks.where((t) => t.status == 'in_progress').toList();
  List<Task> get submittedTasks =>
      _tasks.where((t) => t.status == 'pending_review').toList();
  List<Task> get approvedTasks =>
      _tasks.where((t) => t.status == 'approved').toList();
  List<Task> get rejectedTasks =>
      _tasks.where((t) => t.status == 'rejected').toList();
  List<Task> get overdueTasks => _tasks.where((t) {
    final active = t.status != 'approved' && t.status != 'rejected';
    return active && t.dueDate.isBefore(DateTime.now());
  }).toList();

  Future<void> loadMyTasks(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .get();

      _tasks = snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Transitions pending → in_progress.
  Future<bool> startTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'in_progress',
        'startedAt': DateTime.now().toIso8601String(),
      });
      _updateLocalStatus(taskId, 'in_progress');
      _successMessage = 'Task started';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to start task: $e';
      notifyListeners();
      return false;
    }
  }

  /// Transitions in_progress or rejected → pending_review.
  Future<bool> submitTask(String taskId, String completionNote) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': 'pending_review',
        'completionNote': completionNote,
        'submittedAt': DateTime.now().toIso8601String(),
      });
      _updateLocalStatus(taskId, 'pending_review');
      _successMessage = 'Task submitted for review';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to submit task: $e';
      notifyListeners();
      return false;
    }
  }

  void _updateLocalStatus(String taskId, String newStatus) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    final t = _tasks[idx];
    _tasks[idx] = Task(
      id: t.id,
      title: t.title,
      description: t.description,
      assignedTo: t.assignedTo,
      assignedBy: t.assignedBy,
      priority: t.priority,
      status: newStatus,
      dueDate: t.dueDate,
      createdAt: t.createdAt,
      department: t.department,
      attachments: t.attachments,
      comments: t.comments,
    );
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
