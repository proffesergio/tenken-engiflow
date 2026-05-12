import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/task_provider.dart';
import 'package:tenken_engiflow/presentation/screens/engineer/task_detail_screen.dart';
import 'package:tenken_engiflow/data/models/task_model.dart';

const _kSlate = Color(0xFF37474F);

class TasksTab extends StatefulWidget {
  const TasksTab({super.key});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  _Filter _activeFilter = _Filter.all;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final tasks = _filteredTasks(provider);

    return Column(
      children: [
        _FilterBar(
          active: _activeFilter,
          counts: {
            _Filter.all: provider.tasks.length,
            _Filter.pending: provider.pendingTasks.length,
            _Filter.inProgress: provider.inProgressTasks.length,
            _Filter.submitted: provider.submittedTasks.length,
            _Filter.done: provider.approvedTasks.length,
          },
          onSelect: (f) => setState(() => _activeFilter = f),
        ),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : tasks.isEmpty
                  ? _EmptyState(filter: _activeFilter)
                  : RefreshIndicator(
                      onRefresh: () {
                        final uid = context
                            .read<TaskProvider>()
                            .tasks
                            .isNotEmpty
                            ? context.read<TaskProvider>().tasks.first.assignedTo
                            : '';
                        return context.read<TaskProvider>().loadMyTasks(uid);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                        itemCount: tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _TaskCard(task: tasks[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  List<Task> _filteredTasks(TaskProvider p) => switch (_activeFilter) {
    _Filter.all => p.tasks,
    _Filter.pending => p.pendingTasks,
    _Filter.inProgress => p.inProgressTasks,
    _Filter.submitted => p.submittedTasks,
    _Filter.done => p.approvedTasks,
  };
}

// ── Filter bar ───────────────────────────────────────────────────────────────

enum _Filter { all, pending, inProgress, submitted, done }

class _FilterBar extends StatelessWidget {
  final _Filter active;
  final Map<_Filter, int> counts;
  final ValueChanged<_Filter> onSelect;

  const _FilterBar({
    required this.active,
    required this.counts,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _Filter.values.map((f) {
            final count = counts[f] ?? 0;
            final isActive = f == active;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive ? _kSlate : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _label(f),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isActive ? Colors.white : Colors.grey[700],
                        ),
                      ),
                      if (count > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isActive ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  static String _label(_Filter f) => switch (f) {
    _Filter.all => 'All',
    _Filter.pending => 'Pending',
    _Filter.inProgress => 'In Progress',
    _Filter.submitted => 'Submitted',
    _Filter.done => 'Done',
  };
}

// ── Task card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final Task task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) &&
        task.status != 'approved' &&
        task.status != 'rejected';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
        ),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isOverdue
                  ? Colors.red.withValues(alpha: 0.4)
                  : const Color(0xFFE8E8E8),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _PriorityBadge(task.priority),
                    const SizedBox(width: 8),
                    _StatusBadge(task.status),
                    if (isOverdue) ...[
                      const SizedBox(width: 8),
                      _OverdueBadge(),
                    ],
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _kSlate,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Due ${_formatDate(task.dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isOverdue ? Colors.red : Colors.grey,
                        fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge(this.priority);

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (priority) {
      'urgent' => ('Urgent', const Color(0xFF7B1FA2)),
      'high' => ('High', Colors.red),
      'medium' => ('Medium', Colors.orange),
      _ => ('Low', Colors.green),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: const Text(
        'Overdue',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.red,
        ),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final _Filter filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final (icon, message) = switch (filter) {
      _Filter.all => (Icons.assignment_outlined, 'No tasks assigned yet'),
      _Filter.pending => (Icons.hourglass_empty_rounded, 'No pending tasks'),
      _Filter.inProgress => (Icons.play_circle_outline, 'No tasks in progress'),
      _Filter.submitted => (Icons.upload_outlined, 'No submitted tasks'),
      _Filter.done => (Icons.check_circle_outline, 'No completed tasks'),
    };
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 15, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
