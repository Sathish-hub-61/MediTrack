import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../providers/auth_provider.dart';

class OtpTabWidget extends StatefulWidget {
  final VoidCallback onRegisterTap;
  const OtpTabWidget({super.key, required this.onRegisterTap});

  @override
  State<OtpTabWidget> createState() => _OtpTabWidgetState();
}

class _OtpTabWidgetState extends State<OtpTabWidget> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final phone = '+91${_phoneController.text.trim()}';

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
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              hintText: 'Enter 10 digit number',
              prefixIcon: Padding(
                padding: EdgeInsets.only(
                    left: 3.w, top: 1.5.h, bottom: 1.5.h, right: 1.h),
                child: Text('+91',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              counterText: "",
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter phone number';
              }
              if (value.length != 10) return 'Please enter 10 digits';
              return null;
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
