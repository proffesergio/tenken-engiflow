import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/providers/issue_provider.dart';
import 'package:tenken_engiflow/presentation/providers/task_provider.dart';
import 'package:tenken_engiflow/data/models/issue_model.dart';
import 'package:tenken_engiflow/data/models/work_entry_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _kSlate = Color(0xFF37474F);

// ── Public helpers called from HomeTab quick actions ─────────────────────────

void showWorkEntrySheet(BuildContext context,
    {required Map<String, dynamic>? userData}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WorkEntryForm(userData: userData),
  );
}

void showIssueReportSheet(BuildContext context,
    {required Map<String, dynamic>? userData}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _IssueReportForm(userData: userData),
  );
}

// ── Reports tab ──────────────────────────────────────────────────────────────

class ReportsTab extends StatelessWidget {
  const ReportsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = context.watch<AuthProvider>().userData;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: _kSlate,
              unselectedLabelColor: Colors.grey,
              indicatorColor: _kSlate,
              indicatorWeight: 2.5,
              labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              tabs: [
                Tab(text: 'Work Entries'),
                Tab(text: 'Issues'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _WorkEntriesView(userData: userData),
                _IssuesView(userData: userData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Work entries view ────────────────────────────────────────────────────────

class _WorkEntriesView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const _WorkEntriesView({required this.userData});

  @override
  State<_WorkEntriesView> createState() => _WorkEntriesViewState();
}

class _WorkEntriesViewState extends State<_WorkEntriesView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<WorkEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = widget.userData?['uid'] as String? ?? '';
    if (uid.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('work_entries')
          .where('engineerId', isEqualTo: uid)
          .get();
      final entries = snap.docs
          .map((d) => WorkEntry.fromFirestore(d))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() => _entries = entries);
    } catch (_) {
      // ignore; show empty state
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        _loading
            ? const Center(child: CircularProgressIndicator())
            : _entries.isEmpty
                ? _EmptyState(
                    icon: Icons.edit_note_outlined,
                    message: 'No work entries yet',
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() => _loading = true);
                      await _load();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _WorkEntryCard(entry: _entries[i]),
                    ),
                  ),
        Positioned(
          bottom: 20,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'work_entry_fab',
            backgroundColor: _kSlate,
            foregroundColor: Colors.white,
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _WorkEntryForm(userData: widget.userData),
              );
              // Reload after closing the form
              setState(() => _loading = true);
              await _load();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Entry'),
          ),
        ),
      ],
    );
  }
}

// ── Issues view ──────────────────────────────────────────────────────────────

class _IssuesView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const _IssuesView({required this.userData});

  @override
  State<_IssuesView> createState() => _IssuesViewState();
}

class _IssuesViewState extends State<_IssuesView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final provider = context.watch<IssueProvider>();

    return Stack(
      children: [
        provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.issues.isEmpty
                ? _EmptyState(
                    icon: Icons.report_problem_outlined,
                    message: 'No issues reported',
                  )
                : RefreshIndicator(
                    onRefresh: () {
                      final uid =
                          widget.userData?['uid'] as String? ?? '';
                      return context
                          .read<IssueProvider>()
                          .loadMyIssues(uid);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: provider.issues.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) =>
                          _IssueCard(issue: provider.issues[i]),
                    ),
                  ),
        Positioned(
          bottom: 20,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'issue_fab',
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _IssueReportForm(userData: widget.userData),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Report Issue'),
          ),
        ),
      ],
    );
  }
}

// ── Cards ────────────────────────────────────────────────────────────────────

class _WorkEntryCard extends StatelessWidget {
  final WorkEntry entry;
  const _WorkEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) = switch (entry.status) {
      'approved' => ('Approved', Colors.green),
      'submitted' => ('Submitted', Colors.orange),
      _ => ('Draft', Colors.grey),
    };

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  entry.date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _kSlate,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              entry.description,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${entry.hoursWorked.toStringAsFixed(1)} hrs',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (entry.taskTitle != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.link, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      entry.taskTitle!,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IssueCard extends StatelessWidget {
  final IssueModel issue;
  const _IssueCard({required this.issue});

  @override
  Widget build(BuildContext context) {
    final (severityLabel, severityColor) = _severityStyle(issue.severity);
    final (statusLabel, statusColor) = _statusStyle(issue.status);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Chip(label: severityLabel, color: severityColor),
                const SizedBox(width: 8),
                _Chip(label: statusLabel, color: statusColor),
                const Spacer(),
                Text(
                  _formatDate(issue.createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              issue.title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
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
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.category_outlined,
                    size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _capitalise(issue.category),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static (String, Color) _severityStyle(String s) => switch (s) {
    'critical' => ('Critical', const Color(0xFF7B1FA2)),
    'high' => ('High', Colors.red),
    'medium' => ('Medium', Colors.orange),
    _ => ('Low', Colors.green),
  };

  static (String, Color) _statusStyle(String s) => switch (s) {
    'resolved' => ('Resolved', Colors.green),
    'closed' => ('Closed', Colors.grey),
    'in_progress' => ('In Progress', Colors.blue),
    _ => ('Open', Colors.orange),
  };

  static String _formatDate(DateTime d) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month-1]}';
  }

  static String _capitalise(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
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

// ── Work entry form ──────────────────────────────────────────────────────────

class _WorkEntryForm extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const _WorkEntryForm({required this.userData});

  @override
  State<_WorkEntryForm> createState() => _WorkEntryFormState();
}

class _WorkEntryFormState extends State<_WorkEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _hoursController = TextEditingController();
  String? _selectedTaskId;
  String? _selectedTaskTitle;
  bool _submitting = false;

  @override
  void dispose() {
    _descController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.read<TaskProvider>().inProgressTasks;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'New Work Entry',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: _kSlate,
              ),
            ),
            const SizedBox(height: 20),

            // Description
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: _inputDecoration('Work description *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),

            // Hours worked
            TextFormField(
              controller: _hoursController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('Hours worked *'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final n = double.tryParse(v.trim());
                if (n == null || n <= 0) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Linked task (optional)
            if (tasks.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedTaskId,
                decoration: _inputDecoration('Linked task (optional)'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None'),
                  ),
                  ...tasks.map(
                    (t) => DropdownMenuItem(
                      value: t.id,
                      child: Text(
                        t.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (v) {
                  setState(() {
                    _selectedTaskId = v;
                    _selectedTaskTitle =
                        tasks.firstWhere((t) => t.id == v,
                                orElse: () => tasks.first)
                            .title;
                  });
                },
              ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: _kSlate,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Submit Entry',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final uid = widget.userData?['uid'] as String? ?? '';
    final name = widget.userData?['displayName'] as String? ?? '';
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      final docRef = FirebaseFirestore.instance.collection('work_entries').doc();
      final entry = WorkEntry(
        id: docRef.id,
        engineerId: uid,
        engineerName: name,
        date: dateStr,
        taskId: _selectedTaskId,
        taskTitle: _selectedTaskTitle,
        description: _descController.text.trim(),
        hoursWorked: double.parse(_hoursController.text.trim()),
        status: 'submitted',
        createdAt: now,
      );
      await docRef.set(entry.toMap());

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Work entry submitted'),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  static InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF5F7F8),
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
      borderSide: const BorderSide(color: _kSlate, width: 1.5),
    ),
  );
}

// ── Issue report form ────────────────────────────────────────────────────────

class _IssueReportForm extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const _IssueReportForm({required this.userData});

  @override
  State<_IssueReportForm> createState() => _IssueReportFormState();
}

class _IssueReportFormState extends State<_IssueReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _severity = 'medium';
  String _category = 'equipment';

  static const _severities = ['low', 'medium', 'high', 'critical'];
  static const _categories = [
    'safety', 'equipment', 'quality', 'process', 'other'
  ];

  static Color _severityColor(String s) => switch (s) {
    'critical' => const Color(0xFF7B1FA2),
    'high' => Colors.red,
    'medium' => Colors.orange,
    _ => Colors.green,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final provider = context.watch<IssueProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Report an Issue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _kSlate,
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration('Issue title *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDecoration('Description *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Severity selector
              const Text(
                'Severity',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: _kSlate,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _severities.map((s) {
                  final selected = _severity == s;
                  final color = _severityColor(s);
                  return ChoiceChip(
                    label: Text(
                      '${s[0].toUpperCase()}${s.substring(1)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : color,
                        fontSize: 13,
                      ),
                    ),
                    selected: selected,
                    selectedColor: color,
                    backgroundColor: color.withValues(alpha: 0.08),
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                    onSelected: (_) => setState(() => _severity = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Category selector
              DropdownButtonFormField<String>(
                value: _category,
                decoration: _inputDecoration('Category'),
                items: _categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text('${c[0].toUpperCase()}${c.substring(1)}'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: provider.isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = widget.userData?['uid'] as String? ?? '';
    final name = widget.userData?['displayName'] as String? ?? '';
    final dept = widget.userData?['department'] as String? ?? '';

    final ok = await context.read<IssueProvider>().reportIssue(
      reportedBy: uid,
      reporterName: name,
      department: dept,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      severity: _severity,
      category: _category,
    );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Issue reported successfully' : 'Failed to report issue'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
  }

  static InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFFF5F7F8),
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
      borderSide: const BorderSide(color: Colors.orange, width: 1.5),
    ),
  );
}

// ── Shared empty state ───────────────────────────────────────────────────────

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
