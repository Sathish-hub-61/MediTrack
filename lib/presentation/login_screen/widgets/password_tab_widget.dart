import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../providers/auth_provider.dart';

class PasswordTabWidget extends StatefulWidget {
  final VoidCallback onRegisterTap;
  const PasswordTabWidget({super.key, required this.onRegisterTap});

  @override
  State<PasswordTabWidget> createState() => _PasswordTabWidgetState();
}

class _PasswordTabWidgetState extends State<PasswordTabWidget> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (mounted) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home-dashboard', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: theme.colorScheme.primary,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter email';
              if (!value.contains('@')) return 'Please enter valid email';
              return null;
            },
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Icon(
                Icons.lock_outline,
                color: theme.colorScheme.primary,
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter password';
              }
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Forgot password logic
              },
              child: Text(
                "Forgot Password?",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  child: auth.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Text('Login'),
                );
              },
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
