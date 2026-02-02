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
    };
  }
  
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      displayName: map['displayName'],
      role: map['role'],
      department: map['department'],
      createdAt: DateTime.parse(map['createdAt']),
      managedDepartments: map['managedDepartments'] != null 
          ? List<String>.from(map['managedDepartments'])
          : null,
      teamMemberIds: map['teamMemberIds'] != null
          ? List<String>.from(map['teamMemberIds'])
          : null,
      supervisorId: map['supervisorId'],
    );
  }
  
  // Helper methods
  bool get isEngineer => role == 'engineer';
  bool get isSupervisor => role == 'supervisor';
  bool get isAdmin => role == 'admin';
}