import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';

const _kGreen = Color(0xFF388E3C);
const _kSlate = Color(0xFF37474F);

class AdminOverviewTab extends StatelessWidget {
  const AdminOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();
    final name = auth.userData?['displayName'] as String? ?? 'Admin';
    final first = name.split(' ').first;

    return RefreshIndicator(
      onRefresh: () async {
        admin.loadAllUsers();
        admin.loadAllTasks();
        admin.loadAllIssues();
        await admin.loadRecentActivity();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeBanner(name: first),
            const SizedBox(height: 20),
            _SystemStats(admin: admin),
            const SizedBox(height: 20),
            _OperationsGrid(admin: admin),
            const SizedBox(height: 20),
            const _SystemStatus(),
            const SizedBox(height: 20),
            _ActivityFeed(admin: admin),
          ],
        ),
      ),
    );
  }
}

// ── Welcome banner ────────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  final String name;
  const _WelcomeBanner({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kGreen,
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
              Icons.admin_panel_settings,
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
                  'Welcome, $name',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'System Administrator',
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

// ── System stats (users) ──────────────────────────────────────────────────────

class _SystemStats extends StatelessWidget {
  final AdminProvider admin;
  const _SystemStats({required this.admin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('USER OVERVIEW'),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _StatCard(
              label: 'Total Users',
              value: admin.totalUsers,
              icon: Icons.people,
              color: Colors.blue,
            ),
            _StatCard(
              label: 'Engineers',
              value: admin.totalEngineers,
              icon: Icons.engineering,
              color: Colors.orange,
            ),
            _StatCard(
              label: 'Supervisors',
              value: admin.totalSupervisors,
              icon: Icons.supervisor_account,
              color: Colors.purple,
            ),
            _StatCard(
              label: 'Admins',
              value: admin.totalAdmins,
              icon: Icons.admin_panel_settings,
              color: _kGreen,
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _kSlate,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Operations grid (tasks + issues) ─────────────────────────────────────────

class _OperationsGrid extends StatelessWidget {
  final AdminProvider admin;
  const _OperationsGrid({required this.admin});

  @override
  Widget build(BuildContext context) {
    final taskTotal = admin.allTasks.length;
    final openIssues = (admin.issueStats['open'] ?? 0) +
        (admin.issueStats['in_progress'] ?? 0);
    final pendingReview = admin.taskStats['pending_review'] ?? 0;
    final criticalIssues = admin.issueStats['critical'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('OPERATIONS'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _OpsCard(
                label: 'Total Tasks',
                value: '$taskTotal',
                sub: '$pendingReview pending review',
                icon: Icons.assignment,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _OpsCard(
                label: 'Open Issues',
                value: '$openIssues',
                sub: criticalIssues > 0
                    ? '$criticalIssues critical'
                    : 'No critical',
                icon: Icons.warning_amber,
                color: criticalIssues > 0 ? Colors.red : Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OpsCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;

  const _OpsCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kSlate,
            ),
          ),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

// ── System status ─────────────────────────────────────────────────────────────

class _SystemStatus extends StatelessWidget {
  const _SystemStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'All systems operational',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Activity feed ─────────────────────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  final AdminProvider admin;
  const _ActivityFeed({required this.admin});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('RECENT ACTIVITY'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFEEEEEE)),
          ),
          child: admin.recentActivity.isEmpty
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
                  children: admin.recentActivity.asMap().entries.map((e) {
                    final isLast = e.key == admin.recentActivity.length - 1;
                    return Column(
                      children: [
                        _ActivityItem(data: e.value),
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
    final time = _formatTime(data['time'] as String? ?? '');

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] as String? ?? '',
                  style: const TextStyle(fontSize: 13, color: _kSlate),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((data['sub'] as String? ?? '').isNotEmpty)
                  Text(
                    data['sub'] as String,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
        ],
      ),
    );
  }

  static Color _color(String c) {
    switch (c) {
      case 'blue':
        return Colors.blue;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      case 'green':
        return _kGreen;
      default:
        return Colors.grey;
    }
  }

  static IconData _icon(String s) {
    switch (s) {
      case 'person':
        return Icons.person_add;
      case 'task':
        return Icons.assignment_turned_in;
      case 'warning':
        return Icons.warning_amber;
      default:
        return Icons.info_outline;
    }
  }

  static String _formatTime(String iso) {
    if (iso.isEmpty) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(iso));
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 0.8,
      ),
    );
  }
}
