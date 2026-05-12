import 'package:cloud_firestore/cloud_firestore.dart';

class IssueModel {
  final String id;
  final String reportedBy;
  final String reporterName;
  final String department;
  final String title;
  final String description;
  final String severity;  // 'low' | 'medium' | 'high' | 'critical'
  final String status;    // 'open' | 'in_progress' | 'resolved' | 'closed'
  final String? assignedTo;
  final String category;  // 'safety' | 'equipment' | 'quality' | 'process' | 'other'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  IssueModel({
    required this.id,
    required this.reportedBy,
    required this.reporterName,
    required this.department,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    this.assignedTo,
    required this.category,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'reportedBy': reportedBy,
    'reporterName': reporterName,
    'department': department,
    'title': title,
    'description': description,
    'severity': severity,
    'status': status,
    'assignedTo': assignedTo,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'resolvedAt': resolvedAt?.toIso8601String(),
  };

  factory IssueModel.fromMap(Map<String, dynamic> map) => IssueModel(
    id: map['id'] ?? '',
    reportedBy: map['reportedBy'] ?? '',
    reporterName: map['reporterName'] ?? '',
    department: map['department'] ?? '',
    title: map['title'] ?? '',
    description: map['description'] ?? '',
    severity: map['severity'] ?? 'medium',
    status: map['status'] ?? 'open',
    assignedTo: map['assignedTo'],
    category: map['category'] ?? 'other',
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : DateTime.now(),
    updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : null,
    resolvedAt: map['resolvedAt'] != null
        ? DateTime.parse(map['resolvedAt'])
        : null,
  );

  factory IssueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IssueModel.fromMap({...data, 'id': doc.id});
  }

  bool get isOpen => status == 'open' || status == 'in_progress';
}
