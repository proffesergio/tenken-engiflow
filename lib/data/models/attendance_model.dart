import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String userId;
  final String userName;
  final DateTime date;
  final String checkInTime;   // 'HH:MM', empty if not yet checked in
  final String? checkOutTime; // 'HH:MM', null until checked out
  final String status;        // 'present' | 'late' | 'absent' | 'half_day' | 'leave'
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

  bool get hasCheckedIn => checkInTime.isNotEmpty;
  bool get hasCheckedOut => checkOutTime != null && checkOutTime!.isNotEmpty;

  Map<String, dynamic> toMap() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
    'checkInTime': checkInTime,
    'checkOutTime': checkOutTime,
    'status': status,
    'hoursWorked': hoursWorked,
    'notes': notes,
    'approvedBy': approvedBy,
    'createdAt': createdAt.toIso8601String(),
  };

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    try {
      // Stored as 'YYYY-MM-DD' or ISO string
      final raw = map['date'] as String? ?? '';
      parsedDate = raw.length == 10
          ? DateTime.parse('${raw}T00:00:00')
          : DateTime.parse(raw);
    } catch (_) {
      parsedDate = DateTime.now();
    }

    DateTime parsedCreatedAt;
    try {
      parsedCreatedAt = DateTime.parse(map['createdAt'] as String? ?? '');
    } catch (_) {
      parsedCreatedAt = DateTime.now();
    }

    return AttendanceRecord(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? '',
      date: parsedDate,
      checkInTime: map['checkInTime'] as String? ?? '',
      checkOutTime: map['checkOutTime'] as String?,
      status: map['status'] as String? ?? 'present',
      hoursWorked: (map['hoursWorked'] as num?)?.toDouble(),
      notes: map['notes'] as String?,
      approvedBy: map['approvedBy'] as String?,
      createdAt: parsedCreatedAt,
    );
  }

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord.fromMap({...data, 'id': doc.id});
  }
}
