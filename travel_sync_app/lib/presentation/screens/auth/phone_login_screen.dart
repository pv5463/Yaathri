import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _selectedCountryCode = '+91';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthOtpSent) {
            context.push('/otp-verification?phone=$_selectedCountryCode${_phoneController.text}');
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
                  _buildPhoneInput(),
                  const SizedBox(height: 32),
                  _buildSendOtpButton(),
                  const SizedBox(height: 24),
                  _buildTermsText(),
                  const SizedBox(height: 32),
                  _buildBackToEmailLink(),
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
        const Text(
          'Phone Login',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We\'ll send you a verification code to confirm your phone number',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.textSecondary.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  items: const [
                    DropdownMenuItem(value: '+91', child: Text('+91')),
                    DropdownMenuItem(value: '+1', child: Text('+1')),
                    DropdownMenuItem(value: '+44', child: Text('+44')),
                    DropdownMenuItem(value: '+86', child: Text('+86')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCountryCode = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (value.length < 10) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSendOtpButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return CustomButton(
          text: 'Send OTP',
          onPressed: state is AuthLoading ? null : _handleSendOtp,
          isLoading: state is AuthLoading,
        );
      },
    );
  }

  Widget _buildTermsText() {
    return const Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy. You may receive SMS notifications from us.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: AppTheme.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildBackToEmailLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Prefer email? ',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.go('/login'),
            child: const Text(
              'Sign in with Email',
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

  void _handleSendOtp() {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
      context.read<AuthBloc>().add(
        PhoneLoginRequested(phoneNumber: phoneNumber),
      );
    }
  }
}
