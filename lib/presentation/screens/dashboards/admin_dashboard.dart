import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';
import 'admin/admin_overview_tab.dart';
import 'admin/user_management_tab.dart';
import 'admin/system_configuration_tab.dart';
import 'admin/reports_analytics_tab.dart';
import 'admin/permissions_tab.dart';

class AdminDashboard extends StatefulWidget {
  final int selectedTab;
  
  const AdminDashboard({super.key, required this.selectedTab});
  
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late int _currentTab;
  
  @override
  void initState() {
    super.initState();
    _currentTab = widget.selectedTab;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final adminProvider = Provider.of<AdminProvider>(context, listen: false);
      adminProvider.loadAllUsers();
      adminProvider.loadSystemConfig();
      adminProvider.loadDepartments();
      adminProvider.loadPermissions();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildTabContent(_currentTab),
    );
  }
  
  Widget _buildTabContent(int tab) {
    switch (tab) {
      case 0:
        return AdminOverviewTab();
      case 1:
        return UserManagementTab();
      case 2:
        return SystemConfigurationTab();
      case 3:
        return ReportsAnalyticsTab();
      case 4:
        return PermissionsTab();
      default:
        return AdminOverviewTab();
    }
  }
}