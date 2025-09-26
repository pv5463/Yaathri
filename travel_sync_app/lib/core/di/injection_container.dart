import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import '../config/app_config.dart';
import '../services/location_service.dart';
import '../services/background_service.dart';
import '../services/monument_scanner_service.dart';
import '../services/google_sign_in_service.dart';
import '../services/camera_permission_service.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../../data/datasources/local/local_data_source.dart';
import '../../data/datasources/remote/remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';
// Model imports removed - will be needed when Hive adapters are generated
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/trip/trip_bloc.dart';
import '../../presentation/blocs/location/location_bloc.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  try {
    // External dependencies
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerLazySingleton(() => sharedPreferences);

    // Hive boxes
    await _initializeHiveBoxes();

    // Network
    getIt.registerLazySingleton(() => Dio());
    getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
    getIt.registerLazySingleton<ApiClient>(() => ApiClient(createDio()));

    // Services
    getIt.registerLazySingleton<LocationService>(() => LocationService());
    getIt.registerLazySingleton<BackgroundService>(() => BackgroundService());
    getIt.registerLazySingleton<MonumentScannerService>(() => MonumentScannerService());
    getIt.registerLazySingleton<GoogleSignInService>(() => GoogleSignInService());
    getIt.registerLazySingleton<CameraPermissionService>(() => CameraPermissionService());

    // Data sources
    getIt.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImpl(
      sharedPreferences: getIt(),
    ));
    getIt.registerLazySingleton<RemoteDataSource>(() => RemoteDataSourceImpl(getIt()));

    // Repositories
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        networkInfo: getIt(),
      ),
    );

    getIt.registerLazySingleton<TripRepository>(
      () => TripRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        networkInfo: getIt(),
      ),
    );

    getIt.registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        networkInfo: getIt(),
      ),
    );

    // BLoCs
    getIt.registerFactory(() => AuthBloc(authRepository: getIt()));
    getIt.registerFactory(() => TripBloc(
          tripRepository: getIt(),
          locationService: getIt(),
        ));
    getIt.registerFactory(() => LocationBloc(locationService: getIt()));

    // Initialize background services (with error handling)
    try {
      await BackgroundService.initialize();
    } catch (e) {
      print('Background service initialization failed: $e');
      // Continue without background services
    }
  } catch (e) {
    print('Dependency initialization error: $e');
    rethrow;
  }
}

Future<void> _initializeHiveBoxes() async {
  try {
    // For now, we'll skip Hive adapter registration to prevent crashes
    // TODO: Generate proper Hive adapters using build_runner
    
    // Open Hive boxes without type adapters for now
    await Hive.openBox(AppConfig.userBox);
    await Hive.openBox(AppConfig.tripBox);
    await Hive.openBox(AppConfig.expenseBox);
    await Hive.openBox(AppConfig.settingsBox);

    // Register boxes with GetIt
    getIt.registerLazySingleton<Box>(
      () => Hive.box(AppConfig.userBox),
      instanceName: AppConfig.userBox,
    );
    getIt.registerLazySingleton<Box>(
      () => Hive.box(AppConfig.tripBox),
      instanceName: AppConfig.tripBox,
    );
    getIt.registerLazySingleton<Box>(
      () => Hive.box(AppConfig.expenseBox),
      instanceName: AppConfig.expenseBox,
    );
    getIt.registerLazySingleton<Box>(
      () => Hive.box(AppConfig.settingsBox),
      instanceName: AppConfig.settingsBox,
    );
  } catch (e) {
    print('Error initializing Hive boxes: $e');
    // Continue without Hive for now
  }
}

// Note: Hive adapters should be generated using build_runner
// Run: flutter packages pub run build_runner build
// This will generate the proper adapters for UserModel, TripModel, ExpenseModel, etc.
