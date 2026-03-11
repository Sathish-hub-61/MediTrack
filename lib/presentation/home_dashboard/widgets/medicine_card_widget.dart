import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../../models/medicine_model.dart';

class MedicineCardWidget extends StatelessWidget {
  final MedicineModel medicine;
  final VoidCallback onTap;
  final VoidCallback onSetReminder;
  final VoidCallback onMarkDisposed;

  const MedicineCardWidget({
    super.key,
    required this.medicine,
    required this.onTap,
    required this.onSetReminder,
    required this.onMarkDisposed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine status color based on model status
    Color statusColor;
    if (medicine.status == MedicineStatus.safe) {
      statusColor = const Color(0xFF2E7D32);
    } else if (medicine.status == MedicineStatus.warning) {
      statusColor = const Color(0xFFF57C00);
    } else {
      statusColor = const Color(0xFFD32F2F);
    }

    final daysRemaining = medicine.daysRemaining;

    return Slidable(
      key: ValueKey(medicine.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onSetReminder(),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: Icons.alarm_add,
            label: 'Reminder',
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onMarkDisposed(),
            backgroundColor: const Color(0xFFD32F2F),
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Dispose',
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Left status border
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 5,
                  child: Container(color: statusColor),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Line with Emoji
                      Row(
                        children: [
                          const Text("💊", style: TextStyle(fontSize: 18)),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              medicine.medicineName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),

                      // Batch Line
                      Text(
                        "Batch: ${medicine.batchNumber}",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 0.5.h),

                      // Mfg and Exp Line
                      Row(
                        children: [
                          Text(
                            "Mfg: ${DateFormat('dd/MM/yyyy').format(medicine.manufacturedDate)}",
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 12),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Exp: ${DateFormat('dd/MM/yyyy').format(medicine.expiryDate)}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: medicine.status == MedicineStatus.safe
                                  ? theme.colorScheme.onSurface
                                  : statusColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),

                      // Use Case Line
                      Text(
                        "Use: ${medicine.useCase}",
                        style:
                            theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),

                      // Status Line
                      Row(
                        children: [
                          Icon(
                            medicine.status == MedicineStatus.safe
                                ? Icons.check_circle
                                : medicine.status == MedicineStatus.warning
                                    ? Icons.warning
                                    : Icons.block,
                            color: statusColor,
                            size: 16,
                          ),
                          SizedBox(width: 1.5.w),
                          Text(
                            medicine.status == MedicineStatus.safe
                                ? "Safe • $daysRemaining days remaining"
                                : medicine.status == MedicineStatus.warning
                                    ? "Warning • $daysRemaining days left"
                                    : "EXPIRED • ${daysRemaining.abs()} days ago",
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
