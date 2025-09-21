import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../di/injection_container.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: _redirect,
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
    ],
  );

  static String? _redirect(BuildContext context, GoRouterState state) {
    final authBloc = getIt<AuthBloc>();
    final authState = authBloc.state;

    final isOnAuthPage = [
      '/login',
      '/register',
      '/forgot-password',
      '/phone-login',
      '/otp-verification',
    ].contains(state.uri.toString());

    final isOnOnboardingPage = [
      '/splash',
      '/onboarding',
      '/consent',
    ].contains(state.uri.toString());

    // Check if user is authenticated
    if (authState is AuthSuccess) {
      // User is authenticated
      if (isOnAuthPage || isOnOnboardingPage) {
        return '/home';
      }
      return null; // No redirect needed
    }

    // User is not authenticated
    if (authState is AuthUnauthenticated) {
      if (!isOnAuthPage && !isOnOnboardingPage) {
        return '/login';
      }
      return null; // No redirect needed
    }

    // Loading or initial state
    if (state.uri.toString() == '/splash') {
      return null; // Stay on splash
    }

    return '/splash'; // Default to splash
  }
}

// Placeholder screens that need to be implemented
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
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
              'TravelSync',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Travel Companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
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
