class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'engineer', 'supervisor', 'admin'
  final String department;
  final DateTime createdAt;
  final List<String>? managedDepartments; // For supervisors
  final List<String>? teamMemberIds; // For supervisors
  final String? supervisorId; // For engineers
  final bool isActive; // false = deactivated by admin

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.department,
    required this.createdAt,
    this.managedDepartments,
    this.teamMemberIds,
    this.supervisorId,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
      'managedDepartments': managedDepartments,
      'teamMemberIds': teamMemberIds,
      'supervisorId': supervisorId,
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'engineer',
      department: map['department'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      managedDepartments: map['managedDepartments'] != null
          ? List<String>.from(map['managedDepartments'])
          : null,
      teamMemberIds: map['teamMemberIds'] != null
          ? List<String>.from(map['teamMemberIds'])
          : null,
      supervisorId: map['supervisorId'],
      isActive: map['isActive'] ?? true,
    );
  }

  // Helper getters
  bool get isEngineer => role == 'engineer';
  bool get isSupervisor => role == 'supervisor';
  bool get isAdmin => role == 'admin';
}