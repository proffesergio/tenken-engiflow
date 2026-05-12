import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/supervisor_provider.dart';
import 'package:tenken_engiflow/presentation/components/attendance_card.dart';

const _kOrange = Color(0xFFF57C00);
const _kSlate = Color(0xFF37474F);

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final sv = context.watch<SupervisorProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker row
          _DatePickerRow(
            date: _selectedDate,
            onChanged: (d) {
              setState(() => _selectedDate = d);
              sv.loadAttendanceRecords(d);
            },
          ),
          const SizedBox(height: 20),

          // Attendance stats
          _SectionHeader(title: 'Attendance — ${_dateLabel(_selectedDate)}'),
          const SizedBox(height: 10),
          _AttendanceStats(sv: sv),
          const SizedBox(height: 20),

          // Pending approvals
          const _SectionHeader(title: 'Pending Approvals'),
          const SizedBox(height: 10),
          _PendingStats(sv: sv),
          const SizedBox(height: 20),

          // Issues overview
          const _SectionHeader(title: 'Issues Overview'),
          const SizedBox(height: 10),
          _IssueStats(sv: sv),
          const SizedBox(height: 20),

          // Attendance records list
          _SectionHeader(title: 'Check-ins — ${_dateLabel(_selectedDate)}'),
          const SizedBox(height: 10),
          if (sv.attendanceRecords.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: const Center(
                child: Text(
                  'No attendance records for this date',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            )
          else
            for (final r in sv.attendanceRecords) AttendanceCard(record: r),
        ],
      ),
    );
  }

  static String _dateLabel(DateTime d) {
    final now = DateTime.now();
    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return 'Today';
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

// ── Date picker row ───────────────────────────────────────────────────────────

class _DatePickerRow extends StatelessWidget {
  final DateTime date;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerRow({required this.date, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final label =
        '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: _kOrange),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _kSlate,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Attendance stats ──────────────────────────────────────────────────────────

class _AttendanceStats extends StatelessWidget {
  final SupervisorProvider sv;
  const _AttendanceStats({required this.sv});

  @override
  Widget build(BuildContext context) {
    final total = sv.teamMembers.length;
    final present = sv.presentTodayCount;
    final absent = sv.absentTodayCount;
    final unknown = total - present - absent;
    final rate = total == 0 ? 0.0 : present / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          // Rate + bar
          Row(
            children: [
              Text(
                total == 0
                    ? '—'
                    : '${(rate * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: _kSlate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance rate',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    _ProgressBar(value: rate, color: Colors.green),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Breakdown row
          Row(
            children: [
              _AttendStat(
                label: 'Present',
                count: present,
                color: Colors.green,
              ),
              _AttendStat(
                label: 'Absent',
                count: absent,
                color: Colors.red,
              ),
              _AttendStat(
                label: 'Unknown',
                count: unknown < 0 ? 0 : unknown,
                color: Colors.grey,
              ),
              _AttendStat(
                label: 'Total',
                count: total,
                color: _kSlate,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _AttendStat({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value; // 0.0 – 1.0
  final Color color;
  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: 8,
      ),
    );
  }
}

// ── Pending approvals stats ───────────────────────────────────────────────────

class _PendingStats extends StatelessWidget {
  final SupervisorProvider sv;
  const _PendingStats({required this.sv});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.assignment_late,
            label: 'Tasks',
            value: sv.pendingTasks.length,
            color: _kOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricTile(
            icon: Icons.description,
            label: 'Work Entries',
            value: sv.pendingWorkEntries.length,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: value > 0 ? color : Colors.grey,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Issues overview ───────────────────────────────────────────────────────────

class _IssueStats extends StatelessWidget {
  final SupervisorProvider sv;
  const _IssueStats({required this.sv});

  @override
  Widget build(BuildContext context) {
    final total = sv.departmentIssues.length;
    final open = sv.departmentIssues.where((i) => i.status == 'open').length;
    final inProgress =
        sv.departmentIssues.where((i) => i.status == 'in_progress').length;
    final resolved =
        sv.departmentIssues.where((i) => i.status == 'resolved').length;
    final critical = sv.departmentIssues
        .where((i) => i.severity == 'critical' && i.isOpen)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _IssueStat(label: 'Total', count: total, color: _kSlate),
              _IssueStat(label: 'Open', count: open, color: Colors.red),
              _IssueStat(
                  label: 'In Progress', count: inProgress, color: _kOrange),
              _IssueStat(
                  label: 'Resolved', count: resolved, color: Colors.green),
            ],
          ),
          if (critical > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '$critical critical issue${critical > 1 ? 's' : ''} require immediate attention',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IssueStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _IssueStat({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
