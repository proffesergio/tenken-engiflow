import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/providers/attendance_provider.dart';
import 'package:tenken_engiflow/presentation/providers/task_provider.dart';
import 'package:tenken_engiflow/presentation/screens/engineer/task_detail_screen.dart';
import 'package:tenken_engiflow/presentation/screens/engineer/reports_tab.dart';
import 'package:tenken_engiflow/data/models/task_model.dart';

const _kSlate = Color(0xFF37474F);

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final attendance = context.watch<AttendanceProvider>();
    final taskProvider = context.watch<TaskProvider>();
    final userData = auth.userData;

    final name = userData?['displayName'] as String? ?? 'Engineer';
    final dept = userData?['department'] as String? ?? '';
    final now = DateTime.now();
    final weekday = _weekdayName(now.weekday);
    final dateLabel = '$weekday, ${now.day} ${_monthName(now.month)}';

    return RefreshIndicator(
      onRefresh: () async {
        final uid = userData?['uid'] as String? ?? '';
        if (uid.isEmpty) return;
        await Future.wait([
          context.read<AttendanceProvider>().loadTodayRecord(uid),
          context.read<TaskProvider>().loadMyTasks(uid),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeBanner(name: name, dept: dept, dateLabel: dateLabel),
            const SizedBox(height: 16),
            _AttendanceCard(attendance: attendance, userData: userData),
            const SizedBox(height: 20),
            _TaskSummaryGrid(taskProvider: taskProvider),
            const SizedBox(height: 20),
            _QuickActions(userData: userData),
            const SizedBox(height: 20),
            _TodayTasksSection(tasks: taskProvider.pendingTasks + taskProvider.inProgressTasks),
          ],
        ),
      ),
    );
  }

  static String _weekdayName(int d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d - 1];

  static String _monthName(int m) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];
}

// ── Welcome banner ─────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  final String name;
  final String dept;
  final String dateLabel;

  const _WelcomeBanner({
    required this.name,
    required this.dept,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSlate,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Good ${_greeting()}, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (dept.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      dept,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(Icons.engineering, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

// ── Attendance card ─────────────────────────────────────────────────────────

class _AttendanceCard extends StatelessWidget {
  final AttendanceProvider attendance;
  final Map<String, dynamic>? userData;

  const _AttendanceCard({required this.attendance, required this.userData});

  @override
  Widget build(BuildContext context) {
    final record = attendance.todayRecord;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.access_time_rounded, color: _kSlate, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Attendance',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: _kSlate,
                  ),
                ),
                const Spacer(),
                if (record != null) _StatusChip(record.status),
              ],
            ),
            const SizedBox(height: 14),
            if (record == null || !record.hasCheckedIn) ...[
              const Text(
                'You haven\'t checked in yet',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: attendance.isLoading ? null : () => _checkIn(context),
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('Check In'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kSlate,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ] else ...[
              _TimeRow(
                label: 'Checked in',
                time: record.checkInTime,
                icon: Icons.login,
                color: Colors.green,
              ),
              if (record.hasCheckedOut) ...[
                const SizedBox(height: 8),
                _TimeRow(
                  label: 'Checked out',
                  time: record.checkOutTime!,
                  icon: Icons.logout,
                  color: Colors.orange,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      '${record.hoursWorked?.toStringAsFixed(1) ?? "—"} hours worked',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: attendance.isLoading ? null : () => _checkOut(context),
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Check Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _checkIn(BuildContext context) async {
    final uid = userData?['uid'] as String? ?? '';
    final name = userData?['displayName'] as String? ?? '';
    final dept = userData?['department'] as String? ?? '';
    if (uid.isEmpty) return;

    final success = await context.read<AttendanceProvider>().checkIn(
      userId: uid,
      userName: name,
      department: dept,
    );

    if (context.mounted) {
      final msg = context.read<AttendanceProvider>().successMessage ??
          context.read<AttendanceProvider>().error ?? '';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }

  Future<void> _checkOut(BuildContext context) async {
    final uid = userData?['uid'] as String? ?? '';
    if (uid.isEmpty) return;

    final success = await context
        .read<AttendanceProvider>()
        .checkOut(userId: uid);

    if (context.mounted) {
      final msg = context.read<AttendanceProvider>().successMessage ??
          context.read<AttendanceProvider>().error ?? '';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
      ));
    }
  }
}

class _TimeRow extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color color;

  const _TimeRow({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        const SizedBox(width: 8),
        Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'present' => ('Present', Colors.green),
      'late' => ('Late', Colors.orange),
      'absent' => ('Absent', Colors.red),
      'half_day' => ('Half Day', Colors.blue),
      'leave' => ('On Leave', Colors.purple),
      _ => ('Unknown', Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Task summary ────────────────────────────────────────────────────────────

class _TaskSummaryGrid extends StatelessWidget {
  final TaskProvider taskProvider;
  const _TaskSummaryGrid({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _kSlate,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'Pending',
                count: taskProvider.pendingTasks.length,
                color: Colors.grey,
                icon: Icons.hourglass_empty_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                label: 'In Progress',
                count: taskProvider.inProgressTasks.length,
                color: Colors.blue,
                icon: Icons.play_circle_outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'Submitted',
                count: taskProvider.submittedTasks.length,
                color: Colors.orange,
                icon: Icons.upload_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                label: 'Approved',
                count: taskProvider.approvedTasks.length,
                color: Colors.green,
                icon: Icons.check_circle_outline,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _SummaryTile({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick actions ────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const _QuickActions({required this.userData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _kSlate,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.add_circle_outline,
                label: 'New Work Entry',
                color: _kSlate,
                onTap: () => showWorkEntrySheet(context, userData: userData),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.report_problem_outlined,
                label: 'Report Issue',
                color: Colors.orange,
                onTap: () => showIssueReportSheet(context, userData: userData),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Today's tasks preview ────────────────────────────────────────────────────

class _TodayTasksSection extends StatelessWidget {
  final List<Task> tasks;
  const _TodayTasksSection({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const SizedBox.shrink();

    final preview = tasks.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Tasks',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _kSlate,
              ),
            ),
            if (tasks.length > 3)
              TextButton(
                onPressed: () {},
                child: Text(
                  'See all (${tasks.length})',
                  style: const TextStyle(color: _kSlate, fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ...preview.map((task) => _TaskPreviewRow(task: task)),
      ],
    );
  }
}

class _TaskPreviewRow extends StatelessWidget {
  final Task task;
  const _TaskPreviewRow({required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: _priorityColor(task.priority),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _kSlate,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Due ${_formatDate(task.dueDate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            _StatusBadge(task.status),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  static Color _priorityColor(String p) => switch (p) {
    'high' || 'urgent' => Colors.red,
    'medium' => Colors.orange,
    _ => Colors.green,
  };

  static String _formatDate(DateTime d) =>
      '${d.day} ${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][d.month - 1]}';
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'pending' => ('Pending', Colors.grey),
      'in_progress' => ('In Progress', Colors.blue),
      'pending_review' => ('Submitted', Colors.orange),
      'approved' => ('Approved', Colors.green),
      'rejected' => ('Rejected', Colors.red),
      _ => (status, Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
