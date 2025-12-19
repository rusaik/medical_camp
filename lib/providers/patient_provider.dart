import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/patient.dart';
import '../services/appwrite_service.dart';

// Providers for dependency injection
final appWriteClientProvider = Provider<Client>((ref) => throw UnimplementedError());
final sharedPrefsProvider = Provider<SharedPreferences>((ref) => throw UnimplementedError());

// AppWrite service provider
final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  final client = ref.watch(appWriteClientProvider);
  final prefs = ref.watch(sharedPrefsProvider);
  return AppwriteService(client, prefs);
});

// Patient state management
class PatientNotifier extends StateNotifier<AsyncValue<List<Patient>>> {
  final AppwriteService _service;
  final String campId;

  PatientNotifier(this._service, this.campId) : super(const AsyncValue.loading()) {
    loadPatients();
  }

  Future<void> loadPatients() async {
    state = const AsyncValue.loading();
    try {
      final patients = await _service.getPatients(campId);
      state = AsyncValue.data(patients);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> addPatient(Patient patient) async {
    // Optimistic update: show in UI immediately
    final previousState = state;
    if (state.value != null) {
      state = AsyncValue.data([...state.value!, patient]);
    }

    try {
      await _service.createPatient(patient);
    } catch (e) {
      // Revert on failure
      state = previousState;
      rethrow;
    }
  }
}

// Provider for accessing patients by camp ID
final patientProvider = StateNotifierProvider.family<PatientNotifier, AsyncValue<List<Patient>>, String>(
      (ref, campId) {
    final service = ref.watch(appwriteServiceProvider);
    return PatientNotifier(service, campId);
  },
);

// Sync status indicator provider
final syncStatusProvider = Provider<bool>((ref) {
  final service = ref.watch(appwriteServiceProvider);
  return service.hasPendingSync;
});