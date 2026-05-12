import 'package:cloud_firestore/cloud_firestore.dart';

class WorkEntry {
  final String id;
  final String engineerId;
  final String engineerName;
  final String date;      // 'YYYY-MM-DD'
  final String? taskId;
  final String? taskTitle;
  final String description;
  final double hoursWorked;
  final String status;    // 'draft' | 'submitted' | 'approved'
  final String? supervisorId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  WorkEntry({
    required this.id,
    required this.engineerId,
    required this.engineerName,
    required this.date,
    this.taskId,
    this.taskTitle,
    required this.description,
    required this.hoursWorked,
    required this.status,
    this.supervisorId,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'engineerId': engineerId,
    'engineerName': engineerName,
    'date': date,
    'taskId': taskId,
    'taskTitle': taskTitle,
    'description': description,
    'hoursWorked': hoursWorked,
    'status': status,
    'supervisorId': supervisorId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory WorkEntry.fromMap(Map<String, dynamic> map) => WorkEntry(
    id: map['id'] ?? '',
    engineerId: map['engineerId'] ?? '',
    engineerName: map['engineerName'] ?? '',
    date: map['date'] ?? '',
    taskId: map['taskId'],
    taskTitle: map['taskTitle'],
    description: map['description'] ?? '',
    hoursWorked: (map['hoursWorked'] as num?)?.toDouble() ?? 0.0,
    status: map['status'] ?? 'submitted',
    supervisorId: map['supervisorId'],
    createdAt: map['createdAt'] != null
        ? DateTime.parse(map['createdAt'])
        : DateTime.now(),
    updatedAt: map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'])
        : null,
  );

  factory WorkEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkEntry.fromMap({...data, 'id': doc.id});
  }
}
