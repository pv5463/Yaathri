import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSent) {
            setState(() {
              _isEmailSent = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset email sent!'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  if (!_isEmailSent) ...[
                    _buildForm(),
                    const SizedBox(height: 32),
                    _buildSendButton(),
                  ] else ...[
                    _buildSuccessMessage(),
                    const SizedBox(height: 32),
                    _buildResendButton(),
                  ],
                  const SizedBox(height: 32),
                  _buildBackToLoginLink(),
                ],
              ),
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
        Text(
          _isEmailSent ? 'Check Your Email' : 'Forgot Password',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isEmailSent
              ? 'We\'ve sent a password reset link to your email address'
              : 'Enter your email address and we\'ll send you a link to reset your password',
          style: const TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return CustomTextField(
      controller: _emailController,
      label: 'Email',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildSendButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Send Reset Link',
          onPressed: state is AuthLoading ? null : _handleSendReset,
          isLoading: state is AuthLoading,
        );
      },
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read,
              size: 40,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Email Sent Successfully!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.successColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your email ${_emailController.text} and click the reset link to create a new password.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return Column(
          children: [
            CustomButton(
              text: 'Resend Email',
              onPressed: state is AuthLoading ? null : _handleSendReset,
              isLoading: state is AuthLoading,
              backgroundColor: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isEmailSent = false;
                });
              },
              child: const Text('Use Different Email'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Remember your password? ',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: const Text(
              'Sign In',
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

  void _handleSendReset() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        ForgotPasswordRequested(
          email: _emailController.text.trim(),
        ),
      );
    }
  }
}
