import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/network_info.dart';
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
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.login({
          'email': email,
          'password': password,
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
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.socialLogin({
          'provider': 'google',
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
    // For now, return a simple stream
    return Stream.value(AuthState.unauthenticated);
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
