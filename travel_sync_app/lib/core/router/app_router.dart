import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../utils/server_test.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/auth/phone_login_screen.dart';
import '../../presentation/screens/auth/otp_verification_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/onboarding/consent_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/trips/trips_screen.dart';
import '../../presentation/screens/trips/trip_details_screen.dart';
import '../../presentation/screens/trips/start_trip_screen.dart';
import '../../presentation/screens/trips/manual_trip_screen.dart';
import '../../presentation/screens/planning/planning_screen.dart';
import '../../presentation/screens/planning/create_plan_screen.dart';
import '../../presentation/screens/planning/itinerary_screen.dart';
import '../../presentation/screens/expenses/expenses_screen.dart';
import '../../presentation/screens/expenses/add_expense_screen.dart';
import '../../presentation/screens/expenses/expense_details_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/media/camera_screen.dart';
import '../../presentation/screens/media/gallery_screen.dart';
import '../../presentation/screens/monument_scanner/monument_scanner_screen.dart';
import '../../presentation/screens/scanner/qr_scanner_screen.dart';
import '../../presentation/screens/scanner/document_scanner_screen.dart';
import '../../presentation/screens/debug/server_diagnostics_screen.dart';
import '../../presentation/screens/activity/activity_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../di/injection_container.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    // redirect: _redirect, // Temporarily disabled to let splash handle navigation
    routes: [
      // Splash and Onboarding
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/consent',
        builder: (context, state) => const ConsentScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/phone-login',
        builder: (context, state) => const PhoneLoginScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) => OtpVerificationScreen(
          verificationId: state.extra as String? ?? '',
          phoneNumber: state.uri.queryParameters['phone'] ?? '',
        ),
      ),

      // Main App Routes (using the existing HomeScreen structure)
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'start-trip',
            builder: (context, state) => const StartTripScreen(),
          ),
          GoRoute(
            path: 'add-expense',
            builder: (context, state) => const AddExpenseScreen(),
          ),
          GoRoute(
            path: 'add-memory',
            builder: (context, state) => const CameraScreen(),
          ),
        ],
      ),

      // Trips Routes
      GoRoute(
        path: '/trips',
        builder: (context, state) => const TripsScreen(),
        routes: [
          GoRoute(
            path: 'details/:tripId',
            builder: (context, state) => TripDetailsScreen(
              tripId: state.pathParameters['tripId']!,
            ),
          ),
          GoRoute(
            path: 'manual',
            builder: (context, state) => const ManualTripScreen(),
          ),
        ],
      ),

      // Planning Routes
      GoRoute(
        path: '/planning',
        builder: (context, state) => const PlanningScreen(),
        routes: [
          GoRoute(
            path: 'create',
            builder: (context, state) => const CreatePlanScreen(),
          ),
          GoRoute(
            path: 'itinerary/:planId',
            builder: (context, state) => ItineraryScreen(
              planId: state.pathParameters['planId']!,
            ),
          ),
        ],
      ),

      // Expenses Routes
      GoRoute(
        path: '/expenses',
        builder: (context, state) => const ExpensesScreen(),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddExpenseScreen(),
          ),
          GoRoute(
            path: 'details/:expenseId',
            builder: (context, state) => ExpenseDetailsScreen(
              expenseId: state.pathParameters['expenseId']!,
            ),
          ),
        ],
      ),

      // Profile Routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'edit',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),

      // Standalone Routes
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/gallery',
        builder: (context, state) => const GalleryScreen(),
      ),
      GoRoute(
        path: '/monument-scanner',
        builder: (context, state) => const MonumentScannerScreen(),
      ),
      GoRoute(
        path: '/qr-scanner',
        builder: (context, state) => const QRScannerScreen(),
      ),
      GoRoute(
        path: '/document-scanner',
        builder: (context, state) => const DocumentScannerScreen(),
      ),
      
      // Activity and Notifications Routes
      GoRoute(
        path: '/activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      
      // Additional Routes for Home Screen Actions
      GoRoute(
        path: '/plan-trip',
        builder: (context, state) => const CreatePlanScreen(),
      ),
      GoRoute(
        path: '/add-expense',
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: '/add-memory',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/start-trip',
        builder: (context, state) => const StartTripScreen(),
      ),
      
      // Debug Routes
      GoRoute(
        path: '/debug/server',
        builder: (context, state) => const ServerDiagnosticsScreen(),
      ),
    ],
  );

}

// Splash Screen with proper navigation logic
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Test server connectivity and offline mode (non-blocking)
    ServerTest.testServerAndOfflineMode().catchError((e) {
      print('Server test failed: $e');
    });
    
    // Wait for a minimum splash duration
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if user has completed onboarding
    final hasCompletedOnboarding = await _checkOnboardingStatus();
    
    if (!mounted) return;
    
    // Navigate based on onboarding status
    if (hasCompletedOnboarding) {
      // Check authentication status
      try {
        final authBloc = getIt<AuthBloc>();
        final authState = authBloc.state;
        
        print('Current auth state: ${authState.runtimeType}');
        
        if (authState is AuthSuccess) {
          print('User is authenticated, navigating to home');
          context.go('/home');
        } else if (authState is AuthUnauthenticated) {
          print('User is not authenticated, navigating to login');
          context.go('/login');
        } else {
          // AuthInitial or AuthLoading state - default to login
          print('Auth state is initial/loading, navigating to login');
          context.go('/login');
        }
      } catch (e) {
        print('Auth check failed: $e');
        // Fallback to login if auth check fails
        context.go('/login');
      }
    } else {
      context.go('/onboarding');
    }
  }

  Future<bool> _checkOnboardingStatus() async {
    // Check if onboarding has been completed
    // This could be stored in SharedPreferences or Hive
    // For testing purposes, we'll assume onboarding is completed
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.travel_explore,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Yaathri',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Travel Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This will be the content from the home screen we created earlier
    return const Placeholder(child: Text('Home Tab Content'));
  }
}
