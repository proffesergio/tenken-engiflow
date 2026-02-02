import 'package:flutter/material.dart';
import 'package:tenken_engiflow/data/models/attendance_model.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  
  const AttendanceCard({super.key, required this.record});
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'half_day':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.schedule;
      case 'half_day':
        return Icons.hourglass_bottom;
      default:
        return Icons.help;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(record.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getStatusIcon(record.status),
              color: _getStatusColor(record.status),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Checked in: ${record.checkInTime}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (record.checkOutTime != null)
                  Text(
                    'Checked out: ${record.checkOutTime}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(record.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _getStatusColor(record.status).withOpacity(0.3)),
            ),
            child: Text(
              record.status.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _getStatusColor(record.status),
              ),
            ),
          ),
        ],
      ),
    );
  }
}