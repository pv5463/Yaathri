import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/user_model.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/error/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<SocialLoginRequested>(_onSocialLoginRequested);
    on<PhoneLoginRequested>(_onPhoneLoginRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(AuthUnauthenticated()),
        (user) => emit(AuthSuccess(user: user)),
      );
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _authRepository.loginWithEmail(
        email: event.email,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (user) => emit(AuthSuccess(user: user)),
      );
    } catch (e) {
      emit(const AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _authRepository.registerWithEmail(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        travelPreferences: event.travelPreferences,
        consentGiven: event.consentGiven,
      );
      
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (user) => emit(AuthSuccess(user: user)),
      );
    } catch (e) {
      emit(const AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onSocialLoginRequested(
    SocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      late final Either<Failure, UserModel> result;
      
      switch (event.provider) {
        case 'google':
          result = await _authRepository.loginWithGoogle();
          break;
        case 'apple':
          result = await _authRepository.loginWithApple();
          break;
        case 'facebook':
          result = await _authRepository.loginWithFacebook();
          break;
        default:
          emit(const AuthFailure(message: 'Unsupported login provider'));
          return;
      }
      
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (user) => emit(AuthSuccess(user: user)),
      );
    } catch (e) {
      emit(const AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onPhoneLoginRequested(
    PhoneLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _authRepository.loginWithPhone(
        phoneNumber: event.phoneNumber,
      );
      
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (verificationId) => emit(AuthOtpSent(
          verificationId: verificationId,
          phoneNumber: event.phoneNumber,
        )),
      );
    } catch (e) {
      emit(const AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _authRepository.verifyOtp(
        verificationId: event.verificationId,
        otp: event.otp,
      );
      
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (user) => emit(AuthSuccess(user: user)),
      );
    } catch (e) {
      emit(const AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _authRepository.logout();
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (_) => emit(AuthUnauthenticated()),
      );
    } catch (e) {
      emit(const AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _authRepository.forgotPassword(email: event.email);
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (_) => emit(AuthPasswordResetSent(email: event.email)),
      );
    } catch (e) {
      emit(const AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final result = await _authRepository.resetPassword(
        token: event.token,
        newPassword: event.newPassword,
      );
      
      result.fold(
        (failure) => emit(AuthFailure(message: _mapFailureToMessage(failure))),
        (_) => emit(AuthPasswordResetSuccess()),
      );
    } catch (e) {
      emit(const AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again later.';
      case NetworkFailure:
        return 'Network error. Please check your connection.';
      case AuthFailure:
        return failure.message ?? 'Authentication failed.';
      case ValidationFailure:
        return failure.message ?? 'Invalid input provided.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
