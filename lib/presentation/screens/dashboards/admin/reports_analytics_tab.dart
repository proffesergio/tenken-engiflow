import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/admin_provider.dart';
import 'package:tenken_engiflow/presentation/components/stat_card.dart';
import 'package:tenken_engiflow/l10n/app_localizations.dart';

class ReportsAnalyticsTab extends StatefulWidget {
  const ReportsAnalyticsTab({super.key});

  @override
  State<ReportsAnalyticsTab> createState() => _ReportsAnalyticsTabState();
}

class _ReportsAnalyticsTabState extends State<ReportsAnalyticsTab> {
  DateTimeRange _selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );
  
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
                AppLocalizations.of(context)!.reportsAnalytics,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 16),
              
              // Date Range Picker
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.dateRange,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_selectedDateRange.start.day}/${_selectedDateRange.start.month} - ${_selectedDateRange.end.day}/${_selectedDateRange.end.month}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _selectDateRange(context),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(AppLocalizations.of(context)!.select),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Key Metrics
              Text(
                AppLocalizations.of(context)!.keyMetrics,
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
                    subtitle: 'Active users',
                  ),
                  StatCard(
                    title: 'Avg. Attendance',
                    value: '94%',
                    icon: Icons.event_available,
                    color: Colors.green,
                    subtitle: 'This month',
                  ),
                  StatCard(
                    title: 'Task Completion',
                    value: '87%',
                    icon: Icons.task_alt,
                    color: Colors.orange,
                    subtitle: 'On time',
                  ),
                  StatCard(
                    title: 'Departments',
                    value: '${adminProvider.departments.length}',
                    icon: Icons.apartment,
                    color: Colors.purple,
                    subtitle: 'Active',
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Department Performance
              Text(
                AppLocalizations.of(context)!.departmentPerformance,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF37474F),
                ),
              ),
              const SizedBox(height: 16),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPerformanceRow(
                        'Mechanical',
                        92,
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildPerformanceRow(
                        'Electrical',
                        88,
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildPerformanceRow(
                        'Civil',
                        85,
                        Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildPerformanceRow(
                        'Structural',
                        90,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Export Options
              Text(
                AppLocalizations.of(context)!.exportReport,
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
                    child: ElevatedButton.icon(
                      onPressed: () => _showExportDialog(context, 'PDF'),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showExportDialog(context, 'Excel'),
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Excel'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildPerformanceRow(String name, int percentage, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }
  
  void _showExportDialog(BuildContext context, String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting report as $format...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
