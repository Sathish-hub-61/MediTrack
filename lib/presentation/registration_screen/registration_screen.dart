import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../providers/auth_provider.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms & Privacy Policy'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '1. Terms of Service\n\n'
                  'By using MediTrack, you agree to store your medicine data securely on your device and our cloud servers. '
                  'We respect your privacy and data security.\n\n'
                  '2. Privacy Policy\n\n'
                  'We collect minimal data (phone number, name, email) solely for account management and notification purposes. '
                  'Your health data is not shared with third parties without consent.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _termsAccepted = true;
                });
              },
              child: const Text('Accept'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _handleRegistration() async {
    debugPrint('RegistrationScreen: _handleRegistration called');
    if (!_formKey.currentState!.validate()) {
      debugPrint('RegistrationScreen: Form validation failed');
      return;
    }

    if (!_termsAccepted) {
      debugPrint('RegistrationScreen: Terms not accepted');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms and Privacy Policy'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final phone = '+91${_phoneController.text.trim()}';
    debugPrint('RegistrationScreen: Starting phone verification for $phone');

    try {
      await authProvider.verifyPhoneNumber(
        phone,
        onCodeSent: (verificationId) {
          debugPrint('RegistrationScreen: Code sent, navigating to OTP screen');
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            '/otp-verification-screen',
            arguments: {
              'phoneNumber': phone,
              'registrationData': {
                'name': _nameController.text.trim(),
                'email': _emailController.text.trim(),
                'password': _passwordController.text,
                'phone': _phoneController.text.trim(),
              }
            },
          );
        },
        onVerificationFailed: (e) {
          debugPrint('RegistrationScreen: Verification failed: $e');
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: ${e.message}')),
          );
        },
      );
    } catch (e) {
      debugPrint('RegistrationScreen: Exception caught: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // listen: false removed as it was unused in build. authProvider is obtained inside _handleRegistration.

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 1.h),

                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  Text(
                    'Join MediTrack for safe medicine management',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 2.h),

                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(
                        Icons.phone,
                        color: theme.colorScheme.primary,
                      ),
                      prefixText: '+91 ',
                      prefixStyle: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      if (value.length != 10) {
                        return 'Phone number must be 10 digits';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 2.h),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(
                        Icons.email,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 2.h),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(
                        Icons.lock,
                        color: theme.colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 2.h),

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: theme.textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(
                        Icons.lock,
                        color: theme.colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 2.h),

                  // Terms Checkbox
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _termsAccepted,
                          onChanged: (value) {
                            setState(() {
                              _termsAccepted = value ?? false;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: _showTermsDialog,
                          child: RichText(
                            text: TextSpan(
                              text: 'I accept the ',
                              style: theme.textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(
                                  text: ' and ',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Register Button
                  SizedBox(
                    height: 6.h,
                    child: Consumer<AuthProvider>(
                      builder: (context, auth, _) {
                        debugPrint(
                            'RegistrationScreen: Rebuilding button. isLoading: ${auth.isLoading}');
                        return ElevatedButton(
                          // FORCE ENABLED FOR DEBUGGING
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'DEBUG: Clicked! Loading: ${auth.isLoading}')),
                            );
                            if (auth.isLoading) {
                              debugPrint(
                                  'DEBUG: Button clicked while loading.');
                              return;
                            }
                            _handleRegistration();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: auth.isLoading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Verify & Create Account',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: theme.textTheme.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Go back to login
                        },
                        child: Text(
                          "Login",
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
