import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  final int selectedTab;
  
  const AdminDashboard({super.key, required this.selectedTab});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Admin Dashboard - Coming Soon',
        style: TextStyle(fontSize: 24, color: Colors.grey[600]),
      ),
    );
  }
}