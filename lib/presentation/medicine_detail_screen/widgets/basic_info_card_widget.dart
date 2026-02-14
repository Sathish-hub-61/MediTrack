import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Basic information card displaying batch number, dates, and days remaining
class BasicInfoCardWidget extends StatelessWidget {
  final String batchNumber;
  final DateTime manufacturingDate;
  final DateTime expiryDate;
  final int daysRemaining;
  final Color statusColor;

  const BasicInfoCardWidget({
    super.key,
    required this.batchNumber,
    required this.manufacturingDate,
    required this.expiryDate,
    required this.daysRemaining,
    required this.statusColor,
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
              'Basic Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 2.h),
            _buildInfoRow(context, 'Batch Number', batchNumber, Icons.qr_code),
            SizedBox(height: 1.5.h),
            _buildInfoRow(
              context,
              'Manufacturing Date',
              _formatDate(manufacturingDate),
              Icons.calendar_today,
            ),
            SizedBox(height: 1.5.h),
            _buildInfoRow(
              context,
              'Expiry Date',
              _formatDate(expiryDate),
              Icons.event,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    daysRemaining < 0 ? Icons.error : Icons.access_time,
                    color: statusColor,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    daysRemaining < 0
                        ? 'EXPIRED'
                        : '$daysRemaining days remaining',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
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
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
