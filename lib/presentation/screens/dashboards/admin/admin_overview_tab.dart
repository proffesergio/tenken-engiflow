import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';
import 'package:tenken_engiflow/presentation/components/stat_card.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';

class AdminOverviewTab extends StatefulWidget {
  const AdminOverviewTab({super.key});

  @override
  State<AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<AdminOverviewTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Welcome Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF388E3C).withOpacity(0.1),
                      const Color(0xFF2E7D32).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF388E3C).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF388E3C).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        size: 32,
                        color: Color(0xFF388E3C),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppLocalizations.of(context)!.admin} ${AppLocalizations.of(context)!.dashboard}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF37474F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.systemManagement,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Statistics Section
              Text(
                AppLocalizations.of(context)!.systemStatistics,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 16),
              
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    title: AppLocalizations.of(context)!.totalUsers,
                    value: '${adminProvider.totalUsers}',
                    icon: Icons.people,
                    color: Colors.blue,
                    subtitle: 'Active',
                  ),
                  StatCard(
                    title: AppLocalizations.of(context)!.totalEngineers,
                    value: '${adminProvider.totalEngineers}',
                    icon: Icons.engineering,
                    color: Colors.orange,
                    subtitle: 'Engineers',
                  ),
                  StatCard(
                    title: AppLocalizations.of(context)!.supervisor,
                    value: '${adminProvider.totalSupervisors}',
                    icon: Icons.supervisor_account,
                    color: Colors.purple,
                    subtitle: 'Supervisors',
                  ),
                  StatCard(
                    title: AppLocalizations.of(context)!.admin,
                    value: '${adminProvider.totalAdmins}',
                    icon: Icons.admin_panel_settings,
                    color: Colors.green,
                    subtitle: 'Admins',
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Recent Activity Section
              Text(
                AppLocalizations.of(context)!.recentActivity,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActivityItem(
                      icon: Icons.person_add,
                      title: 'New User Registration',
                      subtitle: 'Engineer - John Doe',
                      time: '2 hours ago',
                      color: Colors.blue,
                    ),
                    const Divider(height: 16),
                    _buildActivityItem(
                      icon: Icons.edit,
                      title: 'System Configuration Updated',
                      subtitle: 'Admin - System Settings',
                      time: '4 hours ago',
                      color: Colors.green,
                    ),
                    const Divider(height: 16),
                    _buildActivityItem(
                      icon: Icons.delete,
                      title: 'User Removed',
                      subtitle: 'Engineer - Inactive Account',
                      time: '1 day ago',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // System Status Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.systemStatus,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF37474F),
                          ),
                        ),
                        Text(
                          'All systems operational',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
