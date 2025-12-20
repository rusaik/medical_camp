import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_camp_flutter/main.dart';
import 'package:medical_camp_flutter/services/appwrite_service.dart';
import 'package:medical_camp_flutter/utils/theme.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _selectedReportType = 'summary';
  bool _isLoading = false;
  Map<String, dynamic>? _reportData;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _generateReport() async {
    if (_startDate.isAfter(_endDate)) {
      Fluttertoast.showToast(
        msg: 'Start date must be before end date',
        backgroundColor: AppTheme.warningColor,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      final result = await appwriteService.executeFunction(
        functionId: 'generateReport',
        data: {
          'reportType': _selectedReportType,
          'startDate': _startDate.toIso8601String(),
          'endDate': _endDate.toIso8601String(),
        },
      );

      if (result.responseBody.isNotEmpty) {
        final responseData = jsonDecode(result.responseBody);
        setState(() {
          _reportData = responseData;
        });
      }

      Fluttertoast.showToast(
        msg: 'Report generated successfully',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to generate report: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToCSV() async {
    if (_reportData == null) {
      Fluttertoast.showToast(
        msg: 'Please generate a report first',
        backgroundColor: AppTheme.warningColor,
        textColor: Colors.white,
      );
      return;
    }

    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      final result = await appwriteService.executeFunction(
        functionId: 'exportToCSV',
        data: {
          'reportType': _selectedReportType,
          'startDate': _startDate.toIso8601String(),
          'endDate': _endDate.toIso8601String(),
        },
      );

      Fluttertoast.showToast(
        msg: 'Export completed. Check your downloads.',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Export failed: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  Widget _buildSummaryReport() {
    if (_reportData == null) {
      return const Center(child: Text('No data available'));
    }

    final data = _reportData!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Key metrics
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Total Patients',
                value: data['totalPatients']?.toString() ?? '0',
                icon: Icons.people_outline,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                title: 'Completed',
                value: data['completed']?.toString() ?? '0',
                icon: Icons.check_circle_outline,
                color: AppTheme.successColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'In Progress',
                value: data['inProgress']?.toString() ?? '0',
                icon: Icons.access_time,
                color: AppTheme.infoColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                title: 'Referred',
                value: data['referred']?.toString() ?? '0',
                icon: Icons.forward,
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        
        // Priority distribution chart
        const Text(
          'Priority Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: AppTheme.priorityRoutine,
                  value: data['routine']?.toDouble() ?? 0,
                  title: 'Routine\n${data['routine'] ?? 0}',
                  radius: 50,
                ),
                PieChartSectionData(
                  color: AppTheme.priorityUrgent,
                  value: data['urgent']?.toDouble() ?? 0,
                  title: 'Urgent\n${data['urgent'] ?? 0}',
                  radius: 50,
                ),
                PieChartSectionData(
                  color: AppTheme.priorityEmergency,
                  value: data['emergency']?.toDouble() ?? 0,
                  title: 'Emergency\n${data['emergency'] ?? 0}',
                  radius: 50,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        
        // Department breakdown
        const Text(
          'Department Breakdown',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (data['departments'] != null)
          ...data['departments'].entries.map((entry) {
            return _DepartmentRow(
              department: entry.key,
              count: entry.value.toString(),
            );
          }),
      ],
    );
  }

  Widget _buildVolunteerActivityReport() {
    if (_reportData == null) {
      return const Center(child: Text('No data available'));
    }

    final data = _reportData!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Volunteer Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (data['volunteers'] != null)
          ...data['volunteers'].entries.map((entry) {
            return _VolunteerRow(
              name: entry.key,
              patientsSeen: entry.value['patients']?.toString() ?? '0',
              hoursWorked: entry.value['hours']?.toString() ?? '0',
            );
          }),
      ],
    );
  }

  Widget _buildMedicationsReport() {
    if (_reportData == null) {
      return const Center(child: Text('No data available'));
    }

    final data = _reportData!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Most Dispensed Medications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (data['medications'] != null)
          ...data['medications'].entries.map((entry) {
            return _MedicationRow(
              medication: entry.key,
              count: entry.value.toString(),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range selector
              const Text(
                'Select Date Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Report type selector
              DropdownButtonFormField<String>(
                value: _selectedReportType,
                decoration: const InputDecoration(
                  labelText: 'Report Type',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'summary',
                    child: Text('Patient Summary'),
                  ),
                  DropdownMenuItem(
                    value: 'volunteers',
                    child: Text('Volunteer Activity'),
                  ),
                  DropdownMenuItem(
                    value: 'medications',
                    child: Text('Medications Report'),
                  ),
                  DropdownMenuItem(
                    value: 'demographics',
                    child: Text('Demographics'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedReportType = value!;
                    _reportData = null;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Generate button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _generateReport,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Generate Report'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: _exportToCSV,
                    icon: const Icon(Icons.download),
                    label: const Text('Export CSV'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Report content
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_reportData != null)
                _buildReportContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    switch (_selectedReportType) {
      case 'summary':
        return _buildSummaryReport();
      case 'volunteers':
        return _buildVolunteerActivityReport();
      case 'medications':
        return _buildMedicationsReport();
      case 'demographics':
        return _buildDemographicsReport();
      default:
        return const Center(child: Text('Unknown report type'));
    }
  }

  Widget _buildDemographicsReport() {
    if (_reportData == null) {
      return const Center(child: Text('No data available'));
    }

    final data = _reportData!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Age Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (data['ageGroups'] != null)
          ...data['ageGroups'].entries.map((entry) {
            return _AgeGroupRow(
              ageGroup: entry.key,
              count: entry.value.toString(),
            );
          }),
        
        const SizedBox(height: 32),
        
        const Text(
          'Gender Distribution',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Male',
                value: data['male']?.toString() ?? '0',
                icon: Icons.male,
                color: AppTheme.infoColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                title: 'Female',
                value: data['female']?.toString() ?? '0',
                icon: Icons.female,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MetricCard(
                title: 'Other',
                value: data['other']?.toString() ?? '0',
                icon: Icons.transgender,
                color: AppTheme.warningColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentRow extends StatelessWidget {
  const _DepartmentRow({
    required this.department,
    required this.count,
  });

  final String department;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(department),
          ),
          Text(
            count,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerRow extends StatelessWidget {
  const _VolunteerRow({
    required this.name,
    required this.patientsSeen,
    required this.hoursWorked,
  });

  final String name;
  final String patientsSeen;
  final String hoursWorked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(name),
          ),
          Text(
            '$patientsSeen patients',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$hoursWorked hrs',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationRow extends StatelessWidget {
  const _MedicationRow({
    required this.medication,
    required this.count,
  });

  final String medication;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(medication),
          ),
          Text(
            count,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeGroupRow extends StatelessWidget {
  const _AgeGroupRow({
    required this.ageGroup,
    required this.count,
  });

  final String ageGroup;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(ageGroup),
          ),
          Text(
            count,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}