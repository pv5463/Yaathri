import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/error/error_handler.dart';
import 'core/di/injection_container.dart' as di;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/server_connectivity_manager.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/trip/trip_bloc.dart';
import 'presentation/blocs/location/location_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase removed - using PostgreSQL backend directly
  debugPrint('Yaathri app starting with PostgreSQL backend...');
  // Initialize global error handling
  GlobalErrorHandler.initialize();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Initialize dependency injection
  try {
    await di.initializeDependencies();
    debugPrint('Dependencies initialized successfully');
  } catch (e) {
    debugPrint('Failed to initialize dependencies: $e');
    // Continue app startup even if some dependencies fail
    // This prevents the app from getting stuck on loading screen
  }
  
  // Initialize server connectivity monitoring
  try {
    final connectivityManager = ServerConnectivityManager.instance;
    connectivityManager.startMonitoring();
    debugPrint('Server connectivity monitoring started');
  } catch (e) {
    debugPrint('Failed to start connectivity monitoring: $e');
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const YaathriApp());
}

class YaathriApp extends StatelessWidget {
  const YaathriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => di.getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<TripBloc>(
          create: (context) => di.getIt<TripBloc>(),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => di.getIt<LocationBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Yaathri',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

