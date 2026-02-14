import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Registration form widget with input fields and validation
class RegistrationFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool isPasswordVisible;
  final bool isTermsAccepted;
  final String? nameError;
  final String? phoneError;
  final String? passwordError;
  final double passwordStrength;
  final String passwordStrengthText;
  final Color passwordStrengthColor;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPhoneChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onPasswordVisibilityToggle;
  final ValueChanged<bool?> onTermsChanged;
  final VoidCallback onPrivacyPolicyTap;

  const RegistrationFormWidget({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.passwordController,
    required this.isPasswordVisible,
    required this.isTermsAccepted,
    this.nameError,
    this.phoneError,
    this.passwordError,
    required this.passwordStrength,
    required this.passwordStrengthText,
    required this.passwordStrengthColor,
    required this.onNameChanged,
    required this.onPhoneChanged,
    required this.onPasswordChanged,
    required this.onPasswordVisibilityToggle,
    required this.onTermsChanged,
    required this.onPrivacyPolicyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full Name field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                onChanged: onNameChanged,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(
                    Icons.person,
                    color: nameError != null
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  errorText: null,
                ),
              ),
              if (nameError != null)
                Padding(
                  padding: EdgeInsets.only(left: 3.w, top: 0.5.h),
                  child: Text(
                    nameError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Phone Number field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: phoneController,
                onChanged: onPhoneChanged,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter 10-digit mobile number',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '+91',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          width: 1,
                          height: 3.h,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                        SizedBox(width: 2.w),
                      ],
                    ),
                  ),
                  errorText: null,
                ),
              ),
              if (phoneError != null)
                Padding(
                  padding: EdgeInsets.only(left: 3.w, top: 0.5.h),
                  child: Text(
                    phoneError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Password field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: passwordController,
                onChanged: onPasswordChanged,
                textInputAction: TextInputAction.done,
                obscureText: !isPasswordVisible,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter secure password',
                  prefixIcon: Icon(
                    Icons.lock,
                    color: passwordError != null
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    onPressed: onPasswordVisibilityToggle,
                  ),
                  errorText: null,
                ),
              ),

              // Password strength indicator
              if (passwordController.text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(left: 3.w, top: 1.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2.0),
                              child: LinearProgressIndicator(
                                value: passwordStrength,
                                backgroundColor: theme
                                    .colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  passwordStrengthColor,
                                ),
                                minHeight: 0.5.h,
                              ),
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            passwordStrengthText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: passwordStrengthColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              if (passwordError != null)
                Padding(
                  padding: EdgeInsets.only(left: 3.w, top: 0.5.h),
                  child: Text(
                    passwordError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          // Terms and conditions checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 6.w,
                height: 6.w,
                child: Checkbox(
                  value: isTermsAccepted,
                  onChanged: onTermsChanged,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTermsChanged(!isTermsAccepted),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11.sp,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: onPrivacyPolicyTap,
                            child: Text(
                              'Healthcare Privacy Policy',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                        ),
                        const TextSpan(text: ' and Terms of Service'),
                      ],
                    ),
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
