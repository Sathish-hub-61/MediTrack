import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../models/medicine_model.dart';
import '../../providers/medicine_provider.dart';

class ExpiredMedicineAlertModal extends StatelessWidget {
  final MedicineModel? medicine;
  const ExpiredMedicineAlertModal({super.key, this.medicine});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final med = medicine ??
        (ModalRoute.of(context)!.settings.arguments as MedicineModel);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: Colors.red, size: 64),
            SizedBox(height: 2.h),
            Text(
              "MEDICINE EXPIRED",
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              med.medicineName,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              "Expired on ${DateFormat('dd/MM/yyyy').format(med.expiryDate)}",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
            ),
            SizedBox(height: 3.h),
            const Text(
              "Please dispose of it safely in a dustbin",
              style: TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Provider.of<MedicineProvider>(context, listen: false)
                      .disposeMedicine(med.id, med.userId);
                  if (context.mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Mark as Disposed"),
              ),
            ),
            SizedBox(height: 1.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Remind Me Later"),
            ),
          ],
        ),
      ),
    );
  }
}
