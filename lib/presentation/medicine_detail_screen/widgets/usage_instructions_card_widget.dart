import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Usage instructions card displaying dosage, frequency, and special instructions
class UsageInstructionsCardWidget extends StatelessWidget {
  final String dosage;
  final String frequency;
  final String specialInstructions;

  const UsageInstructionsCardWidget({
    super.key,
    required this.dosage,
    required this.frequency,
    required this.specialInstructions,
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
              'Usage Instructions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            _buildInstructionItem(context, 'Dosage', dosage, Icons.medication),
            SizedBox(height: 1.5.h),
            _buildInstructionItem(
              context,
              'Frequency',
              frequency,
              Icons.schedule,
            ),
            SizedBox(height: 1.5.h),
            _buildInstructionItem(
              context,
              'Special Instructions',
              specialInstructions,
              Icons.info_outline,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
