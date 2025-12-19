import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/constants.dart';
import 'providers/patient_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = Client()
      .setEndpoint(AppConstants.endpoint)
      .setProject(AppConstants.projectId)
      .setSelfSigned(status: true);

  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appWriteClientProvider.overrideWithValue(client),
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const MedicalCampApp(),
    ),
  );
}

class MedicalCampApp extends ConsumerWidget {
  const MedicalCampApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Medical Camp Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}