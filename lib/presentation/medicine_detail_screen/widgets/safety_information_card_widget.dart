import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Safety information card displaying storage conditions, side effects, and disposal guidelines
class SafetyInformationCardWidget extends StatelessWidget {
  final String storageConditions;
  final String sideEffects;
  final String disposalGuidelines;

  const SafetyInformationCardWidget({
    super.key,
    required this.storageConditions,
    required this.sideEffects,
    required this.disposalGuidelines,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Safety Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            _buildSafetySection(
              context,
              'Storage Conditions',
              storageConditions,
              Icons.ac_unit,
              theme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            _buildSafetySection(
              context,
              'Side Effects',
              sideEffects,
              Icons.warning_amber,
              const Color(0xFFF57C00),
            ),
            SizedBox(height: 2.h),
            _buildSafetySection(
              context,
              'Disposal Guidelines',
              disposalGuidelines,
              Icons.delete_outline,
              theme.colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetySection(
    BuildContext context,
    String title,
    String content,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: iconColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
