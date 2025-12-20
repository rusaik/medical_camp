import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_camp_flutter/main.dart';
import 'package:medical_camp_flutter/models/patient.dart';
import 'package:medical_camp_flutter/models/vital_signs.dart';
import 'package:medical_camp_flutter/services/appwrite_service.dart';
import 'package:medical_camp_flutter/services/auth_service.dart';
import 'package:medical_camp_flutter/utils/theme.dart';

class VitalSignsScreen extends ConsumerStatefulWidget {
  const VitalSignsScreen({super.key, this.patientId});

  final String? patientId;

  @override
  ConsumerState<VitalSignsScreen> createState() => _VitalSignsScreenState();
}

class _VitalSignsScreenState extends ConsumerState<VitalSignsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _pulseController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();
  
  Patient? _selectedPatient;
  List<Patient> _patients = [];
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _loadPatient(widget.patientId!);
    }
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _temperatureController.dispose();
    _bloodPressureController.dispose();
    _pulseController.dispose();
    _respiratoryRateController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPatient(String patientId) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final doc = await appwriteService.getDocument(
        collectionId: 'patients',
        documentId: patientId,
      );
      
      setState(() {
        _selectedPatient = Patient.fromJson(doc.data);
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load patient: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _loadPatients() async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      final docs = await appwriteService.listDocuments(
        collectionId: 'patients',
        queries: [
          Query.equal('status', 'waiting'),
          Query.orderAsc('priority'),
          Query.orderAsc('registeredAt'),
        ],
      );

      setState(() {
        _patients = docs.rows.map((doc) {
          return Patient.fromJson(doc.data);
        }).toList();
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load patients: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _searchPatient() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      final docs = await appwriteService.listDocuments(
        collectionId: 'patients',
        queries: [
          Query.search('registrationNumber', query),
        //  Query.([
          Query.search('firstName', query), Query.search('lastName', query),
         //Ï ]),
        ],
      );

      if (docs.rows.isEmpty) {
        Fluttertoast.showToast(
          msg: 'No patients found',
          backgroundColor: AppTheme.warningColor,
          textColor: Colors.white,
        );
        return;
      }

      if (docs.rows.length == 1) {
        setState(() {
          _selectedPatient = Patient.fromJson(docs.rows.first.data);
        });
      } else {
        // Show selection dialog for multiple results
        _showPatientSelectionDialog(docs.rows.map((doc) {
          return Patient.fromJson(doc.data);
        }).toList());
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Search failed: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showPatientSelectionDialog(List<Patient> patients) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Patient'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final patient = patients[index];
              return ListTile(
                title: Text(patient.fullName),
                subtitle: Text(patient.registrationNumber),
                trailing: Text('${patient.age} yrs'),
                onTap: () {
                  setState(() {
                    _selectedPatient = patient;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVitalSigns() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedPatient == null) {
      Fluttertoast.showToast(
        msg: 'Please select a patient first',
        backgroundColor: AppTheme.warningColor,
        textColor: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider.notifier);
      final appwriteService = ref.read(appwriteServiceProvider);
      
      final currentUser = authService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final vitalSignsData = {
        'patientId': _selectedPatient!.id,
        'recordedBy': currentUser.$id,
        'recordedAt': DateTime.now().toIso8601String(),
        'temperature': _temperatureController.text.trim().isNotEmpty 
            ? _temperatureController.text.trim() : null,
        'bloodPressure': _bloodPressureController.text.trim().isNotEmpty 
            ? _bloodPressureController.text.trim() : null,
        'pulse': _pulseController.text.trim().isNotEmpty 
            ? int.parse(_pulseController.text.trim()) : null,
        'respiratoryRate': _respiratoryRateController.text.trim().isNotEmpty 
            ? int.parse(_respiratoryRateController.text.trim()) : null,
        'weight': _weightController.text.trim().isNotEmpty 
            ? _weightController.text.trim() : null,
        'height': _heightController.text.trim().isNotEmpty 
            ? _heightController.text.trim() : null,
        'notes': _notesController.text.trim().isNotEmpty 
            ? _notesController.text.trim() : null,
      };

      await appwriteService.createDocument(
        collectionId: 'vital_signs',
        data: vitalSignsData,
      );

      // Update patient status to in_consultation if not already
      if (_selectedPatient!.isWaiting) {
        await appwriteService.updateDocument(
          collectionId: 'patients',
          documentId: _selectedPatient!.id!,
          data: {'status': 'in_consultation'},
        );
      }

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Vital signs recorded successfully!',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );

      // Show success and ask for next action
      _showSuccessDialog();

    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Failed to save vital signs: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            SizedBox(width: 8),
            Text('Vital Signs Recorded'),
          ],
        ),
        content: const Text(
          'Vital signs have been successfully recorded. '
          'What would you like to do next?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Record Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/consultation', extra: _selectedPatient!.id);
            },
            child: const Text('Start Consultation'),
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedPatient = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Vital Signs'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Patient selection section
                const Text(
                  'Select Patient',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (_selectedPatient != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedPatient!.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedPatient = null;
                                  });
                                },
                              ),
                            ],
                          ),
                          Text(
                            'Registration: ${_selectedPatient!.registrationNumber}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            '${_selectedPatient!.age} years old, ${_selectedPatient!.gender}',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          if (_selectedPatient!.phone != null)
                            Text(
                              'Phone: ${_selectedPatient!.phone}',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      // Search by registration number
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                labelText: 'Registration Number',
                                hintText: 'Enter registration number',
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _isSearching ? null : _searchPatient,
                            child: _isSearching
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
                                : const Text('Search'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Or select from waiting list
                      const Text(
                        'Or select from waiting patients:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      if (_patients.isEmpty)
                        const Text('No patients waiting'),
                      
                      for (final patient in _patients.take(5))
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(patient.fullName),
                            subtitle: Text(patient.registrationNumber),
                            trailing: Text('${patient.age} yrs'),
                            onTap: () {
                              setState(() {
                                _selectedPatient = patient;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                
                const SizedBox(height: 24),
                
                // Vital Signs Section
                const Text(
                  'Vital Signs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Temperature and Blood Pressure
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _temperatureController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Temperature',
                          hintText: 'e.g., 98.6°F',
                          prefixIcon: Icon(Icons.thermostat_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _bloodPressureController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Blood Pressure',
                          hintText: 'e.g., 120/80',
                          prefixIcon: Icon(Icons.favorite_outline),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Pulse and Respiratory Rate
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _pulseController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Pulse Rate',
                          hintText: 'beats/min',
                          prefixIcon: Icon(Icons.monitor_heart_outlined),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final pulse = int.tryParse(value);
                            if (pulse == null || pulse < 0 || pulse > 300) {
                              return 'Invalid pulse';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _respiratoryRateController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Respiratory Rate',
                          hintText: 'breaths/min',
                          prefixIcon: Icon(Icons.air_outlined),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final rate = int.tryParse(value);
                            if (rate == null || rate < 0 || rate > 100) {
                              return 'Invalid rate';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Weight and Height
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _weightController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Weight',
                          hintText: 'e.g., 65 kg',
                          prefixIcon: Icon(Icons.monitor_weight_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _heightController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          hintText: 'e.g., 170 cm',
                          prefixIcon: Icon(Icons.height_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes',
                    hintText: 'Any additional observations...',
                    prefixIcon: Icon(Icons.note_outlined),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _resetForm,
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveVitalSigns,
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
                            : const Text('Save Vital Signs'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}