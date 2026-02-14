import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class RegistrationHeaderWidget extends StatelessWidget {
  const RegistrationHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // MediTrack logo
        Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.medical_services,
              color: theme.colorScheme.onPrimary,
              size: 10.w,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // MediTrack title
        Text(
          'MediTrack',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            fontSize: 24.sp,
          ),
        ),

        SizedBox(height: 1.h),

        // Create Account subtitle
        Text(
          'Create Account',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 16.sp,
          ),
        ),

        SizedBox(height: 0.5.h),

        // Subtitle description
        Text(
          'Track your medicines safely',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}
