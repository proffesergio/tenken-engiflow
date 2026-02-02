import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';
import 'package:tenken_engiflow/data/models/system_config_model.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';

class SystemConfigurationTab extends StatefulWidget {
  const SystemConfigurationTab({super.key});

  @override
  State<SystemConfigurationTab> createState() => _SystemConfigurationTabState();
}

class _SystemConfigurationTabState extends State<SystemConfigurationTab> {
  int _selectedConfigTab = 0;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        return DefaultTabController(
          length: 3,
          initialIndex: _selectedConfigTab,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.systemConfiguration,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF37474F),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Tab Navigation
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    onTap: (index) {
                      setState(() {
                        _selectedConfigTab = index;
                      });
                    },
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.departments),
                      Tab(text: AppLocalizations.of(context)!.settings),
                      Tab(text: AppLocalizations.of(context)!.notifications),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tab Content
                if (_selectedConfigTab == 0)
                  _buildDepartmentsSection(context, adminProvider)
                else if (_selectedConfigTab == 1)
                  _buildSettingsSection(context, adminProvider)
                else
                  _buildNotificationsSection(context, adminProvider),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildDepartmentsSection(BuildContext context, AdminProvider provider) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAddDepartmentDialog(context, provider),
            icon: const Icon(Icons.add),
            label: Text(AppLocalizations.of(context)!.addDepartment),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        if (provider.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (provider.departments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                AppLocalizations.of(context)!.noDepartments,
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
            itemCount: provider.departments.length,
            itemBuilder: (context, index) {
              final dept = provider.departments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.apartment,
                            color: const Color(0xFF388E3C),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dept.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  dept.description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text('${dept.teamSize} ${AppLocalizations.of(context)!.members}'),
                            backgroundColor: Colors.blue.withOpacity(0.1),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => _showEditDepartmentDialog(context, dept, provider),
                                icon: const Icon(Icons.edit, size: 16),
                                label: Text(AppLocalizations.of(context)!.edit),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
  
  Widget _buildSettingsSection(BuildContext context, AdminProvider provider) {
    if (provider.systemConfig == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final config = provider.systemConfig!;
    
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.companySettings,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: config.companyName,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.companyName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.maintenanceMode),
                  subtitle: Text(
                    AppLocalizations.of(context)!.maintenanceModeDesc,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  value: config.maintenanceMode,
                  onChanged: (value) {
                    // Update maintenance mode
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.systemRoles,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: config.roles.map((role) {
                    return Chip(
                      label: Text(role.toUpperCase()),
                      backgroundColor: const Color(0xFF388E3C).withOpacity(0.1),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNotificationsSection(BuildContext context, AdminProvider provider) {
    if (provider.systemConfig == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final config = provider.systemConfig!;
    
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.notificationSettings,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.enablePushNotifications),
                  value: config.notificationSettings['enablePushNotifications'] ?? true,
                  onChanged: (value) {
                    // Update setting
                  },
                ),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.enableEmailNotifications),
                  value: config.notificationSettings['enableEmailNotifications'] ?? true,
                  onChanged: (value) {
                    // Update setting
                  },
                ),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.enableSmsNotifications),
                  value: config.notificationSettings['enableSmsNotifications'] ?? false,
                  onChanged: (value) {
                    // Update setting
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  void _showAddDepartmentDialog(BuildContext context, AdminProvider provider) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.addDepartment),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.departmentName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                if (nameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.enterDepartmentName)),
                  );
                  return;
                }
                
                final success = await provider.addDepartment(
                  name: nameController.text,
                  description: descController.text,
                  supervisorIds: [],
                );
                
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.departmentAddedSuccess),
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
  }
  
  void _showEditDepartmentDialog(BuildContext context, Department dept, AdminProvider provider) {
    final nameController = TextEditingController(text: dept.name);
    final descController = TextEditingController(text: dept.description);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.editDepartment),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.departmentName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.description,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
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
                final success = await provider.updateDepartment(
                  departmentId: dept.id,
                  name: nameController.text,
                  description: descController.text,
                  supervisorIds: dept.supervisorIds,
                );
                
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.departmentUpdatedSuccess),
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
  }
}
