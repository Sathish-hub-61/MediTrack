import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Registration footer widget with login redirect link
/// Provides easy navigation to login screen for existing users
class RegistrationFooterWidget extends StatelessWidget {
  final VoidCallback onLoginTap;

  const RegistrationFooterWidget({super.key, required this.onLoginTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: GestureDetector(
        onTap: onLoginTap,
        child: RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
            children: [
              const TextSpan(text: 'Already have an account? '),
              TextSpan(
                text: 'Login',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

