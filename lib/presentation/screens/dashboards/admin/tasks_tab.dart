import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/data/models/task_model.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';

const _kGreen = Color(0xFF388E3C);
const _kSlate = Color(0xFF37474F);

class AdminTasksTab extends StatefulWidget {
  const AdminTasksTab({super.key});

  @override
  State<AdminTasksTab> createState() => _AdminTasksTabState();
}

class _AdminTasksTabState extends State<AdminTasksTab> {
  String _statusFilter = 'all';
  String _priorityFilter = 'all';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Task> _applySearch(List<Task> tasks) {
    if (_searchQuery.isEmpty) return tasks;
    final q = _searchQuery.toLowerCase();
    return tasks.where((t) {
      return t.title.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          (t.department?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final tasks = _applySearch(admin.filteredTasks);

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
              hintText: 'Search tasks…',
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

        // Filter chips
        _FilterRow(
          statusFilter: _statusFilter,
          priorityFilter: _priorityFilter,
          onStatusChanged: (s) {
            setState(() => _statusFilter = s);
            admin.filterTasks(
              status: s,
              priority: _priorityFilter,
            );
          },
          onPriorityChanged: (p) {
            setState(() => _priorityFilter = p);
            admin.filterTasks(
              status: _statusFilter,
              priority: p,
            );
          },
        ),

        // Count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              Text(
                '${tasks.length} task${tasks.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => admin.loadAllTasks(),
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        // Task list
        Expanded(
          child: admin.isLoading
              ? const Center(child: CircularProgressIndicator())
              : tasks.isEmpty
                  ? const _EmptyState(
                      icon: Icons.assignment_outlined,
                      message: 'No tasks match your filters',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) =>
                          _AdminTaskCard(task: tasks[i]),
                    ),
        ),
      ],
    );
  }
}

// ── Filter row ────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final String statusFilter;
  final String priorityFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;

  const _FilterRow({
    required this.statusFilter,
    required this.priorityFilter,
    required this.onStatusChanged,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Status filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                for (final s in [
                  ('all', 'All'),
                  ('pending', 'Pending'),
                  ('in_progress', 'In Progress'),
                  ('pending_review', 'Under Review'),
                  ('approved', 'Approved'),
                  ('rejected', 'Rejected'),
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
          // Priority filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text(
                    'Priority:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                for (final p in [
                  ('all', 'All', Colors.grey),
                  ('low', 'Low', Colors.green),
                  ('medium', 'Medium', Colors.orange),
                  ('high', 'High', Colors.red),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(p.$2, style: const TextStyle(fontSize: 11)),
                      selected: priorityFilter == p.$1,
                      onSelected: (_) => onPriorityChanged(p.$1),
                      selectedColor: p.$3.withValues(alpha: 0.15),
                      checkmarkColor: p.$3,
                      side: BorderSide(
                        color: priorityFilter == p.$1
                            ? p.$3
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

// ── Task card ─────────────────────────────────────────────────────────────────

class _AdminTaskCard extends StatelessWidget {
  final Task task;
  const _AdminTaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final admin = context.read<AdminProvider>();
    final priorityColor = _priorityColor(task.priority);
    final statusColor = _statusColor(task.status);
    final isOverdue = task.dueDate.isBefore(DateTime.now()) &&
        task.status != 'approved' &&
        task.status != 'rejected';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOverdue
              ? Colors.red.withValues(alpha: 0.4)
              : const Color(0xFFEEEEEE),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badges
          Row(
            children: [
              _Chip(
                label: task.priority.toUpperCase(),
                color: priorityColor,
              ),
              const SizedBox(width: 6),
              _Chip(
                label: _statusLabel(task.status),
                color: statusColor,
              ),
              if (isOverdue) ...[
                const SizedBox(width: 6),
                const _Chip(label: 'OVERDUE', color: Colors.red),
              ],
              const Spacer(),
              // Status change menu
              _StatusMenu(task: task, admin: admin),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
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
            task.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Meta row
          Row(
            children: [
              Icon(Icons.apartment_outlined, size: 13, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                task.department ?? '—',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 12),
              Icon(Icons.calendar_today_outlined,
                  size: 13,
                  color: isOverdue ? Colors.red : Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                _formatDate(task.dueDate),
                style: TextStyle(
                  fontSize: 12,
                  color: isOverdue ? Colors.red : Colors.grey[500],
                  fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _priorityColor(String p) {
    switch (p) {
      case 'high':
        return Colors.red;
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
      case 'pending':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'pending_review':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static String _statusLabel(String s) {
    switch (s) {
      case 'pending_review':
        return 'REVIEW';
      case 'in_progress':
        return 'IN PROG.';
      default:
        return s.toUpperCase();
    }
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}

class _StatusMenu extends StatelessWidget {
  final Task task;
  final AdminProvider admin;
  const _StatusMenu({required this.task, required this.admin});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 18, color: Colors.grey),
      itemBuilder: (_) => [
        for (final s in [
          ('pending', 'Set Pending'),
          ('in_progress', 'Set In Progress'),
          ('approved', 'Approve'),
          ('rejected', 'Reject'),
        ])
          PopupMenuItem(
            value: s.$1,
            child: Text(s.$2),
          ),
      ],
      onSelected: (status) async {
        final messenger = ScaffoldMessenger.of(context);
        final ok = await admin.updateAdminTaskStatus(task.id, status);
        if (ok) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Task status updated to $status'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

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
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
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
