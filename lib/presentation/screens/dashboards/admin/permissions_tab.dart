import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';

class PermissionsTab extends StatefulWidget {
  const PermissionsTab({super.key});

  @override
  State<PermissionsTab> createState() => _PermissionsTabState();
}

class _PermissionsTabState extends State<PermissionsTab> {
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
                AppLocalizations.of(context)!.rolePermissions,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 16),
              
              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border.all(color: Colors.blue[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.permissionsDesc,
                        style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Engineer Role
              _buildRoleCard(
                context,
                'Engineer',
                Icons.engineering,
                Colors.orange,
                [
                  'View own tasks',
                  'Update task status',
                  'View own attendance',
                  'Submit reports',
                  'View own profile',
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Supervisor Role
              _buildRoleCard(
                context,
                'Supervisor',
                Icons.supervisor_account,
                Colors.purple,
                [
                  'Manage team members',
                  'Assign tasks',
                  'Approve task completion',
                  'Update attendance records',
                  'Generate team reports',
                  'View team performance',
                  'Manage task approvals',
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Admin Role
              _buildRoleCard(
                context,
                'Admin',
                Icons.admin_panel_settings,
                Colors.green,
                [
                  'Manage all users',
                  'Manage system configuration',
                  'Manage roles & permissions',
                  'View system reports',
                  'Manage departments',
                  'System maintenance',
                  'Audit logs',
                  'Backup & restore',
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Permission Matrix
              _buildPermissionMatrix(context),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildRoleCard(
    BuildContext context,
    String roleName,
    IconData icon,
    Color color,
    List<String> permissions,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    roleName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF37474F),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: permissions.map((permission) {
                return Chip(
                  avatar: Icon(Icons.check, size: 16, color: color),
                  label: Text(permission, style: TextStyle(color: color)),
                  backgroundColor: color.withOpacity(0.1),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _showEditPermissionsDialog(context, roleName),
                icon: const Icon(Icons.edit, size: 16),
                label: Text(AppLocalizations.of(context)!.editPermissions),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPermissionMatrix(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.permissionMatrix,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF37474F),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text(AppLocalizations.of(context)!.action)),
                  DataColumn(label: Center(child: Text('Engineer'))),
                  DataColumn(label: Center(child: Text('Supervisor'))),
                  DataColumn(label: Center(child: Text('Admin'))),
                ],
                rows: [
                  _buildPermissionRow('View', false, true, true),
                  _buildPermissionRow('Create', false, true, true),
                  _buildPermissionRow('Edit', false, true, true),
                  _buildPermissionRow('Delete', false, false, true),
                  _buildPermissionRow('Approve', false, true, true),
                  _buildPermissionRow('Admin', false, false, true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  DataRow _buildPermissionRow(String action, bool engineer, bool supervisor, bool admin) {
    return DataRow(
      cells: [
        DataCell(Text(action)),
        DataCell(
          Center(
            child: Icon(
              engineer ? Icons.check_circle : Icons.cancel,
              color: engineer ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Icon(
              supervisor ? Icons.check_circle : Icons.cancel,
              color: supervisor ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ),
        DataCell(
          Center(
            child: Icon(
              admin ? Icons.check_circle : Icons.cancel,
              color: admin ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
  
  void _showEditPermissionsDialog(BuildContext context, String roleName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${AppLocalizations.of(context)!.editPermissions} - $roleName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('View'),
                ),
                CheckboxListTile(
                  value: true,
                  onChanged: (_) {},
                  title: const Text('Create'),
                ),
                CheckboxListTile(
                  value: roleName != 'Engineer',
                  onChanged: (_) {},
                  title: const Text('Edit'),
                ),
                CheckboxListTile(
                  value: roleName == 'Admin',
                  onChanged: (_) {},
                  title: const Text('Delete'),
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
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.permissionsUpdated),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
              ),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        );
      },
    );
  }
}
