import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _locationConsent = false;
  bool _dataConsent = false;
  bool _analyticsConsent = false;

  bool get _canProceed => _locationConsent && _dataConsent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 32),
              _buildConsentSection(),
              const SizedBox(height: 32),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.security,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Privacy & Permissions',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'We need your consent to provide the best travel tracking experience while respecting your privacy.',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildConsentSection() {
    return Column(
      children: [
        _buildConsentItem(
          icon: Icons.location_on,
          title: 'Location Access',
          description: 'Required to track your trips and provide location-based features.',
          isRequired: true,
          value: _locationConsent,
          onChanged: (value) {
            setState(() {
              _locationConsent = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildConsentItem(
          icon: Icons.storage,
          title: 'Data Collection',
          description: 'Collect travel data for research purposes to improve transportation systems.',
          isRequired: true,
          value: _dataConsent,
          onChanged: (value) {
            setState(() {
              _dataConsent = value;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildConsentItem(
          icon: Icons.analytics,
          title: 'Analytics & Insights',
          description: 'Help us improve the app by sharing anonymous usage analytics.',
          isRequired: false,
          value: _analyticsConsent,
          onChanged: (value) {
            setState(() {
              _analyticsConsent = value;
            });
          },
        ),
        const SizedBox(height: 24),
        _buildPrivacyNote(),
      ],
    );
  }

  Widget _buildConsentItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isRequired,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value 
              ? AppTheme.primaryColor.withOpacity(0.3)
              : AppTheme.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.errorColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Your Privacy Matters',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'All data is encrypted and anonymized for research. You can change these settings anytime in the app. Read our Privacy Policy for more details.',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              // TODO: Open privacy policy
            },
            child: const Text(
              'Read Privacy Policy →',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Continue',
          onPressed: _canProceed ? _handleContinue : null,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => context.go('/login'),
          child: const Text(
            'I\'ll decide later',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _handleContinue() {
    // TODO: Save consent preferences
    context.go('/login');
  }
}
