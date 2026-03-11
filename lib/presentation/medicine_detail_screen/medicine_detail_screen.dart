import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../models/medicine_model.dart';
import '../../providers/medicine_provider.dart';

class MedicineDetailScreen extends StatelessWidget {
  const MedicineDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final medicine =
        ModalRoute.of(context)!.settings.arguments as MedicineModel;

    Color statusColor;
    if (medicine.status == MedicineStatus.safe) {
      statusColor = const Color(0xFF2E7D32);
    } else if (medicine.status == MedicineStatus.warning) {
      statusColor = const Color(0xFFF57C00);
    } else {
      statusColor = const Color(0xFFD32F2F);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Medicine Details",
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: theme.colorScheme.primary),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/edit-medicine-screen',
                arguments: medicine,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Medicine Header with Icon
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
              child: Column(
                children: [
                  Container(
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text("💊", style: TextStyle(fontSize: 48)),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    medicine.medicineName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Batch: ${medicine.batchNumber}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                children: [
                  // Status Banner
                  Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          medicine.status == MedicineStatus.safe
                              ? Icons.check_circle
                              : medicine.status == MedicineStatus.warning
                                  ? Icons.warning
                                  : Icons.block,
                          color: statusColor,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medicine.status == MedicineStatus.safe
                                    ? "SAFE TO USE"
                                    : medicine.status == MedicineStatus.warning
                                        ? "EXPIRING SOON"
                                        : "EXPIRED",
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                medicine.status == MedicineStatus.expired
                                    ? "Do not consume. Dispose immediately."
                                    : "${medicine.daysRemaining} days remaining",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Details
                  _buildDetailRow(
                    context,
                    "Manufactured Date",
                    DateFormat('dd MMM yyyy').format(medicine.manufacturedDate),
                  ),
                  _buildDetailRow(
                    context,
                    "Expiry Date",
                    DateFormat('dd MMM yyyy').format(medicine.expiryDate),
                  ),
                  _buildDetailRow(
                    context,
                    "Use Case",
                    medicine.useCase,
                    isText: true,
                  ),

                  SizedBox(height: 4.h),

                  // Action Buttons
                  if (medicine.status == MedicineStatus.expired)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleDisposal(context, medicine),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Mark as Disposed"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),

                  SizedBox(height: 2.h),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Custom reminder logic
                      },
                      icon: const Icon(Icons.alarm_add),
                      label: const Text("Set Custom Reminder"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
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

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {bool isText = false}) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isText ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _handleDisposal(
      BuildContext context, MedicineModel medicine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Disposal"),
        content: Text("Have you safely disposed of ${medicine.medicineName}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Yes, Disposed")),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<MedicineProvider>(context, listen: false)
          .disposeMedicine(medicine.id, medicine.userId);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
