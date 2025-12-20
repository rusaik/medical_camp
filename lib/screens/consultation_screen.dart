import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:medical_camp_flutter/main.dart';
import 'package:medical_camp_flutter/models/consultation.dart';
import 'package:medical_camp_flutter/models/patient.dart';
import 'package:medical_camp_flutter/services/appwrite_service.dart';
import 'package:medical_camp_flutter/services/auth_service.dart';
import 'package:medical_camp_flutter/utils/theme.dart';
import 'package:medical_camp_flutter/widgets/template_shortcuts.dart';

class ConsultationScreen extends ConsumerStatefulWidget {
  const ConsultationScreen({super.key, this.patientId});

  final String? patientId;

  @override
  ConsumerState<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends ConsumerState<ConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _chiefComplaintController = TextEditingController();
  final _examinationFindingsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _prescriptionController = TextEditingController();
  final _adviceController = TextEditingController();
  final _referredToController = TextEditingController();
  
  Patient? _selectedPatient;
  List<Patient> _patients = [];
  bool _isLoading = false;
  bool _isSearching = false;
  bool _followUpRequired = false;
  bool _isReferred = false;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    if (widget.patientId != null) {
      _loadPatient(widget.patientId!);
    } else {
      _loadNextPatient();
    }
    _startAutoSave();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chiefComplaintController.dispose();
    _examinationFindingsController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _adviceController.dispose();
    _referredToController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_selectedPatient != null && 
          (_chiefComplaintController.text.isNotEmpty ||
           _examinationFindingsController.text.isNotEmpty ||
           _diagnosisController.text.isNotEmpty)) {
        _autoSaveConsultation();
      }
    });
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
      
      // Load existing consultation if any
      await _loadExistingConsultation(patientId);
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load patient: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _loadNextPatient() async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      
      final docs = await appwriteService.listDocuments(
        collectionId: 'patients',
        queries: [
          Query.equal('status', 'waiting'),
          Query.orderAsc('priority'),
          Query.orderAsc('registeredAt'),
          Query.limit(1),
        ],
      );

      if (docs.rows.isNotEmpty) {
        setState(() {
          _selectedPatient = Patient.fromJson(docs.rows.first.data);
        });
        
        // Load existing consultation if any
        await _loadExistingConsultation(_selectedPatient!.id!);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to load next patient: ${e.toString()}',
        backgroundColor: AppTheme.errorColor,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _loadExistingConsultation(String patientId) async {
    try {
      final appwriteService = ref.read(appwriteServiceProvider);
      final authService = ref.read(authServiceProvider.notifier);
      
      final currentUser = authService.currentUser;
      if (currentUser == null) return;
      
      final docs = await appwriteService.listDocuments(
        collectionId: 'consultations',
        queries: [
          Query.equal('patientId', patientId),
          Query.equal('volunteerId', currentUser.$id),
          Query.isNull('completedAt'),
        ],
      );

      if (docs.rows.isNotEmpty) {
        final consultation = Consultation.fromJson(docs.rows.first.data);
        _populateForm(consultation);
      }
    } catch (e) {
      // No existing consultation or error loading
    }
  }

  void _populateForm(Consultation consultation) {
    _chiefComplaintController.text = consultation.chiefComplaint;
    _examinationFindingsController.text = consultation.examinationFindings ?? '';
    _diagnosisController.text = consultation.diagnosis ?? '';
    _prescriptionController.text = consultation.prescription ?? '';
    _adviceController.text = consultation.advice ?? '';
    _followUpRequired = consultation.followUpRequired;
    _referredToController.text = consultation.referredTo ?? '';
    _isReferred = consultation.referredTo != null;
  }

  Future<void> _autoSaveConsultation() async {
    if (_selectedPatient == null) return;

    try {
      final authService = ref.read(authServiceProvider.notifier);
      final appwriteService = ref.read(appwriteServiceProvider);
      
      final currentUser = authService.currentUser;
      if (currentUser == null) return;

      final consultationData = {
        'patientId': _selectedPatient!.id,
        'volunteerId': currentUser.$id,
        'department': 'General', // This should come from volunteer profile
        'startedAt': DateTime.now().toIso8601String(),
        'chiefComplaint': _chiefComplaintController.text,
        'examinationFindings': _examinationFindingsController.text,
        'diagnosis': _diagnosisController.text,
        'prescription': _prescriptionController.text,
        'advice': _adviceController.text,
        'followUpRequired': _followUpRequired,
        'referredTo': _isReferred ? _referredToController.text : null,
      };

      // Check if consultation exists
      final existingDocs = await appwriteService.listDocuments(
        collectionId: 'consultations',
        queries: [
          Query.equal('patientId', _selectedPatient!.id),
          Query.equal('volunteerId', currentUser.$id),
          Query.isNull('completedAt'),
        ],
      );

      if (existingDocs.rows.isNotEmpty) {
        // Update existing consultation
        await appwriteService.updateDocument(
          collectionId: 'consultations',
          documentId: existingDocs.rows.first.$id,
          data: consultationData,
        );
      } else {
        // Create new consultation
        await appwriteService.createDocument(
          collectionId: 'consultations',
          data: consultationData,
        );
      }
    } catch (e) {
      // Silently fail auto-save
    }
  }

  Future<void> _completeConsultation() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedPatient == null) {
      Fluttertoast.showToast(
        msg: 'No patient selected',
        backgroundColor: AppTheme.warningColor,
        textColor: Colors.white,
      );
      return;
    }

    if (_chiefComplaintController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Chief complaint is required',
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

      // Update patient status
      await appwriteService.updateDocument(
        collectionId: 'patients',
        documentId: _selectedPatient!.id!,
        data: {'status': _isReferred ? 'referred' : 'completed'},
      );

      // Complete consultation
      final consultationData = {
        'completedAt': DateTime.now().toIso8601String(),
        'chiefComplaint': _chiefComplaintController.text,
        'examinationFindings': _examinationFindingsController.text,
        'diagnosis': _diagnosisController.text,
        'prescription': _prescriptionController.text,
        'advice': _adviceController.text,
        'followUpRequired': _followUpRequired,
        'referredTo': _isReferred ? _referredToController.text : null,
      };

      // Find and update consultation
      final docs = await appwriteService.listDocuments(
        collectionId: 'consultations',
        queries: [
          Query.equal('patientId', _selectedPatient!.id),
          Query.equal('volunteerId', currentUser.$id),
          Query.isNull('completedAt'),
        ],
      );

      if (docs.rows.isNotEmpty) {
        await appwriteService.updateDocument(
          collectionId: 'consultations',
          documentId: docs.rows.first.$id,
          data: consultationData,
        );
      }

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Consultation completed successfully!',
        backgroundColor: AppTheme.successColor,
        textColor: Colors.white,
      );

      // Load next patient
      _loadNextPatient();
      _resetForm();

    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(
        msg: 'Failed to complete consultation: ${e.toString()}',
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

  void _resetForm() {
    _chiefComplaintController.clear();
    _examinationFindingsController.clear();
    _diagnosisController.clear();
    _prescriptionController.clear();
    _adviceController.clear();
    _referredToController.clear();
    setState(() {
      _followUpRequired = false;
      _isReferred = false;
    });
  }

  void _insertTemplate(String template) {
    final text = _prescriptionController.text;
    final selection = _prescriptionController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      template,
    );
    _prescriptionController.text = newText;
    _prescriptionController.selection = TextSelection.collapsed(
      offset: selection.start + template.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Consultation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          if (_selectedPatient != null)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                // Show patient history
              },
              tooltip: 'Patient History',
            ),
        ],
      ),
      body: SafeArea(
        child: _selectedPatient == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Patient info header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedPatient!.fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.getPriorityColor(
                                  _selectedPatient!.priority,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                _selectedPatient!.priority.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              _selectedPatient!.registrationNumber,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '${_selectedPatient!.age} years',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _selectedPatient!.gender,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Consultation form
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Chief Complaint
                            TextFormField(
                              controller: _chiefComplaintController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Chief Complaint *',
                                hintText: 'Patient\'s main concern...',
                                prefixIcon: Icon(Icons.description_outlined),
                                alignLabelWithHint: true,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Chief complaint is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Examination Findings
                            TextFormField(
                              controller: _examinationFindingsController,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                labelText: 'Examination Findings',
                                hintText: 'Physical examination results...',
                                prefixIcon: Icon(Icons.search_outlined),
                                alignLabelWithHint: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Diagnosis
                            TextFormField(
                              controller: _diagnosisController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Diagnosis',
                                hintText: 'Primary diagnosis...',
                                prefixIcon: Icon(Icons.medical_services_outlined),
                                alignLabelWithHint: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Prescription with templates
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Prescription',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TemplateShortcuts(
                                  templates: Consultation.prescriptionTemplates,
                                  onTemplateSelected: _insertTemplate,
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _prescriptionController,
                                  maxLines: 6,
                                  decoration: const InputDecoration(
                                    hintText: 'Medications and dosages...',
                                    prefixIcon: Icon(Icons.medication_outlined),
                                    alignLabelWithHint: true,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Advice
                            TextFormField(
                              controller: _adviceController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Advice',
                                hintText: 'Patient instructions and recommendations...',
                                prefixIcon: Icon(Icons.lightbulb_outline),
                                alignLabelWithHint: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Follow-up and referral options
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text('Follow-up Required'),
                                    value: _followUpRequired,
                                    onChanged: (value) {
                                      setState(() {
                                        _followUpRequired = value ?? false;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text('Refer Patient'),
                                    value: _isReferred,
                                    onChanged: (value) {
                                      setState(() {
                                        _isReferred = value ?? false;
                                      });
                                    },
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                            
                            if (_isReferred)
                              TextFormField(
                                controller: _referredToController,
                                decoration: const InputDecoration(
                                  labelText: 'Referred To',
                                  hintText: 'Hospital or specialist...',
                                  prefixIcon: Icon(Icons.local_hospital_outlined),
                                ),
                                validator: (value) {
                                  if (_isReferred && (value == null || value.isEmpty)) {
                                    return 'Please specify referral destination';
                                  }
                                  return null;
                                },
                              ),
                            
                            const SizedBox(height: 32),
                            
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _isLoading ? null : _resetForm,
                                    child: const Text('Reset Form'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _completeConsultation,
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
                                        : const Text('Complete Consultation'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}