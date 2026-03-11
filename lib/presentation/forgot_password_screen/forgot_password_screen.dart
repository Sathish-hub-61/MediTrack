import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Forgot Password Screen — 3-step flow:
///   Step 1: Enter phone number
///   Step 2: Verify OTP
///   Step 3: Enter new password + confirm password
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // State
  int _currentStep = 0; // 0=phone, 1=OTP, 2=new password
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _verificationId;
  ConfirmationResult? _confirmationResult;
  String _phoneNumber = '';

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    _animController.reset();
    setState(() => _currentStep = step);
    _animController.forward();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  // ─── STEP 1: Send OTP ───
  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      _showSnackBar('Please enter a valid 10-digit phone number');
      return;
    }

    _phoneNumber = '+91$phone';
    setState(() => _isLoading = true);

    try {
      if (kIsWeb) {
        _confirmationResult =
            await FirebaseAuth.instance.signInWithPhoneNumber(_phoneNumber);
        _verificationId = _confirmationResult!.verificationId;
        setState(() => _isLoading = false);
        _goToStep(1);
        _showSnackBar('OTP sent to $_phoneNumber', isSuccess: true);
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: _phoneNumber,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential cred) async {
            // Auto-resolved on Android
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() => _isLoading = false);
            _showSnackBar('Verification failed: ${e.message}');
          },
          codeSent: (String vId, int? resendToken) {
            _verificationId = vId;
            setState(() => _isLoading = false);
            _goToStep(1);
            _showSnackBar('OTP sent to $_phoneNumber', isSuccess: true);
          },
          codeAutoRetrievalTimeout: (String vId) {
            _verificationId = vId;
          },
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Failed to send OTP: $e');
    }
  }

  // ─── STEP 2: Verify OTP ───
  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length < 6) {
      _showSnackBar('Please enter the 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (kIsWeb && _confirmationResult != null) {
        await _confirmationResult!.confirm(code);
      } else {
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: code,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }

      setState(() => _isLoading = false);
      _goToStep(2);
      _showSnackBar('Phone verified! Set your new password.', isSuccess: true);
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Invalid OTP. Please try again.');
    }
  }

  // ─── STEP 3: Update Password ───
  Future<void> _updatePassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }
    if (newPass != confirmPass) {
      _showSnackBar('Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPass);
        _showSnackBar('Password updated successfully!', isSuccess: true);

        // Sign out and go to login
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login-screen', (route) => false);
        }
      } else {
        _showSnackBar('Session expired. Please try again.');
      }
    } catch (e) {
      _showSnackBar('Failed to update password: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isSuccess ? const Color(0xFF00897B) : null,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              children: [
                SizedBox(height: 3.h),
                // ─── Back button + title
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded,
                          color: theme.colorScheme.onSurface, size: 22),
                      onPressed: () {
                        if (_currentStep > 0) {
                          _goToStep(_currentStep - 1);
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const Spacer(),
                    Text(
                      'Reset Password',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // balance the back button
                  ],
                ),

                SizedBox(height: 3.h),

                // ─── Step indicator
                _buildStepIndicator(theme),

                SizedBox(height: 4.h),

                // ─── Illustration
                _buildIllustration(theme),

                SizedBox(height: 3.h),

                // ─── Animated step content
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildCurrentStep(theme),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Step indicator dots ───
  Widget _buildStepIndicator(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: isActive ? 10.w : 3.w,
          height: 1.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: isActive
                ? theme.colorScheme.primary
                : isCompleted
                    ? theme.colorScheme.primary.withValues(alpha: 0.5)
                    : theme.colorScheme.surfaceContainerHighest,
          ),
        );
      }),
    );
  }

  // ─── Icon illustration per step ───
  Widget _buildIllustration(ThemeData theme) {
    final icons = [
      Icons.phone_android_rounded,
      Icons.sms_outlined,
      Icons.lock_reset_rounded,
    ];
    final titles = [
      'Enter Your Phone Number',
      'Verify OTP',
      'Create New Password',
    ];
    final subtitles = [
      'We\'ll send a verification code to your registered phone number',
      'Enter the 6-digit code sent to\n$_phoneNumber',
      'Your new password must be at least 6 characters long',
    ];

    return Column(
      children: [
        Container(
          width: 22.w,
          height: 22.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.colorScheme.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icons[_currentStep],
            color: theme.colorScheme.primary,
            size: 10.w,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          titles[_currentStep],
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          subtitles[_currentStep],
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ─── Route to correct step ───
  Widget _buildCurrentStep(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildPhoneStep(theme);
      case 1:
        return _buildOtpStep(theme);
      case 2:
        return _buildPasswordStep(theme);
      default:
        return const SizedBox();
    }
  }

  // ─── STEP 1: Phone input ───
  Widget _buildPhoneStep(ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          style: theme.textTheme.bodyLarge?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w500,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: '9876543210',
            counterText: '',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 4.w, right: 2.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_outlined,
                      color: theme.colorScheme.primary, size: 20),
                  SizedBox(width: 1.w),
                  Text(
                    '+91',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(width: 1.5.w),
                  Container(
                    width: 1,
                    height: 20,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 4.h),
        _buildActionButton(
          theme: theme,
          label: 'Send OTP',
          icon: Icons.send_rounded,
          onPressed: _sendOtp,
        ),
      ],
    );
  }

  // ─── STEP 2: OTP input ───
  Widget _buildOtpStep(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 12.w,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: _otpControllers[index].text.isNotEmpty
                      ? theme.colorScheme.primary.withValues(alpha: 0.05)
                      : theme.colorScheme.surface,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (value.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  setState(() {}); // refresh filled color
                },
              ),
            );
          }),
        ),
        SizedBox(height: 2.h),
        TextButton.icon(
          onPressed: _isLoading ? null : _sendOtp,
          icon: Icon(Icons.refresh_rounded,
              size: 18, color: theme.colorScheme.primary),
          label: Text(
            'Resend OTP',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        _buildActionButton(
          theme: theme,
          label: 'Verify OTP',
          icon: Icons.verified_outlined,
          onPressed: _verifyOtp,
        ),
      ],
    );
  }

  // ─── STEP 3: New password ───
  Widget _buildPasswordStep(ThemeData theme) {
    return Column(
      children: [
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: 'New Password',
            hintText: 'Enter new password',
            prefixIcon: Icon(Icons.lock_outline,
                color: theme.colorScheme.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            hintText: 'Re-enter new password',
            prefixIcon: Icon(Icons.lock_reset_rounded,
                color: theme.colorScheme.primary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        // Password strength hint
        Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 14, color: theme.colorScheme.onSurfaceVariant),
            SizedBox(width: 1.w),
            Text(
              'Minimum 6 characters',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        _buildActionButton(
          theme: theme,
          label: 'Update Password',
          icon: Icons.check_circle_outline_rounded,
          onPressed: _updatePassword,
        ),
      ],
    );
  }

  // ─── Reusable action button ───
  Widget _buildActionButton({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 6.5.h,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : onPressed,
        icon: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: theme.colorScheme.onPrimary,
                ),
              )
            : Icon(icon, size: 20),
        label: Text(
          _isLoading ? 'Please wait...' : label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
