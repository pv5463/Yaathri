part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final List<String> travelPreferences;
  final bool consentGiven;

  const RegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    this.travelPreferences = const [],
    required this.consentGiven,
  });

  @override
  List<Object?> get props => [
        email,
        password,
        fullName,
        phoneNumber,
        travelPreferences,
        consentGiven,
      ];
}

class SocialLoginRequested extends AuthEvent {
  final String provider;

  const SocialLoginRequested({required this.provider});

  @override
  List<Object?> get props => [provider];
}

class PhoneLoginRequested extends AuthEvent {
  final String phoneNumber;

  const PhoneLoginRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class VerifyOtpRequested extends AuthEvent {
  final String verificationId;
  final String otp;

  const VerifyOtpRequested({
    required this.verificationId,
    required this.otp,
  });

  @override
  List<Object?> get props => [verificationId, otp];
}

class LogoutRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordRequested extends AuthEvent {
  final String token;
  final String newPassword;

  const ResetPasswordRequested({
    required this.token,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [token, newPassword];
}
