import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/data/models/issue_model.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';

const _kGreen = Color(0xFF388E3C);
const _kSlate = Color(0xFF37474F);

class AdminIssuesTab extends StatefulWidget {
  const AdminIssuesTab({super.key});

  @override
  State<AdminIssuesTab> createState() => _AdminIssuesTabState();
}

class _AdminIssuesTabState extends State<AdminIssuesTab> {
  String _statusFilter = 'all';
  String _severityFilter = 'all';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<IssueModel> _applySearch(List<IssueModel> issues) {
    if (_searchQuery.isEmpty) return issues;
    final q = _searchQuery.toLowerCase();
    return issues.where((i) {
      return i.title.toLowerCase().contains(q) ||
          i.description.toLowerCase().contains(q) ||
          i.reporterName.toLowerCase().contains(q) ||
          i.department.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final issues = _applySearch(admin.filteredIssues);

    return Column(
      children: [
        // Search bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search issues…',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Filters
        _FilterRow(
          statusFilter: _statusFilter,
          severityFilter: _severityFilter,
          onStatusChanged: (s) {
            setState(() => _statusFilter = s);
            admin.filterIssues(status: s, severity: _severityFilter);
          },
          onSeverityChanged: (s) {
            setState(() => _severityFilter = s);
            admin.filterIssues(status: _statusFilter, severity: s);
          },
        ),

        // Count + refresh
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                '${issues.length} issue${issues.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => admin.loadAllIssues(),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Issue list
        Expanded(
          child: admin.isLoading
              ? const Center(child: CircularProgressIndicator())
              : issues.isEmpty
                  ? const _EmptyState(
                      icon: Icons.check_circle_outline,
                      message: 'No issues match your filters',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                      itemCount: issues.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) =>
                          _AdminIssueCard(issue: issues[i]),
                    ),
        ),
      ],
    );
  }
}

// ── Filter row ────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String statusFilter;
  final String severityFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSeverityChanged;

  const _FilterRow({
    required this.statusFilter,
    required this.severityFilter,
    required this.onStatusChanged,
    required this.onSeverityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                for (final s in [
                  ('all', 'All'),
                  ('open', 'Open'),
                  ('in_progress', 'In Progress'),
                  ('resolved', 'Resolved'),
                  ('closed', 'Closed'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s.$2, style: const TextStyle(fontSize: 12)),
                      selected: statusFilter == s.$1,
                      onSelected: (_) => onStatusChanged(s.$1),
                      selectedColor: _kGreen.withValues(alpha: 0.15),
                      checkmarkColor: _kGreen,
                      side: BorderSide(
                        color: statusFilter == s.$1
                            ? _kGreen
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Severity
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'Severity:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                for (final s in [
                  ('all', 'All', Colors.grey),
                  ('critical', 'Critical', Colors.purple),
                  ('high', 'High', Colors.red),
                  ('medium', 'Medium', Colors.orange),
                  ('low', 'Low', Colors.green),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(s.$2, style: const TextStyle(fontSize: 11)),
                      selected: severityFilter == s.$1,
                      onSelected: (_) => onSeverityChanged(s.$1),
                      selectedColor: s.$3.withValues(alpha: 0.15),
                      checkmarkColor: s.$3,
                      side: BorderSide(
                        color: severityFilter == s.$1
                            ? s.$3
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

// ── Issue card ────────────────────────────────────────────────────────────────

class _AdminIssueCard extends StatelessWidget {
  final IssueModel issue;
  const _AdminIssueCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();
    final sevColor = _severityColor(issue.severity);
    final statColor = _statusColor(issue.status);
    final isResolved =
        issue.status == 'resolved' || issue.status == 'closed';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (!isResolved && issue.severity == 'critical')
              ? Colors.purple.withValues(alpha: 0.4)
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges row
          Row(
            children: [
              _SevBadge(severity: issue.severity, color: sevColor),
              const SizedBox(width: 6),
              _StatusBadge(status: issue.status, color: statColor),
              const Spacer(),
              _IssueMenu(issue: issue, admin: admin),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            issue.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _kSlate,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            issue.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Meta
          Row(
            children: [
              Icon(Icons.person_outline, size: 13, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                issue.reporterName,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 12),
              Icon(Icons.apartment_outlined, size: 13, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                issue.department,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 12),
              Icon(Icons.category_outlined, size: 13, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  issue.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _formatAge(issue.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  static Color _severityColor(String s) {
    switch (s) {
      case 'critical':
        return Colors.purple;
      case 'high':
        return Colors.red[700]!;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  static Color _statusColor(String s) {
    switch (s) {
      case 'open':
        return Colors.red;
      case 'in_progress':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static String _formatAge(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return '1 day ago';
    return '${diff.inDays} days ago';
  }
}

class _SevBadge extends StatelessWidget {
  final String severity;
  final Color color;
  const _SevBadge({required this.severity, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.replaceAll('_', ' '),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _IssueMenu extends StatelessWidget {
  final IssueModel issue;
  final AdminProvider admin;
  const _IssueMenu({required this.issue, required this.admin});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
      itemBuilder: (_) => [
        for (final s in [
          ('open', 'Mark Open'),
          ('in_progress', 'Mark In Progress'),
          ('resolved', 'Mark Resolved'),
          ('closed', 'Close Issue'),
        ])
          PopupMenuItem(value: s.$1, child: Text(s.$2)),
      ],
      onSelected: (status) async {
        final messenger = ScaffoldMessenger.of(context);
        final ok = await admin.updateAdminIssueStatus(issue.id, status);
        if (ok) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Issue marked as $status'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
