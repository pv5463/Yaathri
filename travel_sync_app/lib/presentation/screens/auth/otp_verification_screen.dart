import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  Timer? _timer;
  int _remainingTime = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingTime = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.go('/home');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          } else if (state is AuthOtpSent) {
            _startTimer();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('OTP sent successfully!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildHeader(),
                const SizedBox(height: 40),
                _buildOtpInput(),
                const SizedBox(height: 32),
                _buildVerifyButton(),
                const SizedBox(height: 24),
                _buildResendSection(),
                const SizedBox(height: 32),
                _buildChangeNumberLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        const SizedBox(height: 24),
        const Text(
          'Verify Phone',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter the 6-digit code sent to ${widget.phoneNumber}',
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInput() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 50,
              height: 60,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.textSecondary.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _focusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  
                  // Auto-verify when all fields are filled
                  if (index == 5 && value.isNotEmpty) {
                    _handleVerify();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        const Text(
          'Didn\'t receive the code? Check your SMS or try again.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Verify',
          onPressed: state is AuthLoading ? null : _handleVerify,
          isLoading: state is AuthLoading,
        );
      },
    );
  }

  Widget _buildResendSection() {
    return Center(
      child: Column(
        children: [
          if (!_canResend)
            Text(
              'Resend code in ${_remainingTime}s',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            )
          else
            TextButton(
              onPressed: _handleResendOtp,
              child: const Text(
                'Resend OTP',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChangeNumberLink() {
    return Center(
      child: TextButton(
        onPressed: () => context.pop(),
        child: const Text(
          'Change Phone Number',
          style: TextStyle(
            color: AppTheme.textSecondary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  void _handleVerify() {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length == 6) {
      context.read<AuthBloc>().add(
        VerifyOtpRequested(
          verificationId: widget.verificationId,
          otp: otp,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the complete 6-digit code'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _handleResendOtp() {
    context.read<AuthBloc>().add(
      PhoneLoginRequested(phoneNumber: widget.phoneNumber),
    );
  }
}
