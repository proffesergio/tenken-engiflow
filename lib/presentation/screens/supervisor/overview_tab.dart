import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/providers/supervisor_provider.dart';
import 'package:tenken_engiflow/presentation/screens/supervisor/team_tab.dart';

const _kOrange = Color(0xFFF57C00);
const _kSlate = Color(0xFF37474F);

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sv = context.watch<SupervisorProvider>();
    final userData = auth.userData;
    final name = userData?['displayName'] as String? ?? '—';
    final dept = userData?['department'] as String? ?? '';
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return RefreshIndicator(
      onRefresh: () async {
        sv.loadTeamMembers(department: dept);
        sv.loadPendingTasks();
        sv.loadAttendanceRecords(DateTime.now());
        sv.loadDepartmentIssues(dept);
        sv.loadPendingWorkEntries();
        await sv.loadRecentActivity(dept);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeBanner(greeting: greeting, name: name, dept: dept),
            const SizedBox(height: 20),
            _StatsGrid(sv: sv),
            const SizedBox(height: 20),
            _QuickActions(sv: sv),
            const SizedBox(height: 20),
            _ActivityFeed(sv: sv),
          ],
        ),
      ),
    );
  }
}

// ── Welcome banner ────────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  final String greeting;
  final String name;
  final String dept;

  const _WelcomeBanner({
    required this.greeting,
    required this.name,
    required this.dept,
  });

  @override
  Widget build(BuildContext context) {
    final first = name.split(' ').first;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kOrange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.supervisor_account,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $first',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                if (dept.isNotEmpty)
                  Text(
                    dept,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats grid ────────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  final SupervisorProvider sv;
  const _StatsGrid({required this.sv});

  @override
  Widget build(BuildContext context) {
    final attendancePct = sv.teamMembers.isEmpty
        ? '—'
        : '${sv.attendanceRateToday.toStringAsFixed(0)}%';
    final pendingCount = sv.pendingTasks.length + sv.pendingWorkEntries.length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        _StatCard(
          title: 'Team Members',
          value: '${sv.teamMembers.length}',
          sub: 'Engineers',
          icon: Icons.group,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Pending Reviews',
          value: '$pendingCount',
          sub: 'Need action',
          icon: Icons.pending_actions,
          color: _kOrange,
        ),
        _StatCard(
          title: 'Attendance',
          value: attendancePct,
          sub: 'Present today',
          icon: Icons.calendar_today,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Open Issues',
          value: '${sv.openIssues.length}',
          sub: 'Unresolved',
          icon: Icons.warning_amber,
          color: Colors.red,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: _kSlate,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kSlate,
            ),
          ),
          Text(
            sub,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final SupervisorProvider sv;
  const _QuickActions({required this.sv});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ACTIONS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.add_task,
                label: 'Assign Task',
                color: _kOrange,
                onTap: () => showAssignTaskDialog(context, sv),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.refresh,
                label: 'Refresh',
                color: _kSlate,
                onTap: () {
                  final dept = context
                          .read<AuthProvider>()
                          .userData?['department'] as String? ??
                      '';
                  sv.loadTeamMembers(department: dept);
                  sv.loadPendingTasks();
                  sv.loadAttendanceRecords(DateTime.now());
                  sv.loadDepartmentIssues(dept);
                  sv.loadPendingWorkEntries();
                  sv.loadRecentActivity(dept);
                },
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity feed ─────────────────────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  final SupervisorProvider sv;
  const _ActivityFeed({required this.sv});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT ACTIVITY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: sv.recentActivity.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No recent activity',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              : Column(
                  children: sv.recentActivity.asMap().entries.map((entry) {
                    final isLast =
                        entry.key == sv.recentActivity.length - 1;
                    return Column(
                      children: [
                        _ActivityItem(data: entry.value),
                        if (!isLast) const Divider(height: 1, indent: 52),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ActivityItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = _color(data['color'] as String? ?? '');
    final icon = _icon(data['icon'] as String? ?? '');
    final timeStr = _formatTime(data['time'] as String? ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              data['title'] as String? ?? '',
              style: const TextStyle(fontSize: 13, color: _kSlate),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  static Color _color(String c) {
    switch (c) {
      case 'orange':
        return _kOrange;
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  static IconData _icon(String s) {
    switch (s) {
      case 'task':
        return Icons.assignment_turned_in;
      case 'check':
        return Icons.check_circle;
      case 'schedule':
        return Icons.schedule;
      case 'warning':
        return Icons.warning_amber;
      default:
        return Icons.info_outline;
    }
  }

  static String _formatTime(String iso) {
    if (iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}
