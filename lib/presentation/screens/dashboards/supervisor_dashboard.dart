import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/providers/supervisor_provider.dart';
import 'package:tenken_engiflow/presentation/screens/supervisor/overview_tab.dart';
import 'package:tenken_engiflow/presentation/screens/supervisor/team_tab.dart';
import 'package:tenken_engiflow/presentation/screens/supervisor/approvals_tab.dart';
import 'package:tenken_engiflow/presentation/screens/supervisor/analytics_tab.dart';

class SupervisorDashboard extends StatefulWidget {
  final int selectedTab;
  const SupervisorDashboard({super.key, required this.selectedTab});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
    }
  }

  void _loadAll() {
    final dept =
        context.read<AuthProvider>().userData?['department'] as String? ?? '';
    final sv = context.read<SupervisorProvider>();
    sv.loadTeamMembers(department: dept);
    sv.loadPendingTasks();
    sv.loadAttendanceRecords(DateTime.now());
    sv.loadDepartmentIssues(dept);
    sv.loadPendingWorkEntries();
    sv.loadRecentActivity(dept);
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.selectedTab,
      children: const [
        OverviewTab(),
        TeamTab(),
        ApprovalsTab(),
        AnalyticsTab(),
      ],
    );
  }
}
