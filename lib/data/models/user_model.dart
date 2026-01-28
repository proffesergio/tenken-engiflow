class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'engineer', 'supervisor', 'admin'
  final String department;
  final DateTime createdAt;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.department,
    required this.createdAt,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
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
    );
  }
}