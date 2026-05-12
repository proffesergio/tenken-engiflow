import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/supervisor_provider.dart';

const _kOrange = Color(0xFFF57C00);
const _kSlate = Color(0xFF37474F);

// Public helper callable from overview_tab
void showAssignTaskDialog(
  BuildContext context,
  SupervisorProvider provider, {
  String? preselectedMemberId,
}) {
  showDialog(
    context: context,
    builder: (_) => AssignTaskDialog(
      provider: provider,
      teamMembers: provider.teamMembers,
      preselectedMemberId: preselectedMemberId,
    ),
  );
}

class TeamTab extends StatefulWidget {
  const TeamTab({super.key});

  @override
  State<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends State<TeamTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(List<Map<String, dynamic>> members) {
    if (_searchQuery.isEmpty) return members;
    final q = _searchQuery.toLowerCase();
    return members.where((m) {
      final name = (m['displayName'] as String? ?? '').toLowerCase();
      final dept = (m['department'] as String? ?? '').toLowerCase();
      return name.contains(q) || dept.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final sv = context.watch<SupervisorProvider>();
    final filtered = _filtered(sv.teamMembers);

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: Colors.white,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search by name or department…',
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
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
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

        // Header row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Text(
                '${filtered.length} member${filtered.length != 1 ? 's' : ''}',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add_task, size: 16),
                label: const Text('Assign Task'),
                style: TextButton.styleFrom(foregroundColor: _kOrange),
                onPressed: () => showAssignTaskDialog(context, sv),
              ),
            ],
          ),
        ),

        // Member list
        Expanded(
          child: sv.isLoading
              ? const Center(child: CircularProgressIndicator())
              : filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No team members found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => _MemberCard(
                        member: filtered[i],
                        onAssign: () => showAssignTaskDialog(
                          context,
                          sv,
                          preselectedMemberId: filtered[i]['id'] as String?,
                        ),
                        onDetails: () => _showDetails(context, filtered[i]),
                        onAttendance: () =>
                            _showAttendance(context, sv, filtered[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MemberDetailsSheet(member: member),
    );
  }

  void _showAttendance(
    BuildContext context,
    SupervisorProvider sv,
    Map<String, dynamic> member,
  ) {
    showDialog(
      context: context,
      builder: (_) => AttendanceUpdateDialog(
        provider: sv,
        member: member,
        selectedDate: DateTime.now(),
      ),
    );
  }
}

// ── Member card ───────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final Map<String, dynamic> member;
  final VoidCallback onAssign;
  final VoidCallback onDetails;
  final VoidCallback onAttendance;

  const _MemberCard({
    required this.member,
    required this.onAssign,
    required this.onDetails,
    required this.onAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final name = member['displayName'] as String? ?? '—';
    final email = member['email'] as String? ?? '—';
    final dept = member['department'] as String? ?? '—';

    return GestureDetector(
      onTap: onDetails,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _kSlate,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials(name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _kSlate,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dept,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Actions column
            Column(
              children: [
                _SmallButton(
                  icon: Icons.add_task,
                  label: 'Assign',
                  color: _kOrange,
                  onTap: onAssign,
                ),
                const SizedBox(height: 4),
                _SmallButton(
                  icon: Icons.event_note,
                  label: 'Attend.',
                  color: Colors.blue,
                  onTap: onAttendance,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Member details bottom sheet ───────────────────────────────────────────────

class _MemberDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> member;
  const _MemberDetailsSheet({required this.member});

  @override
  Widget build(BuildContext context) {
    final name = member['displayName'] as String? ?? '—';
    final email = member['email'] as String? ?? '—';
    final dept = member['department'] as String? ?? '—';
    final role = member['role'] as String? ?? 'engineer';
    final createdAt = member['createdAt'] as String? ?? '';

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scroll) => SingleChildScrollView(
        controller: scroll,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
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
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: _kSlate,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _initials(name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kSlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _kOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${role[0].toUpperCase()}${role.substring(1)}',
                        style: const TextStyle(
                          color: _kOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: email,
              ),
              const Divider(height: 20),
              _InfoRow(
                icon: Icons.apartment_outlined,
                label: 'Department',
                value: dept,
              ),
              const Divider(height: 20),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Joined',
                value: _formatDate(createdAt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static String _formatDate(String iso) {
    if (iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '—';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(fontSize: 14, color: _kSlate)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}

// ── Dialogs ───────────────────────────────────────────────────────────────────

class AssignTaskDialog extends StatefulWidget {
  final SupervisorProvider provider;
  final List<Map<String, dynamic>> teamMembers;
  final String? preselectedMemberId;

  const AssignTaskDialog({
    super.key,
    required this.provider,
    required this.teamMembers,
    this.preselectedMemberId,
  });

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 3));
  String _memberId = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _memberId = widget.preselectedMemberId ??
        (widget.teamMembers.isNotEmpty
            ? widget.teamMembers.first['id'] as String? ?? ''
            : '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              if (widget.teamMembers.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _memberId.isEmpty ? null : _memberId,
                  decoration: const InputDecoration(labelText: 'Assign To'),
                  items: widget.teamMembers.map((m) {
                    return DropdownMenuItem(
                      value: m['id'] as String? ?? '',
                      child: Text(
                          m['displayName'] as String? ?? m['id'] as String),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _memberId = v ?? ''),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Select a member' : null,
                ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (v) => setState(() => _priority = v ?? 'medium'),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (d != null) setState(() => _dueDate = d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Due Date'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
                      ),
                      const Icon(Icons.calendar_today, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _kOrange),
          onPressed: _saving ? null : _submit,
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ok = await widget.provider.assignTask(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      assignedTo: _memberId,
      priority: _priority,
      dueDate: _dueDate,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task assigned successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class AttendanceUpdateDialog extends StatefulWidget {
  final SupervisorProvider provider;
  final Map<String, dynamic> member;
  final DateTime selectedDate;

  const AttendanceUpdateDialog({
    super.key,
    required this.provider,
    required this.member,
    required this.selectedDate,
  });

  @override
  State<AttendanceUpdateDialog> createState() =>
      _AttendanceUpdateDialogState();
}

class _AttendanceUpdateDialogState extends State<AttendanceUpdateDialog> {
  String _status = 'present';
  final _notesCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.member['displayName'] as String? ?? '—';
    final d = widget.selectedDate;
    final dateStr =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return AlertDialog(
      title: const Text('Update Attendance'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            dateStr,
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: const [
              DropdownMenuItem(value: 'present', child: Text('Present')),
              DropdownMenuItem(value: 'absent', child: Text('Absent')),
              DropdownMenuItem(value: 'late', child: Text('Late')),
              DropdownMenuItem(value: 'half_day', child: Text('Half Day')),
              DropdownMenuItem(value: 'leave', child: Text('On Leave')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'present'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            maxLines: 2,
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
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    final ok = await widget.provider.updateAttendance(
      userId: widget.member['id'] as String,
      date: widget.selectedDate,
      status: _status,
      notes: _notesCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Attendance updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
