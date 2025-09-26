import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
import '../../core/services/offline_service.dart';
import '../../core/services/server_connectivity_manager.dart';
import '../../core/services/google_sign_in_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_data_source.dart';
import '../datasources/remote/remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final RemoteDataSource remoteDataSource;
  final LocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserModel>> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    print('\n🔐 === AUTHENTICATION ATTEMPT ===');
    print('Email: $email');
    
    // Check server connectivity first
    final connectivityManager = ServerConnectivityManager.instance;
    final isServerAvailable = await connectivityManager.checkConnectivity();
    
    if (isServerAvailable && connectivityManager.workingServerUrl != null) {
      try {
        print('🌐 Attempting online authentication...');
        final user = await remoteDataSource.login({
          'email': email,
          'password': password,
        });
        await localDataSource.cacheUser(user);
        print('✅ Online authentication successful');
        return Right(user);
      } on ServerException catch (e) {
        print('❌ Server authentication failed: ${e.message}');
        print('🔄 Falling back to offline mode...');
        return _attemptOfflineLogin(email, password);
      } catch (e) {
        print('❌ Unexpected authentication error: $e');
        return _attemptOfflineLogin(email, password);
      }
    } else {
      print('📱 Server unavailable, using offline mode...');
      return _attemptOfflineLogin(email, password);
    }
  }
  
  Future<Either<Failure, UserModel>> _attemptOfflineLogin(String email, String password) async {
    try {
      OfflineService.enableOfflineMode();
      final mockResponse = await OfflineService.mockLogin(email, password);
      
      if (mockResponse['success'] == true) {
        final user = UserModel.fromJson(mockResponse['user']);
        await localDataSource.cacheUser(user);
        return Right(user);
      } else {
        return Left(AuthFailure(message: mockResponse['message']));
      }
    } catch (e) {
      return Left(AuthFailure(message: 'Offline login failed: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    List<String> travelPreferences = const [],
    required bool consentGiven,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.register({
          'email': email,
          'password': password,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'travelPreferences': travelPreferences,
          'consentGiven': consentGiven,
        });
        await localDataSource.cacheUser(user);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> loginWithGoogle() async {
    print('\n🔐 === GOOGLE SIGN-IN ATTEMPT ===');
    
    try {
      // First, authenticate with Google
      final googleSignInService = GoogleSignInService();
      final googleResult = await googleSignInService.signInWithGoogle();
      
      return googleResult.fold(
        (failure) {
          print('❌ Google Sign-In failed: ${failure.message}');
          return Left(failure);
        },
        (googleData) async {
          print('✅ Google Sign-In successful, attempting backend authentication...');
          
          // Check server connectivity
          final connectivityManager = ServerConnectivityManager.instance;
          final isServerAvailable = await connectivityManager.checkConnectivity();
          
          if (isServerAvailable && connectivityManager.workingServerUrl != null) {
            try {
              print('🌐 Attempting backend authentication with data: ${googleData.keys.join(', ')}');
              // Try to authenticate with backend using Google credentials
              final user = await remoteDataSource.socialLogin(googleData);
              await localDataSource.cacheUser(user);
              print('✅ Backend authentication successful');
              return Right(user);
            } on ServerException catch (e) {
              print('❌ Backend authentication failed: ${e.message}');
              print('📊 Server response details: ${e.toString()}');
              print('🔄 Creating offline user from Google data...');
              return _createOfflineUserFromGoogle(googleData);
            } catch (e) {
              print('❌ Unexpected backend error: $e');
              print('🔄 Falling back to offline mode...');
              return _createOfflineUserFromGoogle(googleData);
            }
          } else {
            print('📱 Server unavailable, creating offline user from Google data...');
            return _createOfflineUserFromGoogle(googleData);
          }
        },
      );
    } catch (e) {
      print('❌ Unexpected Google Sign-In error: $e');
      return Left(AuthFailure(message: 'Google Sign-In failed: $e'));
    }
  }
  
  Future<Either<Failure, UserModel>> _createOfflineUserFromGoogle(Map<String, dynamic> googleData) async {
    try {
      OfflineService.enableOfflineMode();
      
      // Extract user data from the nested structure
      final userData = googleData['userData'] as Map<String, dynamic>? ?? {};
      
      // Create a user model from Google data
      final user = UserModel(
        id: userData['id'] ?? 'google_${DateTime.now().millisecondsSinceEpoch}',
        email: userData['email'] ?? '',
        fullName: userData['name'] ?? 'Google User',
        profileImageUrl: userData['picture'],
        consentGiven: true, // Assumed for Google sign-in
        isVerified: true, // Google accounts are verified
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await localDataSource.cacheUser(user);
      print('✅ Offline Google user created successfully');
      return Right(user);
    } catch (e) {
      print('❌ Failed to create offline Google user: $e');
      return Left(AuthFailure(message: 'Failed to create offline user: $e'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> loginWithApple() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.socialLogin({
          'provider': 'apple',
        });
        await localDataSource.cacheUser(user);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> loginWithFacebook() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.socialLogin({
          'provider': 'facebook',
        });
        await localDataSource.cacheUser(user);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> loginWithPhone({
    required String phoneNumber,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.phoneLogin({
          'phone_number': phoneNumber,
        });
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.verifyOtp({
          'verification_id': verificationId,
          'otp': otp,
        });
        await localDataSource.cacheUser(user);
        return Right(user);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String email,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.forgotPassword({
          'email': email,
        });
        return Right(result);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.resetPassword({
          'token': token,
          'new_password': newPassword,
        });
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.logout();
      }
      await localDataSource.clearUserCache();
      await localDataSource.clearAuthToken();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      // First try to get from cache
      final cachedUser = await localDataSource.getCachedUser();
      
      if (await networkInfo.isConnected) {
        try {
          // Try to get fresh data from server
          final user = await remoteDataSource.getCurrentUser();
          await localDataSource.cacheUser(user);
          return Right(user);
        } on ServerException {
          // If server fails, return cached user if available
          if (cachedUser != null) {
            return Right(cachedUser);
          }
          throw const ServerException(message: 'No cached user available');
        }
      } else {
        // No network, return cached user
        if (cachedUser != null) {
          return Right(cachedUser);
        }
        return const Left(NetworkFailure());
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile({
    required UserModel user,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser = await remoteDataSource.updateUser(user.id, user.toJson());
        await localDataSource.cacheUser(updatedUser);
        return Right(updatedUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (await networkInfo.isConnected) {
      try {
        final user = await localDataSource.getCachedUser();
        if (user != null) {
          await remoteDataSource.deleteUser(user.id);
        }
        await localDataSource.clearUserCache();
        await localDataSource.clearAuthToken();
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return const Left(NetworkFailure());
    }
  }

  @override
  Stream<AuthState> get authStateChanges {
    // This would typically be implemented with a StreamController
    // For now, return a simple stream that indicates authentication status
    return Stream.fromFuture(isLoggedIn().then((result) => result.fold(
      (failure) => AuthState.unauthenticated,
      (isLoggedIn) => isLoggedIn ? AuthState.authenticated : AuthState.unauthenticated,
    )));
  }

  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final token = await localDataSource.getAuthToken();
      final user = await localDataSource.getCachedUser();
      return Right(token != null && user != null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
