import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/components/task_card.dart';
import 'package:tenken_engiflow/presentation/components/stat_card.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';

class EngineerDashboard extends StatefulWidget {
  final int selectedTab;
  
  const EngineerDashboard({super.key, required this.selectedTab});
  
  @override
  State<EngineerDashboard> createState() => _EngineerDashboardState();
}

class _EngineerDashboardState extends State<EngineerDashboard> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userData = authProvider.userData;
    
    // For now, show a simple dashboard
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF37474F),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.welcome},',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xCCFFFFFF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userData?['displayName'] ?? AppLocalizations.of(context)!.engineer,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        (userData?['role'] ?? AppLocalizations.of(context)!.engineer).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x33FFFFFF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        userData?['department'] ?? AppLocalizations.of(context)!.department,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Stats
          Text(
            AppLocalizations.of(context)!.todayOverview,
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
                title: AppLocalizations.of(context)!.attendance,
                value: AppLocalizations.of(context)!.present,
                icon: Icons.check_circle,
                color: Colors.green,
                subtitle: 'Checked in at 08:30',
              ),
              StatCard(
                title: AppLocalizations.of(context)!.workEntries,
                value: '3/5',
                icon: Icons.assignment,
                color: Colors.blue,
                subtitle: AppLocalizations.of(context)!.tasksCompleted,
              ),
              StatCard(
                title: AppLocalizations.of(context)!.inspections,
                value: '2 ${AppLocalizations.of(context)!.pending}',
                icon: Icons.inventory_2,
                color: Colors.orange,
                subtitle: AppLocalizations.of(context)!.inspectionsDue,
              ),
              StatCard(
                title: AppLocalizations.of(context)!.reports,
                value: '1 ${AppLocalizations.of(context)!.pending}',
                icon: Icons.description,
                color: Colors.purple,
                subtitle: AppLocalizations.of(context)!.reportsPending,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Quick Actions
          Text(
            AppLocalizations.of(context)!.quickActions,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF37474F),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_circle_outline,
                  label: AppLocalizations.of(context)!.newEntry,
                  color: const Color(0xFF37474F),
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.report_problem,
                  label: AppLocalizations.of(context)!.reportIssue,
                  color: Colors.orange,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.assessment,
                  label: AppLocalizations.of(context)!.viewReports,
                  color: Colors.blue,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}