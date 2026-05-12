import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/data/models/task_model.dart';
import 'package:tenken_engiflow/presentation/providers/task_provider.dart';

const _kSlate = Color(0xFF37474F);

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _noteController = TextEditingController();
  bool _isActing = false;
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Task Detail',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _kSlate,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE0E0E0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(task: _task),
            const SizedBox(height: 16),
            _InfoCard(task: _task),
            const SizedBox(height: 16),
            _StatusTimeline(status: _task.status),
            if (_task.status == 'rejected') ...[
              const SizedBox(height: 16),
              _RejectionCard(task: _task),
            ],
            if (_canAct) ...[
              const SizedBox(height: 16),
              _ActionCard(
                task: _task,
                noteController: _noteController,
                isActing: _isActing,
                onStart: _startTask,
                onSubmit: _submitTask,
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool get _canAct =>
      _task.status == 'pending' ||
      _task.status == 'in_progress' ||
      _task.status == 'rejected';

  Future<void> _startTask() async {
    setState(() => _isActing = true);
    final ok = await context.read<TaskProvider>().startTask(_task.id);
    if (!mounted) return;
    setState(() {
      _isActing = false;
      if (ok) _task = _copyWithStatus(_task, 'in_progress');
    });
    _showSnackBar(ok, ok ? 'Task started' : context.read<TaskProvider>().error);
  }

  Future<void> _submitTask() async {
    if (_noteController.text.trim().isEmpty) {
      _showSnackBar(false, 'Please add a completion note');
      return;
    }
    setState(() => _isActing = true);
    final ok = await context
        .read<TaskProvider>()
        .submitTask(_task.id, _noteController.text.trim());
    if (!mounted) return;
    setState(() {
      _isActing = false;
      if (ok) _task = _copyWithStatus(_task, 'pending_review');
    });
    _showSnackBar(ok, ok ? 'Task submitted for review' : context.read<TaskProvider>().error);
  }

  void _showSnackBar(bool success, String? message) {
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: success ? Colors.green : Colors.red,
    ));
  }

  static Task _copyWithStatus(Task t, String status) => Task(
    id: t.id,
    title: t.title,
    description: t.description,
    assignedTo: t.assignedTo,
    assignedBy: t.assignedBy,
    priority: t.priority,
    status: status,
    dueDate: t.dueDate,
    createdAt: t.createdAt,
    department: t.department,
    attachments: t.attachments,
    comments: t.comments,
  );
}

// ── Header card ─────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final Task task;
  const _HeaderCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) &&
        task.status != 'approved' && task.status != 'rejected';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
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
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _kSlate,
              ),
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Info card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Task task;
  const _InfoCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final due = task.dueDate;
    final dueFmt = '${due.day} ${months[due.month-1]} ${due.year}';
    final created = task.createdAt;
    final createdFmt = '${created.day} ${months[created.month-1]} ${created.year}';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Due Date',
              value: dueFmt,
              valueColor: task.dueDate.isBefore(DateTime.now()) &&
                      task.status != 'approved' ? Colors.red : _kSlate,
            ),
            const Divider(height: 20),
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Assigned By',
              value: task.assignedBy,
            ),
            if (task.department != null) ...[
              const Divider(height: 20),
              _InfoRow(
                icon: Icons.apartment_outlined,
                label: 'Department',
                value: task.department!,
              ),
            ],
            const Divider(height: 20),
            _InfoRow(
              icon: Icons.access_time_outlined,
              label: 'Created',
              value: createdFmt,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: valueColor ?? _kSlate,
          ),
        ),
      ],
    );
  }
}

// ── Status timeline ──────────────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  final String status;
  const _StatusTimeline({required this.status});

  static const _steps = [
    ('Assigned', 'pending'),
    ('In Progress', 'in_progress'),
    ('Submitted', 'pending_review'),
    ('Approved', 'approved'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: _kSlate,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: _steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final (label, stepStatus) = entry.value;
                final isDone = _isDone(stepStatus);
                final isActive = status == stepStatus;

                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDone || isActive
                                    ? (status == 'rejected' && stepStatus == 'pending_review'
                                        ? Colors.red
                                        : isDone || isActive ? Colors.green : Colors.grey[200])
                                    : Colors.grey[200],
                                border: isActive
                                    ? Border.all(color: Colors.green, width: 2)
                                    : null,
                              ),
                              child: Icon(
                                isDone || isActive ? Icons.check : Icons.circle,
                                size: 14,
                                color: isDone || isActive ? Colors.white : Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isDone || isActive
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: isDone || isActive
                                    ? _kSlate
                                    : Colors.grey[400],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (idx < _steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 22),
                            color: _isDone(_steps[idx + 1].$2) || isDone
                                ? Colors.green
                                : Colors.grey[200],
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDone(String stepStatus) {
    const order = ['pending', 'in_progress', 'pending_review', 'approved'];
    final myIdx = order.indexOf(status);
    final stepIdx = order.indexOf(stepStatus);
    return stepIdx <= myIdx;
  }
}

// ── Rejection card ───────────────────────────────────────────────────────────

class _RejectionCard extends StatelessWidget {
  final Task task;
  const _RejectionCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, color: Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Rejected',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
                if (task.comments != null && task.comments!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.comments!,
                    style: const TextStyle(fontSize: 13, color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final Task task;
  final TextEditingController noteController;
  final bool isActing;
  final VoidCallback onStart;
  final VoidCallback onSubmit;

  const _ActionCard({
    required this.task,
    required this.noteController,
    required this.isActing,
    required this.onStart,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Status',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: _kSlate,
              ),
            ),
            const SizedBox(height: 14),

            if (task.status == 'pending') ...[
              const Text(
                'Start this task to indicate you\'ve begun work.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isActing ? null : onStart,
                  icon: isActing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Start Task'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],

            if (task.status == 'in_progress' || task.status == 'rejected') ...[
              const Text(
                'Describe what you completed before submitting for review.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Completion notes…',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: const Color(0xFFF5F7F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isActing ? null : onSubmit,
                  icon: isActing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.upload_rounded, size: 20),
                  label: Text(
                    task.status == 'rejected' ? 'Resubmit' : 'Submit for Review',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _kSlate,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shared badges ────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$label Priority',
        style: TextStyle(
          fontSize: 12,
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
      'pending_review' => ('Awaiting Review', Colors.orange),
      'approved' => ('Approved', Colors.green),
      'rejected' => ('Rejected', Colors.red),
      _ => (status, Colors.grey),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _OverdueBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
