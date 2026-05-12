import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/data/models/issue_model.dart';
import 'package:tenken_engiflow/data/models/work_entry_model.dart';
import 'package:tenken_engiflow/presentation/providers/supervisor_provider.dart';
import 'package:tenken_engiflow/presentation/components/task_approval_card.dart';

const _kOrange = Color(0xFFF57C00);
const _kSlate = Color(0xFF37474F);

class ApprovalsTab extends StatelessWidget {
  const ApprovalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final sv = context.watch<SupervisorProvider>();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: _kOrange,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: _kOrange,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Tasks'),
                      if (sv.pendingTasks.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _Badge(count: sv.pendingTasks.length),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Work Entries'),
                      if (sv.pendingWorkEntries.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _Badge(count: sv.pendingWorkEntries.length),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Issues'),
                      if (sv.openIssues.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        _Badge(count: sv.openIssues.length),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab views
          const Expanded(
            child: TabBarView(
              children: [
                _TasksView(),
                _WorkEntriesView(),
                _IssuesView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final int count;
  const _Badge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _kOrange,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Tasks view ────────────────────────────────────────────────────────────────

class _TasksView extends StatelessWidget {
  const _TasksView();

  @override
  Widget build(BuildContext context) {
    final sv = context.watch<SupervisorProvider>();

    if (sv.pendingTasks.isEmpty) {
      return const _EmptyState(
        icon: Icons.check_circle_outline,
        message: 'No tasks pending review',
        color: Colors.green,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: sv.pendingTasks.length,
      itemBuilder: (context, i) {
        final task = sv.pendingTasks[i];
        return TaskApprovalCard(
          task: task,
          onApprove: (comments) => sv.approveTask(task.id, comments),
          onReject: (reason) => sv.rejectTask(task.id, reason),
        );
      },
    );
  }
}

// ── Work entries view ─────────────────────────────────────────────────────────

class _WorkEntriesView extends StatelessWidget {
  const _WorkEntriesView();

  @override
  Widget build(BuildContext context) {
    final sv = context.watch<SupervisorProvider>();

    if (sv.pendingWorkEntries.isEmpty) {
      return const _EmptyState(
        icon: Icons.description_outlined,
        message: 'No work entries pending review',
        color: Colors.blue,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: sv.pendingWorkEntries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) =>
          _WorkEntryCard(entry: sv.pendingWorkEntries[i]),
    );
  }
}

class _WorkEntryCard extends StatefulWidget {
  final WorkEntry entry;
  const _WorkEntryCard({required this.entry});

  @override
  State<_WorkEntryCard> createState() => _WorkEntryCardState();
}

class _WorkEntryCardState extends State<_WorkEntryCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final sv = context.read<SupervisorProvider>();
    final e = widget.entry;

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
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description, color: Colors.blue, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.engineerName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kSlate,
                      ),
                    ),
                    Text(
                      e.date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${e.hoursWorked.toStringAsFixed(1)}h',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Description
          Text(
            e.description,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (e.taskTitle != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.link, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  e.taskTitle!,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Return'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await sv.rejectWorkEntry(e.id);
                          if (mounted) setState(() => _loading = false);
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  icon: _loading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check, size: 16),
                  label: const Text('Approve'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          final messenger = ScaffoldMessenger.of(context);
                          final ok = await sv.approveWorkEntry(e.id);
                          if (!mounted) return;
                          setState(() => _loading = false);
                          if (ok) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Work entry approved'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Issues view ───────────────────────────────────────────────────────────────

class _IssuesView extends StatelessWidget {
  const _IssuesView();

  @override
  Widget build(BuildContext context) {
    final sv = context.watch<SupervisorProvider>();
    final issues = sv.departmentIssues;

    if (issues.isEmpty) {
      return const _EmptyState(
        icon: Icons.check_circle_outline,
        message: 'No issues reported',
        color: Colors.green,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      itemCount: issues.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _IssueCard(issue: issues[i]),
    );
  }
}

class _IssueCard extends StatefulWidget {
  final IssueModel issue;
  const _IssueCard({required this.issue});

  @override
  State<_IssueCard> createState() => _IssueCardState();
}

class _IssueCardState extends State<_IssueCard> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final issue = widget.issue;
    final sv = context.read<SupervisorProvider>();
    final severityColor = _severityColor(issue.severity);
    final statusColor = _statusColor(issue.status);
    final isResolved = issue.status == 'resolved' || issue.status == 'closed';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isResolved
              ? const Color(0xFFEEEEEE)
              : severityColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              _SeverityChip(severity: issue.severity),
              const SizedBox(width: 8),
              _StatusChip(status: issue.status, color: statusColor),
              const Spacer(),
              Text(
                _formatDate(issue.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[400]),
              ),
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
          ),
          const SizedBox(height: 4),
          Text(
            issue.description,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.person_outline, size: 13, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                issue.reporterName,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 12),
              Icon(Icons.category_outlined, size: 13, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                issue.category,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),

          if (!isResolved) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (issue.status == 'open')
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.person_add, size: 15),
                      label: const Text('Assign'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _kOrange,
                        side: BorderSide(
                            color: _kOrange.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: _loading
                          ? null
                          : () => _showAssign(context, sv, issue),
                    ),
                  ),
                if (issue.status == 'open') const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    icon: _loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.done_all, size: 15),
                    label: const Text('Resolve'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: _loading
                        ? null
                        : () async {
                            setState(() => _loading = true);
                            final messenger = ScaffoldMessenger.of(context);
                            final ok = await sv.updateIssueStatus(
                              issue.id,
                              'resolved',
                            );
                            if (!mounted) return;
                            setState(() => _loading = false);
                            if (ok) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Issue resolved'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showAssign(
    BuildContext context,
    SupervisorProvider sv,
    IssueModel issue,
  ) {
    showDialog(
      context: context,
      builder: (_) => _AssignIssueDialog(sv: sv, issue: issue),
    );
  }

  static Color _severityColor(String s) {
    switch (s) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red[700]!;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  static Color _statusColor(String s) {
    switch (s) {
      case 'open':
        return Colors.red;
      case 'in_progress':
        return _kOrange;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  static String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }
}

class _SeverityChip extends StatelessWidget {
  final String severity;
  const _SeverityChip({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = _color(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        severity.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  static Color _color(String s) {
    switch (s) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red[700]!;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    final label = status.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _AssignIssueDialog extends StatefulWidget {
  final SupervisorProvider sv;
  final IssueModel issue;
  const _AssignIssueDialog({required this.sv, required this.issue});

  @override
  State<_AssignIssueDialog> createState() => _AssignIssueDialogState();
}

class _AssignIssueDialogState extends State<_AssignIssueDialog> {
  String _selectedMemberId = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.sv.teamMembers.isNotEmpty) {
      _selectedMemberId =
          widget.sv.teamMembers.first['id'] as String? ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final members = widget.sv.teamMembers;

    return AlertDialog(
      title: const Text('Assign Issue'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.issue.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (members.isEmpty)
            const Text('No team members available')
          else
            DropdownButtonFormField<String>(
              value: _selectedMemberId.isEmpty ? null : _selectedMemberId,
              decoration: const InputDecoration(labelText: 'Assign To'),
              items: members.map((m) {
                return DropdownMenuItem(
                  value: m['id'] as String? ?? '',
                  child:
                      Text(m['displayName'] as String? ?? m['id'] as String),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedMemberId = v ?? ''),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _kOrange),
          onPressed: (_saving || _selectedMemberId.isEmpty) ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Assign'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await widget.sv.updateIssueStatus(
      widget.issue.id,
      'in_progress',
      assignedTo: _selectedMemberId,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      nav.pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Issue assigned'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: color.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
