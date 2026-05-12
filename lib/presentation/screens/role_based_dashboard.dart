import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/core/services/fcm_service.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/components/role_navigation.dart';
import 'package:tenken_engiflow/presentation/components/language_switcher.dart';
import 'package:tenken_engiflow/presentation/screens/dashboards/engineer_dashboard.dart';
import 'package:tenken_engiflow/presentation/screens/dashboards/supervisor_dashboard.dart';
import 'package:tenken_engiflow/presentation/screens/dashboards/admin_dashboard.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';

class RoleBasedDashboard extends StatefulWidget {
  const RoleBasedDashboard({super.key});

  @override
  State<RoleBasedDashboard> createState() => _RoleBasedDashboardState();
}

class _RoleBasedDashboardState extends State<RoleBasedDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize FCM after login — runs asynchronously, errors are silent
    final uid = context.read<AuthProvider>().firebaseUser?.uid;
    if (uid != null) FcmService.initialize(uid);
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final role = userData?['role'] ?? 'engineer';
    
    return Scaffold(
      appBar: _buildAppBar(context, role, userData, authProvider),
      body: _buildBody(role, _selectedIndex),
      bottomNavigationBar: RoleNavigation(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
  
  AppBar _buildAppBar(BuildContext context, String role, Map<String, dynamic>? userData, AuthProvider authProvider) {
    Color roleColor;
    String roleTitle;
    
    switch (role) {
      case 'engineer':
        roleColor = const Color(0xFF37474F);
        roleTitle = AppLocalizations.of(context)!.engineer;
        break;
      case 'supervisor':
        roleColor = const Color(0xFFF57C00);
        roleTitle = AppLocalizations.of(context)!.supervisor;
        break;
      case 'admin':
        roleColor = const Color(0xFF388E3C);
        roleTitle = AppLocalizations.of(context)!.admin;
        break;
      default:
        roleColor = const Color(0xFF37474F);
        roleTitle = AppLocalizations.of(context)!.dashboard;
    }
    
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$roleTitle ${AppLocalizations.of(context)!.dashboard}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (userData?['department'] != null)
            Text(
              userData!['department'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 1,
      actions: [
        // Language Switcher
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: LanguageSwitcher(showLabel: false),
        ),
        
        // Role Badge
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: roleColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            role.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: roleColor,
            ),
          ),
        ),
        
        // Logout Button
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () => authProvider.logout(),
          tooltip: AppLocalizations.of(context)!.logout,
        ),
      ],
    );
  }
  
  Widget _buildBody(String role, int index) {
    switch (role) {
      case 'engineer':
        return EngineerDashboard(selectedTab: index);
      case 'supervisor':
        return SupervisorDashboard(selectedTab: index);
      case 'admin':
        return AdminDashboard(selectedTab: index);
      default:
        return EngineerDashboard(selectedTab: index);
    }
  }
}