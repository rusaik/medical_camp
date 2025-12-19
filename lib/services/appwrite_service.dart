import 'package:appwrite/appwrite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/patient.dart';
import '../config/constants.dart';

class AppwriteService {
  final Client client;
  final SharedPreferences prefs;
  late final Databases databases;
  late final Realtime realtime;

  // In-memory retry queue
  final List<Map<String, dynamic>> _retryQueue = [];
  Timer? _retryTimer;
  bool _isProcessingQueue = false;

  AppwriteService(this.client, this.prefs) {
    databases = Databases(client);
    realtime = Realtime(client);
    _loadQueueFromPrefs();
    _startRetryTimer();
  }

  // Load queue from SharedPreferences on app start
  void _loadQueueFromPrefs() {
    final String? queueData = prefs.getString('sync_queue');
    if (queueData != null) {
      final List<dynamic> decoded = jsonDecode(queueData);
      _retryQueue.addAll(decoded.map((e) => Map<String, dynamic>.from(e)));
    }
  }

  // Save queue to SharedPreferences for persistence
  Future<void> _saveQueueToPrefs() async {
    await prefs.setString('sync_queue', jsonEncode(_retryQueue));
  }

  // Create patient - fire and forget
  Future<void> createPatient(Patient patient) async {
    try {
      // Immediately add to local queue for optimistic UI
      _addToQueue('create', patient);

      // Try to sync to AppWrite
      await databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.patientsCollectionId,
        documentId: patient.id ?? ID.unique(),
        data: patient.toDocumentData(),
      );

      // Remove from queue on success
      _removeFromQueue(patient.id!);
    } catch (e) {
      // Network failed - stays in queue for retry
      throw Exception('Sync pending - will auto-retry');
    }
  }

  // Add operation to queue
  void _addToQueue(String operation, Patient patient) {
    _retryQueue.add({
      'operation': operation,
      'data': patient.toJson(),
      'timestamp': DateTime.now().toIso8601String(),
    });
    _saveQueueToPrefs();
  }

  // Remove from queue on success
  void _removeFromQueue(String patientId) {
    _retryQueue.removeWhere((item) => item['data']['id'] == patientId);
    _saveQueueToPrefs();
  }

  // Start background retry timer
  void _startRetryTimer() {
    _retryTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_retryQueue.isEmpty) return;
      if (_isProcessingQueue) return;

      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) return;

      await _processRetryQueue();
    });
  }

  // Process all pending operations
  Future<void> _processRetryQueue() async {
    _isProcessingQueue = true;

    try {
      for (var item in List.from(_retryQueue)) {
        try {
          final Patient patient = Patient.fromJson(item['data']);

          switch (item['operation']) {
            case 'create':
              await databases.createDocument(
                databaseId: AppConstants.databaseId,
                collectionId: AppConstants.patientsCollectionId,
                documentId: patient.id ?? ID.unique(),
                data: patient.toDocumentData(),
              );
              break;
          }

          _removeFromQueue(patient.id!);
        } catch (e) {
          // Individual item failed - skip and retry next cycle
          continue;
        }
      }
    } finally {
      _isProcessingQueue = false;
    }
  }

  // Get all patients from AppWrite
  Future<List<Patient>> getPatients(String campId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.patientsCollectionId,
        queries: [Query.equal('camp_id', campId)],
      );

      return response.documents.map((doc) => Patient.fromDocument(doc.toMap())).toList();
    } catch (e) {
      return []; // Return empty on failure - UI handles gracefully
    }
  }

  // Realtime subscription for web dashboard
  Stream<RealtimeMessage> subscribeToPatients() {
    return realtime.subscribe([
      'databases.${AppConstants.databaseId}.collections.${AppConstants.patientsCollectionId}.documents'
    ]).stream;
  }

  // Check sync status
  bool get hasPendingSync => _retryQueue.isNotEmpty;
  int get pendingCount => _retryQueue.length;

  void dispose() {
    _retryTimer?.cancel();
  }
}