import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final String checkInTime;
  final String? checkOutTime;
  final String status; // 'present', 'absent', 'late', 'half_day'
  final double? hoursWorked;
  final String? notes;
  final String? approvedBy;
  final DateTime createdAt;
  
  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.userName,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.hoursWorked,
    this.notes,
    this.approvedBy,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'date': date.toIso8601String(),
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'status': status,
      'hoursWorked': hoursWorked,
      'notes': notes,
      'approvedBy': approvedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      userId: map['userId'],
      userName: map['userName'],
      date: DateTime.parse(map['date']),
      checkInTime: map['checkInTime'],
      checkOutTime: map['checkOutTime'],
      status: map['status'],
      hoursWorked: map['hoursWorked'],
      notes: map['notes'],
      approvedBy: map['approvedBy'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  
  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord.fromMap({...data, 'id': doc.id});
  }
}