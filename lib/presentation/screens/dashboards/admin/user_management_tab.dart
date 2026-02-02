import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRoleFilter = 'all';
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                AppLocalizations.of(context)!.userManagement,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 16),
              
              // Add New User Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(context, adminProvider),
                  icon: const Icon(Icons.person_add),
                  label: Text(AppLocalizations.of(context)!.addNewUser),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Search and Filter Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        adminProvider.searchUsers(value);
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchUsers,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedRoleFilter,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text(AppLocalizations.of(context)!.allRoles),
                        ),
                        DropdownMenuItem(
                          value: 'engineer',
                          child: Text(AppLocalizations.of(context)!.engineer),
                        ),
                        DropdownMenuItem(
                          value: 'supervisor',
                          child: Text(AppLocalizations.of(context)!.supervisor),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text(AppLocalizations.of(context)!.admin),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRoleFilter = value ?? 'all';
                          adminProvider.filterUsersByRole(_selectedRoleFilter);
                        });
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // User List
              if (adminProvider.isLoading)
                Center(
                  child: CircularProgressIndicator(),
                )
              else if (adminProvider.filteredUsers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      AppLocalizations.of(context)!.noUsersFound,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: adminProvider.filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = adminProvider.filteredUsers[index];
                    return _buildUserCard(context, user, adminProvider);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildUserCard(BuildContext context, dynamic user, AdminProvider provider) {
    Color roleColor;
    IconData roleIcon;
    
    switch (user.role) {
      case 'engineer':
        roleColor = Colors.orange;
        roleIcon = Icons.engineering;
        break;
      case 'supervisor':
        roleColor = Colors.purple;
        roleIcon = Icons.supervisor_account;
        break;
      case 'admin':
        roleColor = Colors.green;
        roleIcon = Icons.admin_panel_settings;
        break;
      default:
        roleColor = Colors.grey;
        roleIcon = Icons.person;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withOpacity(0.2),
                  child: Icon(roleIcon, color: roleColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: roleColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.apartment, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  user.department,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditUserDialog(context, user, provider),
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(AppLocalizations.of(context)!.edit),
                ),
                TextButton.icon(
                  onPressed: () => _showDeleteConfirmation(context, user, provider),
                  icon: const Icon(Icons.delete, size: 16),
                  label: Text(AppLocalizations.of(context)!.delete),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showAddUserDialog(BuildContext context, AdminProvider provider) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nameController = TextEditingController();
    String selectedRole = 'engineer';
    String selectedDepartment = 'Mechanical';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.addNewUser),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.fullName,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.password,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.role,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'engineer',
                          child: Text(AppLocalizations.of(context)!.engineer),
                        ),
                        DropdownMenuItem(
                          value: 'supervisor',
                          child: Text(AppLocalizations.of(context)!.supervisor),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text(AppLocalizations.of(context)!.admin),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedRole = value ?? 'engineer';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.department,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['Mechanical', 'Electrical', 'Civil', 'Structural']
                          .map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDepartment = value ?? 'Mechanical';
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.fillAllFields),
                        ),
                      );
                      return;
                    }
                    
                    final success = await provider.createNewUser(
                      email: emailController.text,
                      password: passwordController.text,
                      displayName: nameController.text,
                      role: selectedRole,
                      department: selectedDepartment,
                    );
                    
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.userCreatedSuccess),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                  ),
                  child: Text(AppLocalizations.of(context)!.create),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showEditUserDialog(BuildContext context, dynamic user, AdminProvider provider) {
    final nameController = TextEditingController(text: user.displayName);
    String selectedRole = user.role;
    String selectedDepartment = user.department;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.editUser),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.fullName,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.role,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'engineer',
                          child: Text(AppLocalizations.of(context)!.engineer),
                        ),
                        DropdownMenuItem(
                          value: 'supervisor',
                          child: Text(AppLocalizations.of(context)!.supervisor),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text(AppLocalizations.of(context)!.admin),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedRole = value ?? 'engineer';
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedDepartment,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.department,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: ['Mechanical', 'Electrical', 'Civil', 'Structural']
                          .map((dept) => DropdownMenuItem(
                            value: dept,
                            child: Text(dept),
                          ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedDepartment = value ?? user.department;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success = await provider.updateUser(
                      userId: user.uid,
                      displayName: nameController.text,
                      role: selectedRole,
                      department: selectedDepartment,
                    );
                    
                    if (success && mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context)!.userUpdatedSuccess),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                  ),
                  child: Text(AppLocalizations.of(context)!.update),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _showDeleteConfirmation(BuildContext context, dynamic user, AdminProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteUser),
          content: Text('${AppLocalizations.of(context)!.confirmDeleteUser}:\n\n${user.displayName} (${user.email})'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await provider.deleteUser(user.uid);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.userDeletedSuccess),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    );
  }
}
