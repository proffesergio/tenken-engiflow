import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tenken_engiflow/data/models/attendance_model.dart';

class AttendanceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AttendanceRecord? _todayRecord;
  bool _isLoading = false;
  String? _error;
  String? _successMessage;

  AttendanceRecord? get todayRecord => _todayRecord;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  bool get isCheckedIn => _todayRecord?.hasCheckedIn ?? false;
  bool get isCheckedOut => _todayRecord?.hasCheckedOut ?? false;

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _timeStr(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Future<void> loadTodayRecord(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docId = '${userId}_${_dateStr(DateTime.now())}';
      final doc = await _firestore.collection('attendance').doc(docId).get();

      _todayRecord = doc.exists
          ? AttendanceRecord.fromMap({...doc.data()!, 'id': doc.id})
          : null;
    } catch (e) {
      _error = 'Failed to load attendance: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIn({
    required String userId,
    required String userName,
    required String department,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final dateStr = _dateStr(now);
      final docId = '${userId}_$dateStr';

      // Late if checking in after 09:00
      final isLate = now.hour > 9 || (now.hour == 9 && now.minute > 0);
      final status = isLate ? 'late' : 'present';
      final timeStr = _timeStr(now);

      final data = {
        'id': docId,
        'userId': userId,
        'userName': userName,
        'department': department,
        'date': dateStr,
        'checkInTime': timeStr,
        'checkOutTime': null,
        'status': status,
        'hoursWorked': null,
        'createdAt': now.toIso8601String(),
      };

      await _firestore.collection('attendance').doc(docId).set(data);

      _todayRecord = AttendanceRecord.fromMap(data);
      _successMessage = 'Checked in at $timeStr';
      return true;
    } catch (e) {
      _error = 'Check-in failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkOut({required String userId}) async {
    if (_todayRecord == null || !_todayRecord!.hasCheckedIn) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final timeStr = _timeStr(now);

      // Compute hours worked from checkIn string
      final parts = _todayRecord!.checkInTime.split(':');
      final checkInDt = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );
      final hours = now.difference(checkInDt).inMinutes / 60.0;
      final roundedHours = double.parse(hours.toStringAsFixed(1));

      final docId = _todayRecord!.id;
      await _firestore.collection('attendance').doc(docId).update({
        'checkOutTime': timeStr,
        'hoursWorked': roundedHours,
        'updatedAt': now.toIso8601String(),
      });

      _todayRecord = AttendanceRecord(
        id: docId,
        userId: _todayRecord!.userId,
        userName: _todayRecord!.userName,
        date: _todayRecord!.date,
        checkInTime: _todayRecord!.checkInTime,
        checkOutTime: timeStr,
        status: _todayRecord!.status,
        hoursWorked: roundedHours,
        notes: _todayRecord!.notes,
        approvedBy: _todayRecord!.approvedBy,
        createdAt: _todayRecord!.createdAt,
      );

      _successMessage = 'Checked out at $timeStr — $roundedHours hrs';
      return true;
    } catch (e) {
      _error = 'Check-out failed: $e';
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
