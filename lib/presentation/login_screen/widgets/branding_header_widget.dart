import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// MediTrack branding header with healthcare trust indicators.
/// Displays application logo, name, and tagline for user confidence.
class BrandingHeaderWidget extends StatelessWidget {
  const BrandingHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // MediTrack logo with healthcare icon
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              Icons.medical_services,
              color: theme.colorScheme.primary,
              size: 10.w,
            ),
          ),
        ),
        SizedBox(height: 2.h),

        // Application name
        Text(
          'MediTrack',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 0.5.h),

        // Tagline
        Text(
          'Never Miss Medicine Expiry',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 1.h),

        // Healthcare trust indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user,
              color: theme.colorScheme.primary,
              size: 16,
            ),
            SizedBox(width: 1.w),
            Text(
              'Secure & Trusted',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
