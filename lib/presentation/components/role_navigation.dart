import 'package:flutter/material.dart';
import 'package:tenken_engiflow/core/constants/roles.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RoleNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const RoleNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    final role = userData?['role'] ?? 'engineer';
    
    // Different navigation items based on role
    final navItems = _getNavigationItems(role);
    
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF37474F),
      unselectedItemColor: Colors.grey[600],
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: navItems,
    );
  }
  
  List<BottomNavigationBarItem> _getNavigationItems(String role) {
    switch (role) {
      case 'engineer':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tasks',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ];
        
      case 'supervisor':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Team',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Approvals',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ];
        
      case 'admin':
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'System',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Admin',
          ),
        ];
        
      default:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
        ];
    }
  }
}