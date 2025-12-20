import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:appwrite/appwrite.dart';
import 'package:medical_camp_flutter/services/appwrite_service.dart';
import 'package:medical_camp_flutter/services/auth_service.dart';
import 'package:medical_camp_flutter/screens/login_screen.dart';
import 'package:medical_camp_flutter/screens/registration_screen.dart';
import 'package:medical_camp_flutter/screens/dashboard_screen.dart';
import 'package:medical_camp_flutter/screens/patient_registration_screen.dart';
import 'package:medical_camp_flutter/screens/patient_queue_screen.dart';
import 'package:medical_camp_flutter/screens/vital_signs_screen.dart';
import 'package:medical_camp_flutter/screens/consultation_screen.dart';
import 'package:medical_camp_flutter/screens/reports_screen.dart';
import 'package:medical_camp_flutter/screens/volunteer_management_screen.dart';
import 'package:medical_camp_flutter/screens/profile_screen.dart';
import 'package:medical_camp_flutter/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Appwrite
  final appwriteService = AppwriteService();
  await appwriteService.initialize();
  
  runApp(
    ProviderScope(
      overrides: [
        appwriteServiceProvider.overrideWithValue(appwriteService),
      ],
      child: const MedicalCampApp(),
    ),
  );
}

// Appwrite service provider
final appwriteServiceProvider = Provider<AppwriteService>((ref) {
  throw UnimplementedError('AppwriteService must be overridden');
});

// Router configuration
final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider.notifier);
  
  return GoRouter(
    initialLocation: '/login',
   //Ï refreshListenable: _AuthNotifier(authService),
    redirect: (context, state) {
      final isAuthenticated = authService.isAuthenticated;
      final isVolunteerActive = authService.isVolunteerActive;
      
      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToRegister = state.matchedLocation == '/register';
      
      // If not authenticated and not going to login/register, redirect to login
      if (!isAuthenticated && !isGoingToLogin && !isGoingToRegister) {
        return '/login';
      }
      
      // If authenticated but volunteer profile not active (pending approval)
      if (isAuthenticated && !isVolunteerActive && !isGoingToLogin) {
        return '/login';
      }
      
      // If authenticated and going to login/register, redirect to dashboard
      if (isAuthenticated && isVolunteerActive && (isGoingToLogin || isGoingToRegister)) {
        return '/';
      }
      
      return null;
    },
    routes: [
      // Login route
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Registration route
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegistrationScreen(),
      ),
      
      // Dashboard (home)
      GoRoute(
        path: '/',
        builder: (context, state) => const DashboardScreen(),
        routes: [
          // Patient registration
          GoRoute(
            path: 'register-patient',
            builder: (context, state) => const PatientRegistrationScreen(),
          ),
          
          // Patient queue
          GoRoute(
            path: 'patient-queue',
            builder: (context, state) => const PatientQueueScreen(),
          ),
          
          // Vital signs
          GoRoute(
            path: 'vital-signs',
            builder: (context, state) {
              final patientId = state.extra as String?;
              return VitalSignsScreen(patientId: patientId);
            },
          ),
          
          // Consultation
          GoRoute(
            path: 'consultation',
            builder: (context, state) {
              final patientId = state.extra as String?;
              return ConsultationScreen(patientId: patientId);
            },
          ),
          
          // Reports
          GoRoute(
            path: 'reports',
            builder: (context, state) => const ReportsScreen(),
          ),
          
          // Volunteer management (admin only)
          GoRoute(
            path: 'volunteers',
            builder: (context, state) => const VolunteerManagementScreen(),
          ),
          
          // Profile
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

// Auth notifier for router refresh
/*class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(this._authService) {
    _authService.addListener(_onAuthChanged);
  }
  
  final AuthService _authService;
  
  void _onAuthChanged() {
    notifyListeners();
  }
  
  @override
  void dispose() {
    _authService.removeListener(_onAuthChanged);
    super.dispose();
  }
}*/

class MedicalCampApp extends ConsumerWidget {
  const MedicalCampApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Medical Camp Management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}