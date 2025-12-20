import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:appwrite/appwrite.dart';
import 'package:medical_camp_flutter/main.dart';
import 'package:medical_camp_flutter/models/patient.dart';
import 'package:medical_camp_flutter/services/appwrite_service.dart';
import 'package:medical_camp_flutter/utils/theme.dart';

class PatientQueueScreen extends ConsumerStatefulWidget {
  const PatientQueueScreen({super.key});

  @override
  ConsumerState<PatientQueueScreen> createState() => _PatientQueueScreenState();
}

class _PatientQueueScreenState extends ConsumerState<PatientQueueScreen> {
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  String _selectedPriority = 'all';
  StreamSubscription<RealtimeMessage>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadPatients();
    _subscribeToUpdates();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      // Build query based on filters
      final queries = <String>[];
      if (_selectedStatus != 'all') {
        queries.add(Query.equal('status', _selectedStatus));
      }
      if (_selectedPriority != 'all') {
        queries.add(Query.equal('priority', _selectedPriority));
      }
      if (_searchQuery.isNotEmpty) {
        queries.add(Query.search('firstName', _searchQuery));
      }
      
      // Add ordering
      queries.add(Query.orderAsc('priority'));
      queries.add(Query.orderAsc('registeredAt'));
      
      final docs = await appwriteService.listDocuments(
        collectionId: 'patients',
        queries: queries,
      );

      setState(() {
        _patients = docs.rows.map((doc) {
          return Patient.fromJson(doc.data);
        }).toList();
        _filteredPatients = _patients;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      Fluttertoast.showToast(
        msg: 'Failed to load patients: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  void _subscribeToUpdates() {
    final appwriteService = ref.read(appwriteServiceProvider);
    
    _subscription = appwriteService.subscribe(
      channels: ['databases.medical_camp_db.collections.patients.documents'],
    ).listen((message) {
      // Handle real-time updates
      if (message.events.contains('databases.*.collections.patients.documents.*.create') ||
          message.events.contains('databases.*.collections.patients.documents.*.update') ||
          message.events.contains('databases.*.collections.patients.documents.*.delete')) {
        _loadPatients();
        
        // Show notification for new patients
        if (message.events.contains('*.create')) {
          final patientData = message.payload;
          Fluttertoast.showToast(
            msg: 'New patient registered: ${patientData['firstName']} ${patientData['lastName']}',
            backgroundColor: AppTheme.infoColor,
            textColor: Colors.white,
          );
        }
      }
    });
  }

  void _filterPatients() {
    setState(() {
      _filteredPatients = _patients.where((patient) {
        // Filter by status
        if (_selectedStatus != 'all' && patient.status != _selectedStatus) {
          return false;
        }
        
        // Filter by priority
        if (_selectedPriority != 'all' && patient.priority != _selectedPriority) {
          return false;
        }
        
        // Filter by search query
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final fullName = patient.fullName.toLowerCase();
          final regNumber = patient.registrationNumber.toLowerCase();
          
          if (!fullName.contains(query) && !regNumber.contains(query)) {
            return false;
          }
        }
        
        return true;
      }).toList();
    });
  }

  Future<void> _updatePatientStatus(Patient patient, String newStatus) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      await appwriteService.updateDocument(
        collectionId: 'patients',
        documentId: patient.id!,
        data: {'status': newStatus},
      );
      
      Fluttertoast.showToast(
        msg: 'Patient status updated',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update status: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  void _showPatientDetails(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Patient Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(
                label: 'Registration',
                value: patient.registrationNumber,
              ),
              _DetailRow(
                label: 'Name',
                value: patient.fullName,
              ),
              _DetailRow(
                label: 'Age',
                value: '${patient.age} years',
              ),
              _DetailRow(
                label: 'Gender',
                value: patient.gender == 'M' ? 'Male' : 
                       patient.gender == 'F' ? 'Female' : 'Other',
              ),
              if (patient.phone != null)
                _DetailRow(
                  label: 'Phone',
                  value: patient.phone!,
                ),
              _DetailRow(
                label: 'Address',
                value: patient.address,
              ),
              _DetailRow(
                label: 'Priority',
                value: patient.priority.toUpperCase(),
                valueColor: AppTheme.getPriorityColor(patient.priority),
              ),
              _DetailRow(
                label: 'Status',
                value: patient.status.replaceAll('_', ' ').toUpperCase(),
                valueColor: AppTheme.getStatusColor(patient.status),
              ),
              _DetailRow(
                label: 'Wait Time',
                value: patient.formattedWaitTime,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (patient.isWaiting)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/vital-signs', extra: patient.id);
              },
              child: const Text('Record Vitals'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Queue'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPatients,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters section
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                // Search field
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search patients',
                    hintText: 'Search by name or registration',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _filterPatients();
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Status and Priority filters
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Status')),
                          DropdownMenuItem(value: 'waiting', child: Text('Waiting')),
                          DropdownMenuItem(value: 'in_consultation', child: Text('In Consultation')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'referred', child: Text('Referred')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                            _filterPatients();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Priority')),
                          DropdownMenuItem(value: 'routine', child: Text('Routine')),
                          DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                          DropdownMenuItem(value: 'emergency', child: Text('Emergency')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                            _filterPatients();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Patient count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Showing ${_filteredPatients.length} of ${_patients.length} patients',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          
          // Patient list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPatients.isEmpty
                    ? const Center(
                        child: Text('No patients found'),
                      )
                    : ListView.builder(
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return _PatientCard(
                            patient: patient,
                            onTap: () => _showPatientDetails(patient),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/register-patient'),
        icon: const Icon(Icons.person_add),
        label: const Text('Register Patient'),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({
    required this.patient,
    required this.onTap,
  });

  final Patient patient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      patient.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getPriorityColor(patient.priority)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      patient.priority.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getPriorityColor(patient.priority),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    patient.registrationNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${patient.age} yrs',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    patient.gender,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getStatusColor(patient.status)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      patient.status.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getStatusColor(patient.status),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    patient.formattedWaitTime,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}