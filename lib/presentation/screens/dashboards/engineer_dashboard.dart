import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/providers/task_provider.dart';
import 'package:tenken_engiflow/presentation/providers/attendance_provider.dart';
import 'package:tenken_engiflow/presentation/providers/issue_provider.dart';
import 'package:tenken_engiflow/presentation/screens/engineer/home_tab.dart';
import 'package:tenken_engiflow/presentation/screens/engineer/tasks_tab.dart';
import 'package:tenken_engiflow/presentation/screens/engineer/reports_tab.dart';
import 'package:tenken_engiflow/presentation/screens/engineer/profile_tab.dart';

class EngineerDashboard extends StatefulWidget {
  final int selectedTab;
  const EngineerDashboard({super.key, required this.selectedTab});

  @override
  State<EngineerDashboard> createState() => _EngineerDashboardState();
}

class _EngineerDashboardState extends State<EngineerDashboard> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load once per session; re-runs if auth user changes.
    if (!_loaded) {
      _loaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
    }
  }

  void _loadAll() {
    final uid =
        context.read<AuthProvider>().userData?['uid'] as String? ?? '';
    if (uid.isEmpty) return;
    context.read<TaskProvider>().loadMyTasks(uid);
    context.read<AttendanceProvider>().loadTodayRecord(uid);
    context.read<IssueProvider>().loadMyIssues(uid);
  }

  @override
  Widget build(BuildContext context) {
    // IndexedStack keeps all tabs alive so scroll position and loaded
    // data are preserved when switching tabs.
    return IndexedStack(
      index: widget.selectedTab,
      children: const [
        HomeTab(),
        TasksTab(),
        ReportsTab(),
        ProfileTab(),
      ],
    );
  }
}
