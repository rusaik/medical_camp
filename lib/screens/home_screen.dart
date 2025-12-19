import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../providers/patient_provider.dart' hide Patient;
import '../models/patient.dart';
import '../config/constants.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'M';
  final _uuid = const Uuid();
  final String _campId = 'camp_${DateTime.now().toIso8601String().split('T').first}';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _registerPatient() async {
    if (!_formKey.currentState!.validate()) return;

    final patient = Patient(
      id: _uuid.v4(),
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      gender: _selectedGender,
      campId: _campId,
    );

    try {
      await ref.read(patientProvider(_campId).notifier).addPatient(patient);

      // Clear form
      _formKey.currentState!.reset();
      _nameController.clear();
      _ageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient registered ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration saved - will sync soon ⚠️')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientsAsync = ref.watch(patientProvider(_campId));
    final hasPendingSync = ref.watch(syncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Camp Registration'),
        actions: [
          if (hasPendingSync)
            IconButton(
              icon: const Icon(Icons.cloud_sync, color: Colors.orange),
              onPressed: () {},
              tooltip: '${ref.read(appwriteServiceProvider).pendingCount} pending sync',
            )
          else
            IconButton(
              icon: const Icon(Icons.cloud_done, color: Colors.green),
              onPressed: () {},
              tooltip: 'All synced',
            ),
        ],
      ),
      body: Column(
        children: [
          // Registration Form
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Patient Name'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender'),
                      items: const [
                        DropdownMenuItem(value: 'M', child: Text('Male')),
                        DropdownMenuItem(value: 'F', child: Text('Female')),
                        DropdownMenuItem(value: 'O', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _selectedGender = v!),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _registerPatient,
                      child: const Text('Register Patient'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Patient List
          Expanded(
            child: patientsAsync.when(
              data: (patients) => ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(patient.name[0]),
                    ),
                    title: Text(patient.name),
                    subtitle: Text('Age: ${patient.age}, Gender: ${patient.gender}'),
                    trailing: Icon(
                      patient.isSynced ? Icons.check_circle : Icons.pending,
                      color: patient.isSynced ? Colors.green : Colors.orange,
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}