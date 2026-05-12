import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenken_engiflow/data/models/issue_model.dart';

class IssueProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<IssueModel> _issues = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  List<IssueModel> get issues => _issues;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;

  List<IssueModel> get openIssues => _issues.where((i) => i.isOpen).toList();

  Future<void> loadMyIssues(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('issues')
          .where('reportedBy', isEqualTo: userId)
          .get();

      _issues = snapshot.docs
          .map((doc) => IssueModel.fromFirestore(doc))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Failed to load issues: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reportIssue({
    required String reportedBy,
    required String reporterName,
    required String department,
    required String title,
    required String description,
    required String severity,
    required String category,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docRef = _firestore.collection('issues').doc();
      final issue = IssueModel(
        id: docRef.id,
        reportedBy: reportedBy,
        reporterName: reporterName,
        department: department,
        title: title,
        description: description,
        severity: severity,
        status: 'open',
        category: category,
        createdAt: DateTime.now(),
      );

      await docRef.set(issue.toMap());
      _issues.insert(0, issue);
      _successMessage = 'Issue reported successfully';
      return true;
    } catch (e) {
      _error = 'Failed to report issue: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _error = null;
    _successMessage = null;
    notifyListeners();
  }
}
