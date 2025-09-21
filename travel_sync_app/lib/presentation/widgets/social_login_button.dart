import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

class SocialLoginButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.isFullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor ?? const Color(0xFFE1E8ED),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIcon(),
                if (!isFullWidth) ...[
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textColor ?? AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? AppTheme.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (icon.endsWith('.svg')) {
      return SvgPicture.asset(
        icon,
        width: 24,
        height: 24,
      );
    } else {
      // Fallback to built-in icons
      IconData iconData;
      switch (label.toLowerCase()) {
        case 'google':
          iconData = Icons.g_mobiledata;
          break;
        case 'apple':
          iconData = Icons.apple;
          break;
        case 'facebook':
          iconData = Icons.facebook;
          break;
        case 'continue with phone':
        case 'phone':
          iconData = Icons.phone;
          break;
        default:
          iconData = Icons.login;
      }
      
      return Icon(
        iconData,
        size: 24,
        color: _getIconColor(),
      );
    }
  }

  Color _getIconColor() {
    switch (label.toLowerCase()) {
      case 'google':
        return const Color(0xFF4285F4);
      case 'apple':
        return Colors.black;
      case 'facebook':
        return const Color(0xFF1877F2);
      case 'continue with phone':
      case 'phone':
        return AppTheme.primaryColor;
      default:
        return AppTheme.textPrimary;
    }
  }
}

class SocialLoginGrid extends StatelessWidget {
  final List<SocialLoginOption> options;
  final void Function(String provider) onProviderSelected;

  const SocialLoginGrid({
    super.key,
    required this.options,
    required this.onProviderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Or continue with',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            return SocialLoginButton(
              icon: option.icon,
              label: option.label,
              onPressed: () => onProviderSelected(option.provider),
              isFullWidth: option.isFullWidth,
              backgroundColor: option.backgroundColor,
              textColor: option.textColor,
              borderColor: option.borderColor,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class SocialLoginOption {
  final String provider;
  final String icon;
  final String label;
  final bool isFullWidth;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SocialLoginOption({
    required this.provider,
    required this.icon,
    required this.label,
    this.isFullWidth = false,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  static const google = SocialLoginOption(
    provider: 'google',
    icon: 'assets/icons/google.svg',
    label: 'Google',
  );

  static const apple = SocialLoginOption(
    provider: 'apple',
    icon: 'assets/icons/apple.svg',
    label: 'Apple',
  );

  static const facebook = SocialLoginOption(
    provider: 'facebook',
    icon: 'assets/icons/facebook.svg',
    label: 'Facebook',
  );

  static const phone = SocialLoginOption(
    provider: 'phone',
    icon: 'assets/icons/phone.svg',
    label: 'Continue with Phone',
    isFullWidth: true,
  );
}
