import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/providers/supervisor_provider.dart';
import 'package:tenken_engiflow/presentation/components/stat_card.dart';
import 'package:tenken_engiflow/presentation/components/team_member_card.dart';
import 'package:tenken_engiflow/presentation/components/task_approval_card.dart';
import 'package:tenken_engiflow/presentation/components/attendance_card.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';


class SupervisorDashboard extends StatefulWidget {
  final int selectedTab;
  
  const SupervisorDashboard({super.key, required this.selectedTab});
  
  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  DateTime _selectedDate = DateTime.now();
  String _selectedDepartment = 'All';
  final List<String> _departments = ['All', 'Mechanical', 'Electrical', 'Civil', 'Structural'];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final supervisorProvider = Provider.of<SupervisorProvider>(context, listen: false);
      supervisorProvider.loadTeamMembers();
      supervisorProvider.loadPendingTasks();
      supervisorProvider.loadAttendanceRecords(_selectedDate);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final supervisorProvider = Provider.of<SupervisorProvider>(context);
    final userData = authProvider.userData;
    
    // Show different content based on selected tab
    switch (widget.selectedTab) {
      case 0: // Overview tab
        return _buildOverviewTab(userData, supervisorProvider);
      case 1: // Team tab
        return _buildTeamTab(supervisorProvider);
      case 2: // Approvals tab
        return _buildApprovalsTab(supervisorProvider);
      case 3: // Analytics tab
        return _buildAnalyticsTab(supervisorProvider);
      default:
        return _buildOverviewTab(userData, supervisorProvider);
    }
  }
  
  Widget _buildOverviewTab(Map<String, dynamic>? userData, SupervisorProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF57C00).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF57C00).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF57C00).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.supervisor_account,
                    size: 32,
                    color: Color(0xFFF57C00),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Supervisor Dashboard',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF37474F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Team: ${userData?['department'] ?? 'Engineering Department'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Stats
          Text(
            AppLocalizations.of(context)!.quick_stats,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              StatCard(
                title: 'Team Members',
                value: '${provider.teamMembers.length}',
                icon: Icons.group,
                color: Colors.blue,
                subtitle: 'Active engineers',
              ),
              StatCard(
                title: 'Pending Tasks',
                value: '${provider.pendingTasks.length}',
                icon: Icons.pending_actions,
                color: Colors.orange,
                subtitle: 'Awaiting approval',
              ),
              StatCard(
                title: 'Attendance',
                value: '95%',
                icon: Icons.calendar_today,
                color: Colors.green,
                subtitle: 'Today\'s present rate',
              ),
              StatCard(
                title: 'Completion',
                value: '88%',
                icon: Icons.check_circle,
                color: Colors.purple,
                subtitle: 'Task completion rate',
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.add_task,
                  label: 'Assign Task',
                  color: const Color(0xFF37474F),
                  onTap: () => _showAssignTaskDialog(context, provider),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.approval,
                  label: 'Review Tasks',
                  color: const Color(0xFFF57C00),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.assessment,
                  label: 'Team Report',
                  color: Colors.blue,
                  onTap: () {},
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Recent Team Activity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Team Activity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF37474F),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(color: Color(0xFFF57C00)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Activity List
          ..._buildActivityList(),
        ],
      ),
    );
  }
  
  Widget _buildTeamTab(SupervisorProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Team Header with Filter
          Row(
            children: [
              const Text(
                'Team Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF37474F),
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedDepartment,
                items: _departments.map((dept) {
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(dept),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value!;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Team Members Grid
          provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.teamMembers.isEmpty
                  ? const Center(
                      child: Text(
                        'No team members found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: provider.teamMembers.length,
                      itemBuilder: (context, index) {
                        final member = provider.teamMembers[index];
                        return TeamMemberCard(
                          member: member,
                          onAssignTask: () => _showAssignTaskDialog(context, provider, memberId: member['id']),
                          onViewDetails: () => _showMemberDetails(context, member),
                          onEvaluate: () => _showAttendanceDialog(context, provider, member),
                        );
                      },
                    ),
          
          const SizedBox(height: 24),
          
          // Add Team Member Button
          Center(
            child: ElevatedButton.icon(
              onPressed: () => _showAddTeamMemberDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Team Member'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF57C00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildApprovalsTab(SupervisorProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Approvals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tasks, reports, and requests requiring your approval',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          
          // Tabs for different approval types
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    labelColor: const Color(0xFFF57C00),
                    unselectedLabelColor: Colors.grey[600],
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    tabs: const [
                      Tab(text: 'Tasks'),
                      Tab(text: 'Reports'),
                      Tab(text: 'Requests'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    children: [
                      // Tasks Tab
                      provider.pendingTasks.isEmpty
                          ? const Center(
                              child: Text(
                                'No pending tasks for approval',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: provider.pendingTasks.length,
                              itemBuilder: (context, index) {
                                final task = provider.pendingTasks[index];
                                return TaskApprovalCard(
                                  task: task,
                                  onApprove: (comments) => provider.approveTask(task.id, comments),
                                  onReject: (reason) => provider.rejectTask(task.id, reason),
                                );
                              },
                            ),
                      
                      // Reports Tab
                      const Center(
                        child: Text(
                          'No pending reports',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      
                      // Requests Tab
                      const Center(
                        child: Text(
                          'No pending requests',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnalyticsTab(SupervisorProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Analytics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 16),
          
          // Date Range Selector
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 8),
                      Text('This Month'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {},
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Performance Metrics
          const Text(
            'Performance Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              _buildMetricCard('Task Completion', '92%', Icons.check_circle, Colors.green, '+2% from last month'),
              _buildMetricCard('On-Time Delivery', '88%', Icons.timer, Colors.blue, '5 days avg'),
              _buildMetricCard('Quality Score', '94%', Icons.star, Colors.orange, 'High'),
              _buildMetricCard('Team Attendance', '96%', Icons.people, Colors.purple, 'Excellent'),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Attendance Overview
          const Text(
            'Attendance Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 16),
          
          // Attendance Cards
          ...provider.attendanceRecords.map((record) => AttendanceCard(record: record)).toList(),
          
          const SizedBox(height: 24),
          
          // Department Performance
          const Text(
            'Department Performance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Department', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Completion', style: TextStyle(fontWeight: FontWeight.w600))),
                    Expanded(child: Text('Quality', style: TextStyle(fontWeight: FontWeight.w600))),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: Text('Mechanical')),
                    Expanded(child: Text('95%')),
                    Expanded(child: Text('92%')),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('Electrical')),
                    Expanded(child: Text('89%')),
                    Expanded(child: Text('90%')),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Text('Civil')),
                    Expanded(child: Text('91%')),
                    Expanded(child: Text('88%')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods for dialogs
  void _showAssignTaskDialog(BuildContext context, SupervisorProvider provider, {String? memberId}) {
    showDialog(
      context: context,
      builder: (context) => AssignTaskDialog(
        provider: provider,
        teamMembers: provider.teamMembers,
        preselectedMemberId: memberId,
      ),
    );
  }
  
  void _showMemberDetails(BuildContext context, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => MemberDetailsDialog(member: member),
    );
  }
  
  void _showAttendanceDialog(BuildContext context, SupervisorProvider provider, Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) => AttendanceDialog(
        provider: provider,
        member: member,
        selectedDate: _selectedDate,
      ),
    );
  }
  
  void _showAddTeamMemberDialog(BuildContext context) {
    // Implementation for adding team member
  }
  
  List<Widget> _buildActivityList() {
    return [
      _buildActivityItem('山田太郎 completed "機械点検" task', '10:30 AM', Icons.check_circle, Colors.green),
      _buildActivityItem('佐藤花子 submitted weekly report', '9:15 AM', Icons.description, Colors.blue),
      _buildActivityItem('鈴木一郎 checked in late', '8:45 AM', Icons.schedule, Colors.orange),
      _buildActivityItem('New task assigned to 田中健', 'Yesterday', Icons.add_task, Colors.purple),
    ];
  }
  
  Widget _buildActivityItem(String text, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF37474F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

// Dialog Widgets
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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedMember = '';
  String _selectedPriority = 'medium';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  
  @override
  void initState() {
    super.initState();
    _selectedMember = widget.preselectedMemberId ?? (widget.teamMembers.isNotEmpty ? widget.teamMembers.first['id'] : '');
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign New Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedMember,
                decoration: const InputDecoration(
                  labelText: 'Assign To',
                  border: OutlineInputBorder(),
                ),
                items: widget.teamMembers.map<DropdownMenuItem<String>>((member) {
                  return DropdownMenuItem(
                    value: member['id'],
                    child: Text(member['displayName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMember = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select team member';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPriority = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selected != null) {
                    setState(() {
                      _selectedDate = selected;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
                      const Icon(Icons.calendar_today),
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
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final success = await widget.provider.assignTask(
                title: _titleController.text,
                description: _descriptionController.text,
                assignedTo: _selectedMember,
                priority: _selectedPriority,
                dueDate: _selectedDate,
              );
              
              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task assigned successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            }
          },
          child: const Text('Assign Task'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

class MemberDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> member;
  
  const MemberDetailsDialog({super.key, required this.member});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Team Member Details'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF37474F).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF37474F),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Name', member['displayName']),
            _buildDetailRow('Email', member['email']),
            _buildDetailRow('Role', member['role']),
            _buildDetailRow('Department', member['department']),
            _buildDetailRow('Member Since', member['createdAt']?.toString().substring(0, 10) ?? 'N/A'),
            const SizedBox(height: 16),
            const Text(
              'Performance Metrics',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildMetricRow('Task Completion', '92%'),
            _buildMetricRow('On Time Rate', '88%'),
            _buildMetricRow('Quality Score', '4.5/5'),
            _buildMetricRow('Attendance', '96%'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('View Full Report'),
        ),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
  
  Widget _buildMetricRow(String metric, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(metric)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AttendanceDialog extends StatefulWidget {
  final SupervisorProvider provider;
  final Map<String, dynamic> member;
  final DateTime selectedDate;
  
  const AttendanceDialog({
    super.key,
    required this.provider,
    required this.member,
    required this.selectedDate,
  });
  
  @override
  State<AttendanceDialog> createState() => _AttendanceDialogState();
}

class _AttendanceDialogState extends State<AttendanceDialog> {
  String _selectedStatus = 'present';
  final _notesController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Attendance'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Member: ${widget.member['displayName']}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: ${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Attendance Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'present', child: Text('Present')),
                DropdownMenuItem(value: 'absent', child: Text('Absent')),
                DropdownMenuItem(value: 'late', child: Text('Late')),
                DropdownMenuItem(value: 'half_day', child: Text('Half Day')),
                DropdownMenuItem(value: 'leave', child: Text('On Leave')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final success = await widget.provider.updateAttendance(
              userId: widget.member['id'],
              date: widget.selectedDate,
              status: _selectedStatus,
              notes: _notesController.text,
            );
            
            if (success && context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attendance updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text('Update'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF57C00),
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}