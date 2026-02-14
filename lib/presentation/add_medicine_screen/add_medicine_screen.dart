import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../widgets/custom_app_bar.dart';
import '../../providers/medicine_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/medicine_model.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _useCaseController = TextEditingController();

  DateTime? _manufacturedDate;
  DateTime? _expiryDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _medicineNameController.dispose();
    _batchNumberController.dispose();
    _useCaseController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isManufactured) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isManufactured
          ? (_manufacturedDate ?? DateTime.now())
          : (_expiryDate ?? DateTime.now().add(const Duration(days: 365))),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText:
          isManufactured ? 'Select Manufacturing Date' : 'Select Expiry Date',
    );

    if (picked != null) {
      setState(() {
        if (isManufactured) {
          _manufacturedDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_manufacturedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select manufacturing date')),
      );
      return;
    }

    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select expiry date')),
      );
      return;
    }

    if (_expiryDate!.isBefore(_manufacturedDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Expiry date must be after manufacturing date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final medicineProvider =
          Provider.of<MedicineProvider>(context, listen: false);

      final medicine = MedicineModel(
        id: const Uuid().v4(),
        userId: authProvider.user!.uid,
        medicineName: _medicineNameController.text.trim(),
        batchNumber: _batchNumberController.text.trim(),
        manufacturedDate: _manufacturedDate!,
        expiryDate: _expiryDate!,
        useCase: _useCaseController.text.trim(),
        disposed: false,
        addedAt: DateTime.now(),
      );

      await medicineProvider.addMedicine(medicine);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medicine.medicineName} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding medicine: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Add Medicine",
        variant: CustomAppBarVariant.standard,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Name
              _buildSectionTitle(theme, 'Medicine Information'),
              SizedBox(height: 1.h),
              _buildTextField(
                controller: _medicineNameController,
                label: 'Medicine Name',
                hint: 'Enter medicine name (e.g., Paracetamol 500mg)',
                icon: Icons.medication,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              // Batch Number
              _buildTextField(
                controller: _batchNumberController,
                label: 'Batch Number',
                hint: 'Enter batch number (e.g., PCM2024A123)',
                icon: Icons.inventory_2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter batch number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),

              // Dates Section
              _buildSectionTitle(theme, 'Dates'),
              SizedBox(height: 1.h),

              // Manufacturing Date
              _buildDateField(
                context: context,
                label: 'Manufacturing Date',
                value: _manufacturedDate,
                onTap: () => _selectDate(context, true),
              ),
              SizedBox(height: 2.h),

              // Expiry Date
              _buildDateField(
                context: context,
                label: 'Expiry Date',
                value: _expiryDate,
                onTap: () => _selectDate(context, false),
                isExpiry: true,
              ),
              SizedBox(height: 3.h),

              // Use Case
              _buildSectionTitle(theme, 'Usage'),
              SizedBox(height: 1.h),
              _buildTextField(
                controller: _useCaseController,
                label: 'Use Case / Purpose',
                hint: 'What is this medicine used for?',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter use case';
                  }
                  return null;
                },
              ),
              SizedBox(height: 4.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 2.w),
                            const Text(
                              'Add Medicine',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: theme.colorScheme.primary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 2.h,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool isExpiry = false,
  }) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isExpiry ? Icons.event_busy : Icons.event,
              color: theme.colorScheme.primary,
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
                    value != null ? dateFormat.format(value) : 'Select date',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: value != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
