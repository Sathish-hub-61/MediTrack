import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Action buttons section for medicine detail screen
class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onSetReminder;
  final VoidCallback onMarkDisposed;
  final VoidCallback onShareInfo;
  final bool isExpired;

  const ActionButtonsWidget({
    super.key,
    required this.onSetReminder,
    required this.onMarkDisposed,
    required this.onShareInfo,
    required this.isExpired,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isExpired) ...[
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton.icon(
                  onPressed: onSetReminder,
                  icon: Icon(
                    Icons.alarm_add,
                    color: theme.colorScheme.onPrimary,
                    size: 20,
                  ),
                  label: Text(
                    'Set Custom Reminder',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 1.5.h),
            ],
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: OutlinedButton.icon(
                onPressed: onMarkDisposed,
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                label: Text(
                  'Mark as Disposed',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.colorScheme.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.5.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: TextButton.icon(
                onPressed: onShareInfo,
                icon: Icon(
                  Icons.share,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: Text(
                  'Share Info',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
