import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';
import 'admin/admin_overview_tab.dart';
import 'admin/user_management_tab.dart';
import 'admin/tasks_tab.dart';
import 'admin/issues_tab.dart';
import 'admin/reports_analytics_tab.dart';

class AdminDashboard extends StatefulWidget {
  final int selectedTab;
  const AdminDashboard({super.key, required this.selectedTab});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
    final admin = context.read<AdminProvider>();
    admin.loadAllUsers();
    admin.loadAllTasks();
    admin.loadAllIssues();
    admin.loadRecentActivity();
    admin.loadSystemConfig();
    admin.loadDepartments();
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.selectedTab,
      children: const [
        AdminOverviewTab(),
        UserManagementTab(),
        AdminTasksTab(),
        AdminIssuesTab(),
        ReportsAnalyticsTab(),
      ],
    );
  }
}
