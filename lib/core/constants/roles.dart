import 'package:flutter/material.dart';

class Role {
  final String displayName;
  final String value;
  final IconData icon;
  final String description;

  const Role({
    required this.displayName,
    required this.value,
    required this.icon,
    required this.description,
  });
}

class AppRoles {
  static const engineer = Role(
    displayName: 'Engineer',
    value: 'engineer',
    icon: Icons.engineering,
    description: 'Create work entries, submit reports, view tasks',
  );
  
  static const supervisor = Role(
    displayName: 'Supervisor',
    value: 'supervisor',
    icon: Icons.supervisor_account,
    description: 'Approve reports, assign tasks, view team progress',
  );
  
  static const admin = Role(
    displayName: 'Admin',
    value: 'admin',
    icon: Icons.admin_panel_settings,
    description: 'Manage users, system configuration, all permissions',
  );
  
  static List<Role> get all => [engineer, supervisor, admin];
  
  static Role? fromValue(String value) {
    return all.firstWhere(
      (role) => role.value == value,
      orElse: () => engineer,
    );
  }
}