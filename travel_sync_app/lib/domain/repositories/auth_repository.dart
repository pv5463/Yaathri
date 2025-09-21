import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, UserModel>> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? phoneNumber,
    List<String> travelPreferences = const [],
    required bool consentGiven,
  });

  Future<Either<Failure, UserModel>> loginWithGoogle();
  Future<Either<Failure, UserModel>> loginWithApple();
  Future<Either<Failure, UserModel>> loginWithFacebook();
  
  Future<Either<Failure, String>> loginWithPhone({
    required String phoneNumber,
  });
  
  Future<Either<Failure, UserModel>> verifyOtp({
    required String verificationId,
    required String otp,
  });

  Future<Either<Failure, UserModel>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, String>> forgotPassword({
    required String email,
  });
  
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<Either<Failure, UserModel>> updateProfile({
    required UserModel user,
  });

  Future<Either<Failure, void>> deleteAccount();

  Stream<AuthState> get authStateChanges;
}

enum AuthState {
  authenticated,
  unauthenticated,
  loading,
}
