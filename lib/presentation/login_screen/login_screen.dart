import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'widgets/branding_header_widget.dart';
import 'widgets/password_tab_widget.dart';
import 'widgets/otp_tab_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    debugPrint('LoginScreen: initState called');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('LoginScreen: build called');
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              children: [
                SizedBox(height: 5.h),
                const BrandingHeaderWidget(),
                SizedBox(height: 6.h),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: theme.colorScheme.primary,
                    ),
                    labelColor: theme.colorScheme.onPrimary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(text: "Password"),
                      Tab(text: "OTP"),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                SizedBox(
                  height: 45.h,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      PasswordTabWidget(
                        onRegisterTap: () => Navigator.pushNamed(
                            context, '/registration-screen'),
                      ),
                      OtpTabWidget(
                        onRegisterTap: () => Navigator.pushNamed(
                            context, '/registration-screen'),
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
