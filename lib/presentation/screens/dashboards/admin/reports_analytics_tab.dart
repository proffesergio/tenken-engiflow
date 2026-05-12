import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';

const _kGreen = Color(0xFF388E3C);
const _kSlate = Color(0xFF37474F);

class ReportsAnalyticsTab extends StatefulWidget {
  const ReportsAnalyticsTab({super.key});

  @override
  State<ReportsAnalyticsTab> createState() => _ReportsAnalyticsTabState();
}

class _ReportsAnalyticsTabState extends State<ReportsAnalyticsTab> {
  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _UserRoleChart(admin: admin),
          const SizedBox(height: 20),
          _TaskStatusChart(admin: admin),
          const SizedBox(height: 20),
          _IssueSeverityChart(admin: admin),
          const SizedBox(height: 20),
          _DepartmentBreakdown(admin: admin),
          const SizedBox(height: 20),
          const _ExportSection(),
        ],
      ),
    );
  }
}

// ── User role chart ───────────────────────────────────────────────────────────

class _UserRoleChart extends StatelessWidget {
  final AdminProvider admin;
  const _UserRoleChart({required this.admin});

  @override
  Widget build(BuildContext context) {
    final total = admin.totalUsers;
    if (total == 0) {
      return const _ChartCard(
        title: 'User Distribution',
        child: _NoData(),
      );
    }

    final bars = [
      _BarData(
        label: 'Engineers',
        count: admin.totalEngineers,
        total: total,
        color: Colors.orange,
      ),
      _BarData(
        label: 'Supervisors',
        count: admin.totalSupervisors,
        total: total,
        color: Colors.purple,
      ),
      _BarData(
        label: 'Admins',
        count: admin.totalAdmins,
        total: total,
        color: _kGreen,
      ),
    ];

    return _ChartCard(
      title: 'User Distribution',
      subtitle: '$total total users',
      child: _HorizontalBarChart(bars: bars),
    );
  }
}

// ── Task status chart ─────────────────────────────────────────────────────────

class _TaskStatusChart extends StatelessWidget {
  final AdminProvider admin;
  const _TaskStatusChart({required this.admin});

  @override
  Widget build(BuildContext context) {
    final stats = admin.taskStats;
    final total = admin.allTasks.length;

    if (total == 0) {
      return const _ChartCard(
        title: 'Task Status Distribution',
        child: _NoData(),
      );
    }

    final bars = [
      _BarData(
        label: 'Pending',
        count: stats['pending'] ?? 0,
        total: total,
        color: Colors.grey,
      ),
      _BarData(
        label: 'In Progress',
        count: stats['in_progress'] ?? 0,
        total: total,
        color: Colors.blue,
      ),
      _BarData(
        label: 'Under Review',
        count: stats['pending_review'] ?? 0,
        total: total,
        color: Colors.orange,
      ),
      _BarData(
        label: 'Approved',
        count: stats['approved'] ?? 0,
        total: total,
        color: Colors.green,
      ),
      _BarData(
        label: 'Rejected',
        count: stats['rejected'] ?? 0,
        total: total,
        color: Colors.red,
      ),
    ];

    final completionRate = total == 0
        ? 0.0
        : ((stats['approved'] ?? 0) / total) * 100;

    return _ChartCard(
      title: 'Task Status Distribution',
      subtitle:
          '$total tasks — ${completionRate.toStringAsFixed(0)}% approved',
      child: _HorizontalBarChart(bars: bars),
    );
  }
}

// ── Issue severity chart ──────────────────────────────────────────────────────

class _IssueSeverityChart extends StatelessWidget {
  final AdminProvider admin;
  const _IssueSeverityChart({required this.admin});

  @override
  Widget build(BuildContext context) {
    final stats = admin.issueStats;
    final total = admin.allIssues.length;

    if (total == 0) {
      return const _ChartCard(
        title: 'Issue Overview',
        child: _NoData(),
      );
    }

    final openCount = (stats['open'] ?? 0) + (stats['in_progress'] ?? 0);

    return _ChartCard(
      title: 'Issue Overview',
      subtitle: '$total total — $openCount open',
      child: Column(
        children: [
          // Status breakdown
          const _SubLabel('By Status'),
          const SizedBox(height: 8),
          _HorizontalBarChart(
            bars: [
              _BarData(
                  label: 'Open',
                  count: stats['open'] ?? 0,
                  total: total,
                  color: Colors.red),
              _BarData(
                  label: 'In Progress',
                  count: stats['in_progress'] ?? 0,
                  total: total,
                  color: Colors.orange),
              _BarData(
                  label: 'Resolved',
                  count: stats['resolved'] ?? 0,
                  total: total,
                  color: Colors.green),
              _BarData(
                  label: 'Closed',
                  count: stats['closed'] ?? 0,
                  total: total,
                  color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          // Severity breakdown
          const _SubLabel('By Severity'),
          const SizedBox(height: 8),
          _HorizontalBarChart(
            bars: [
              _BarData(
                  label: 'Critical',
                  count: stats['critical'] ?? 0,
                  total: total,
                  color: Colors.purple),
              _BarData(
                  label: 'High',
                  count: stats['high'] ?? 0,
                  total: total,
                  color: Colors.red),
              _BarData(
                  label: 'Medium',
                  count: stats['medium'] ?? 0,
                  total: total,
                  color: Colors.orange),
              _BarData(
                  label: 'Low',
                  count: stats['low'] ?? 0,
                  total: total,
                  color: Colors.green),
            ],
          ),
          if ((stats['critical'] ?? 0) > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '${stats['critical']} critical issue${stats['critical']! > 1 ? 's' : ''} require immediate attention',
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

// ── Department breakdown ──────────────────────────────────────────────────────

class _DepartmentBreakdown extends StatelessWidget {
  final AdminProvider admin;
  const _DepartmentBreakdown({required this.admin});

  @override
  Widget build(BuildContext context) {
    final users = admin.allUsers;
    if (users.isEmpty) {
      return const _ChartCard(
        title: 'Department Breakdown',
        child: _NoData(),
      );
    }

    // Group engineers by department
    final Map<String, int> deptCount = {};
    for (final u in users) {
      if (u.isEngineer) {
        deptCount[u.department] = (deptCount[u.department] ?? 0) + 1;
      }
    }

    if (deptCount.isEmpty) {
      return const _ChartCard(
        title: 'Department Breakdown',
        child: _NoData(),
      );
    }

    final total = deptCount.values.fold(0, (a, b) => a + b);
    final colors = [
      Colors.blue, Colors.orange, Colors.green,
      Colors.purple, Colors.teal, Colors.red,
    ];

    final bars = deptCount.entries.toList().asMap().entries.map((e) {
      return _BarData(
        label: e.value.key,
        count: e.value.value,
        total: total,
        color: colors[e.key % colors.length],
      );
    }).toList();

    bars.sort((a, b) => b.count.compareTo(a.count));

    return _ChartCard(
      title: 'Department Breakdown',
      subtitle: 'Engineers by department',
      child: _HorizontalBarChart(bars: bars),
    );
  }
}

// ── Export section ────────────────────────────────────────────────────────────

class _ExportSection extends StatelessWidget {
  const _ExportSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('EXPORT'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.picture_as_pdf, size: 18),
                label: const Text('PDF Report'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PDF export — coming in Step 6'),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.table_chart, size: 18),
                label: const Text('CSV Export'),
                style: FilledButton.styleFrom(
                  backgroundColor: _kGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CSV export — coming in Step 6'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Reusable chart widgets ────────────────────────────────────────────────────

class _BarData {
  final String label;
  final int count;
  final int total;
  final Color color;
  const _BarData({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });
  double get fraction => total == 0 ? 0 : count / total;
  String get pct => '${(fraction * 100).toStringAsFixed(0)}%';
}

class _HorizontalBarChart extends StatelessWidget {
  final List<_BarData> bars;
  const _HorizontalBarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: bars.map((b) => _BarRow(data: b)).toList(),
    );
  }
}

class _BarRow extends StatelessWidget {
  final _BarData data;
  const _BarRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              data.label,
              style: const TextStyle(fontSize: 12, color: _kSlate),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: data.fraction,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(data.color),
                minHeight: 10,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              data.pct,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: data.color,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 24,
            child: Text(
              '${data.count}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    this.subtitle,
    required this.child,
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _kSlate,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SubLabel extends StatelessWidget {
  final String text;
  const _SubLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
        ),
      ),
    );
  }
}

class _NoData extends StatelessWidget {
  const _NoData();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'No data yet',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

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
