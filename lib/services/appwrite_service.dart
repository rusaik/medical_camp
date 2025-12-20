import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/appwrite.dart' as models;
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:medical_camp_flutter/services/appwrite_config.dart';

class AppwriteService {
  static final AppwriteService _instance = AppwriteService._internal();
  factory AppwriteService() => _instance;
  AppwriteService._internal();

  late final Client client;
  late final Account account;
  //late final Databases databases;
  late final TablesDB tablesDB;
  late final Functions functions;
  late final Storage storage;
  late final Realtime realtime;

  // Initialize Appwrite client
  Future<void> initialize() async {
    try {
      client = Client()
          .setEndpoint(AppwriteConfig.endpoint)
          .setProject(AppwriteConfig.projectId)
          .setDevKey(AppwriteConfig.appwriteEndpointKey)
          .setSelfSigned(status: false);

      account = Account(client);
      tablesDB = TablesDB(client);
      functions = Functions(client);
      storage = Storage(client);
      realtime = Realtime(client);

      debugPrint('Appwrite initialized successfully');
    } catch (e) {
      debugPrint('Error initializing Appwrite: $e');
      rethrow;
    }
  }

  // Authentication methods
  Future<models.User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return user;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  Future<models.Session> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }

  Future<models.User?> getCurrentUser() async {
    try {
      final user = await account.get();
      return user;
    } catch (e) {
      debugPrint('Get current user error: $e');
      return null;
    }
  }

  Future<models.Session?> getCurrentSession() async {
    try {
      final session = await account.getSession(sessionId: 'current');
      return session;
    } catch (e) {
      debugPrint('Get current session error: $e');
      return null;
    }
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await account.updatePassword(
        password: newPassword,
        oldPassword: oldPassword,
      );
    } catch (e) {
      debugPrint('Update password error: $e');
      rethrow;
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    try {
      await account.createRecovery(
        email: email,
        url: 'https://your-app.com/reset-password',
      );
    } catch (e) {
      debugPrint('Password reset error: $e');
      rethrow;
    }
  }

  // Database methods
  Future<models.Row> createDocument({
    required String collectionId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    try {
      final row = await tablesDB.createRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: collectionId,
        rowId: data["\$id"] ?? ID.unique(),
        data: data,
        permissions: permissions,
      );
      return row;
    } catch (e) {
      debugPrint('Create document error: $e');
      rethrow;
    }
  }

  Future<models.Row> getDocument({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      final doc = await tablesDB.getRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: collectionId,
        rowId: documentId,
      );
      return doc;
    } catch (e) {
      debugPrint('Get document error: $e');
      rethrow;
    }
  }

  Future<models.RowList> listDocuments({
    required String collectionId,
    List<String>? queries,
    int? limit,
    int? offset,
    String? cursor,
    String? cursorDirection,
    List<String>? orderAttributes,
    List<String>? orderTypes,
  }) async {
    try {
      final docs = await tablesDB.listRows(
        databaseId: AppwriteConfig.databaseId,
        tableId: collectionId,
        queries: queries,
        /*limit: limit,
        offset: offset,
        cursor: cursor,
        cursorDirection: cursorDirection,
        orderAttributes: orderAttributes,
        orderTypes: orderTypes,*/
      );
      return docs;
    } catch (e) {
      debugPrint('List documents error: $e');
      rethrow;
    }
  }

  Future<models.Row> updateDocument({
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final doc = await tablesDB.updateRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: collectionId,
        rowId: documentId,
        data: data,
      );
      return doc;
    } catch (e) {
      debugPrint('Update document error: $e');
      rethrow;
    }
  }

  Future<void> deleteDocument({
    required String collectionId,
    required String documentId,
  }) async {
    try {
      await tablesDB.deleteRow(
        databaseId: AppwriteConfig.databaseId,
        tableId: collectionId,
        rowId: documentId,
      );
    } catch (e) {
      debugPrint('Delete document error: $e');
      rethrow;
    }
  }

  // Realtime subscriptions
  Stream<models.RealtimeMessage> subscribe({
    required List<String> channels,
  }) {
    try {
      final subscription = realtime.subscribe(channels);
      return subscription.stream;
    } catch (e) {
      debugPrint('Subscribe error: $e');
      rethrow;
    }
  }

  // Functions
  Future<models.Execution> executeFunction({
    required String functionId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final execution = await functions.createExecution(
        functionId: functionId,
        body: data != null ? jsonEncode(data) : null,
      );
      return execution;
    } catch (e) {
      debugPrint('Execute function error: $e');
      rethrow;
    }
  }

  // Utility methods for common queries
  String buildEqualQuery(String attribute, String value) {
    return Query.equal(attribute, value);
  }

  String buildNotEqualQuery(String attribute, String value) {
    return Query.notEqual(attribute, value);
  }

  String buildContainsQuery(String attribute, String value) {
    return Query.search(attribute, value);
  }

  String buildGreaterThanQuery(String attribute, dynamic value) {
    return Query.greaterThan(attribute, value);
  }

  String buildLessThanQuery(String attribute, dynamic value) {
    return Query.lessThan(attribute, value);
  }

  String buildOrderQuery(String attribute, String direction) {
    return Query.orderAsc(attribute);
  }

  String buildLimitQuery(int limit) {
    return Query.limit(limit);
  }

  String buildOffsetQuery(int offset) {
    return Query.offset(offset);
  }

  // Error handling helper
  String getErrorMessage(dynamic error) {
    if (error is AppwriteException) {
      switch (error.code) {
        case 401:
          return 'Unauthorized. Please login again.';
        case 404:
          return 'Resource not found.';
        case 409:
          return 'Resource already exists.';
        case 429:
          return 'Too many requests. Please try again later.';
        default:
          return error.message ?? 'An error occurred.';
      }
    }
    return error.toString();
  }
}
