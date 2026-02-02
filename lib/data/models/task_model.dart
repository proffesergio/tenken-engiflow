import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final String assignedTo; // User ID
  final String assignedBy; // Supervisor ID
  final String priority; // 'low', 'medium', 'high'
  final String status; // 'pending', 'in_progress', 'completed', 'overdue'
  final DateTime dueDate;
  final DateTime createdAt;
  final String? department;
  final List<String>? attachments;
  final String? comments;
  
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.assignedBy,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.department,
    this.attachments,
    this.comments,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'priority': priority,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'department': department,
      'attachments': attachments,
      'comments': comments,
    };
  }
  
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      assignedTo: map['assignedTo'],
      assignedBy: map['assignedBy'],
      priority: map['priority'],
      status: map['status'],
      dueDate: DateTime.parse(map['dueDate']),
      createdAt: DateTime.parse(map['createdAt']),
      department: map['department'],
      attachments: map['attachments'] != null 
          ? List<String>.from(map['attachments'])
          : null,
      comments: map['comments'],
    );
  }
  
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Task.fromMap({...data, 'id': doc.id});
  }
}