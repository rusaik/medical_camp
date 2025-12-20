import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:medical_camp_flutter/models/volunteer.dart';
import 'package:medical_camp_flutter/services/appwrite_service.dart';
import 'package:appwrite/models.dart' as models;

import '../main.dart';

class AuthService extends StateNotifier<AsyncValue<models.User?>> {
  AuthService(this._appwriteService) : super(const AsyncValue.loading()) {
    _init();
  }

  final AppwriteService _appwriteService;
  Volunteer? _currentVolunteer;

  // Initialize auth state
  Future<void> _init() async {
    try {
      final user = await _appwriteService.getCurrentUser();
      state = AsyncValue.data(user);

      if (user != null) {
        await _loadVolunteerProfile(user.$id);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  // Load volunteer profile
  Future<void> _loadVolunteerProfile(String userId) async {
    try {
      debugPrint("_loadVolunteerProfile - $userId");
      final docs = await _appwriteService.getDocument(
          collectionId: 'volunteers', documentId: userId
          // queries: [Query.equal('\$id', userId)],
          );
      debugPrint(docs.data.toString());
      debugPrint('loaded from cloud');
      // if (docs.rows.isNotEmpty) {
      //   _currentVolunteer = Volunteer.fromJson(docs.rows.first.data);
      // }
      if (docs.data.isNotEmpty) {
         debugPrint('loaded from cloud assigning ');
        _currentVolunteer = Volunteer.fromJson(docs.data);
      }
      debugPrint("_currentVolunteer.toString()");
      debugPrint(_currentVolunteer.toString());
      debugPrint(_currentVolunteer!.isActive.toString());
    } catch (e) {
      // Volunteer profile might not exist yet (pending approval)
      _currentVolunteer = null;
      debugPrint(e.toString());
    }
  }

  // Sign in
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      await _appwriteService.signIn(email: email, password: password);
      final user = await _appwriteService.getCurrentUser();
      debugPrint(user!.toMap().toString());
      debugPrint("signed in");
      if (user != null) {
        await _loadVolunteerProfile(user.$id);
      }

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Sign up (requires admin approval)
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String department,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Create user account
      final user = await _appwriteService.signUp(
        email: email,
        password: password,
        name: name,
      );
      debugPrint("account created");
      debugPrint(user.toMap().toString());
      debugPrint(user.$id.toString());

      // Create pending volunteer profile
      final volunteerData = {
        '\$id': user.$id,
        'fullName': name,
        'phone': phone,
        'role': 'volunteer',
        'department': department,
        'isActive': false, // Pending approval
        'joinedAt': DateTime.now().toIso8601String(),
      };

      await _appwriteService.createDocument(
        collectionId: 'volunteers',
        data: volunteerData,
      );

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _appwriteService.signOut();
      _currentVolunteer = null;
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  // Update password
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _appwriteService.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Request password reset
  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _appwriteService.requestPasswordReset(email: email);
    } catch (e) {
      rethrow;
    }
  }

  // Get current user
  models.User? get currentUser => state.value;

  // Get current volunteer
  Volunteer? get currentVolunteer => _currentVolunteer;

  // Check if user is authenticated
  bool get isAuthenticated => state.value != null;

  // Check if user is admin
  bool get isAdmin => _currentVolunteer?.isAdmin ?? false;

  // Check if user can write
  bool get canWrite => _currentVolunteer?.canWrite ?? false;

  // Check if volunteer profile is active
  bool get isVolunteerActive => _currentVolunteer?.isActive ?? false;
}

// Provider
final authServiceProvider =
    StateNotifierProvider<AuthService, AsyncValue<models.User?>>((ref) {
  final appwriteService = ref.watch(appwriteServiceProvider);
  return AuthService(appwriteService);
});

// Helper providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authServiceProvider.select((auth) => auth.value != null));
});

final isAdminProvider = Provider<bool>((ref) {
  final auth = ref.watch(authServiceProvider.notifier);
  return auth.isAdmin;
});

final currentVolunteerProvider = Provider<Volunteer?>((ref) {
  final auth = ref.watch(authServiceProvider.notifier);
  return auth.currentVolunteer;
});
