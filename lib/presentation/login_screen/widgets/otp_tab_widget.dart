import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../providers/auth_provider.dart';

class OtpTabWidget extends StatefulWidget {
  final VoidCallback onRegisterTap;
  const OtpTabWidget({super.key, required this.onRegisterTap});

  @override
  State<OtpTabWidget> createState() => _OtpTabWidgetState();
}

class _OtpTabWidgetState extends State<OtpTabWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _completePhoneNumber = '';

  void _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final phone = _completePhoneNumber;

      try {
        await authProvider.verifyPhoneNumber(
          phone,
          onCodeSent: (verificationId) {
            Navigator.pushNamed(
              context,
              '/otp-verification-screen',
              arguments: {'phoneNumber': phone},
            );
          },
          onVerificationFailed: (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verification failed: ${e.message}')),
            );
          },
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          IntlPhoneField(
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            initialCountryCode: 'IN',
            onChanged: (phone) {
              _completePhoneNumber = phone.completeNumber;
            },
          ),
          SizedBox(height: 4.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: authProvider.isLoading ? null : _sendOtp,
              child: authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Send OTP'),
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("New to MediTrack? ", style: theme.textTheme.bodyMedium),
              TextButton(
                onPressed: widget.onRegisterTap,
                child: Text(
                  "Register",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
