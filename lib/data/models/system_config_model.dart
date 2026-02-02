/// System Configuration Model
class SystemConfig {
  final String id;
  final List<String> departments;
  final List<String> roles;
  final Map<String, dynamic> permissions;
  final String companyName;
  final String companyLogo;
  final bool maintenanceMode;
  final DateTime lastUpdatedAt;
  final String lastUpdatedBy;
  final Map<String, dynamic> emailSettings;
  final Map<String, dynamic> notificationSettings;
  
  SystemConfig({
    required this.id,
    required this.departments,
    required this.roles,
    required this.permissions,
    required this.companyName,
    required this.companyLogo,
    required this.maintenanceMode,
    required this.lastUpdatedAt,
    required this.lastUpdatedBy,
    required this.emailSettings,
    required this.notificationSettings,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departments': departments,
      'roles': roles,
      'permissions': permissions,
      'companyName': companyName,
      'companyLogo': companyLogo,
      'maintenanceMode': maintenanceMode,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'lastUpdatedBy': lastUpdatedBy,
      'emailSettings': emailSettings,
      'notificationSettings': notificationSettings,
    };
  }
  
  factory SystemConfig.fromMap(Map<String, dynamic> map) {
    return SystemConfig(
      id: map['id'] ?? 'default',
      departments: List<String>.from(map['departments'] ?? ['Mechanical', 'Electrical', 'Civil', 'Structural']),
      roles: List<String>.from(map['roles'] ?? ['engineer', 'supervisor', 'admin']),
      permissions: map['permissions'] ?? {},
      companyName: map['companyName'] ?? 'Engineering Company',
      companyLogo: map['companyLogo'] ?? '',
      maintenanceMode: map['maintenanceMode'] ?? false,
      lastUpdatedAt: map['lastUpdatedAt'] != null 
          ? DateTime.parse(map['lastUpdatedAt'])
          : DateTime.now(),
      lastUpdatedBy: map['lastUpdatedBy'] ?? 'System',
      emailSettings: map['emailSettings'] ?? {},
      notificationSettings: map['notificationSettings'] ?? {},
    );
  }
  
  factory SystemConfig.defaultConfig() {
    return SystemConfig(
      id: 'default',
      departments: ['Mechanical', 'Electrical', 'Civil', 'Structural'],
      roles: ['engineer', 'supervisor', 'admin'],
      permissions: {
        'engineer': ['view_own_tasks', 'view_own_attendance', 'view_own_reports'],
        'supervisor': ['manage_team', 'assign_tasks', 'approve_tasks', 'view_team_attendance', 'generate_team_reports'],
        'admin': ['manage_all_users', 'manage_system_config', 'manage_permissions', 'view_system_reports', 'manage_departments'],
      },
      companyName: 'Engineering Company',
      companyLogo: '',
      maintenanceMode: false,
      lastUpdatedAt: DateTime.now(),
      lastUpdatedBy: 'System',
      emailSettings: {
        'smtpServer': '',
        'smtpPort': 587,
        'enableNotifications': true,
      },
      notificationSettings: {
        'enablePushNotifications': true,
        'enableEmailNotifications': true,
        'enableSmsNotifications': false,
      },
    );
  }
}


/// Department Model
class Department {
  final String id;
  final String name;
  final String description;
  final List<String> supervisorIds;
  final int teamSize;
  final DateTime createdAt;
  final bool isActive;
  
  Department({
    required this.id,
    required this.name,
    required this.description,
    required this.supervisorIds,
    required this.teamSize,
    required this.createdAt,
    required this.isActive,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'supervisorIds': supervisorIds,
      'teamSize': teamSize,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
  
  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      supervisorIds: List<String>.from(map['supervisorIds'] ?? []),
      teamSize: map['teamSize'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      isActive: map['isActive'] ?? true,
    );
  }
}


/// Permission Model
class Permission {
  final String id;
  final String role;
  final List<String> actions;
  final List<String> resources;
  final bool canApprove;
  final bool canManage;
  final bool canView;
  final DateTime lastModified;
  
  Permission({
    required this.id,
    required this.role,
    required this.actions,
    required this.resources,
    required this.canApprove,
    required this.canManage,
    required this.canView,
    required this.lastModified,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      'actions': actions,
      'resources': resources,
      'canApprove': canApprove,
      'canManage': canManage,
      'canView': canView,
      'lastModified': lastModified.toIso8601String(),
    };
  }
  
  factory Permission.fromMap(Map<String, dynamic> map) {
    return Permission(
      id: map['id'],
      role: map['role'],
      actions: List<String>.from(map['actions'] ?? []),
      resources: List<String>.from(map['resources'] ?? []),
      canApprove: map['canApprove'] ?? false,
      canManage: map['canManage'] ?? false,
      canView: map['canView'] ?? true,
      lastModified: DateTime.parse(map['lastModified']),
    );
  }
}
