import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../providers/auth_provider.dart';
import '../../firebase_options.dart';
import '../../services/notification_service.dart';
import '../home_dashboard/home_dashboard.dart';
import '../login_screen/login_screen.dart';

/// Splash Screen for MediTrack application
/// Provides branded app launch experience while initializing medicine data synchronization
/// and user authentication status
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isInitializing = true;
  String _statusMessage = 'Initializing...';
  bool _hasNavigated = false;
  Timer? _failsafeTimer;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();

    // Failsafe timer: Force navigation after 8 seconds if nothing else triggers it
    _failsafeTimer = Timer(const Duration(seconds: 8), () {
      if (!_hasNavigated && mounted) {
        debugPrint(
            'SplashScreen: Failsafe timer triggered - forcing navigation');
        _navigateToNextScreen();
      }
    });

    // Wait for the first frame to render before starting initialization
    // This prevents the "blank screen" by ensuring the UI shows up first
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// Initialize pulse animation for logo
  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  /// Initialize app with background tasks
  Future<void> _initializeApp() async {
    debugPrint('SplashScreen: 100.h = ${100.h}');
    debugPrint('SplashScreen: Starting Initialization...');
    try {
      // Initialize Firebase (non-blocking for UI)
      if (Firebase.apps.isEmpty) {
        debugPrint('SplashScreen: Initializing Firebase...');
        await Future.any([
          Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          Future.delayed(const Duration(seconds: 4), () {
            debugPrint(
                'SplashScreen: Firebase Init Timeout - Proceeding anyway');
            return null;
          }),
        ]);
        debugPrint('SplashScreen: Firebase Initialized/Timeout Complete');
      } else {
        debugPrint('SplashScreen: Firebase already initialized');
      }

      // Initialize Auth Provider
      if (mounted) {
        debugPrint('SplashScreen: Initializing AuthProvider...');
        // Wrap in timeout to prevent hanging
        await Future.any([
          Provider.of<AuthProvider>(context, listen: false).initialize(),
          Future.delayed(const Duration(seconds: 3), () {
            debugPrint(
                'SplashScreen: AuthProvider Init Timeout - Proceeding anyway');
            return null;
          }),
        ]);
        debugPrint('SplashScreen: AuthProvider Initialized');
      }

      // Initialize Notifications
      debugPrint('SplashScreen: Initializing Notifications...');
      // Wrap in timeout
      await Future.any([
        NotificationService().init(),
        Future.delayed(const Duration(seconds: 2), () {
          debugPrint(
              'SplashScreen: Notification Init Timeout - Proceeding anyway');
          return null;
        }),
      ]);
      debugPrint('SplashScreen: Notifications Initialized');

      // Artificial delay for brand visibility
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isInitializing = false);
      _navigateToNextScreen();
    } catch (e) {
      debugPrint('SplashScreen: Initialization error: $e');
      if (mounted) {
        // Even if init fails, try to proceed
        setState(() {
          _isInitializing = false;
          _statusMessage = 'Starting offline mode...';
        });
        await Future.delayed(const Duration(seconds: 1));
        _navigateToNextScreen();
      }
    }
  }

  /// Navigate to appropriate screen based on user status
  void _navigateToNextScreen() {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;
    _failsafeTimer?.cancel();

    debugPrint('SplashScreen: Navigating to next screen... (Direct Route)');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      Widget nextScreen;
      if (authProvider.isAuthenticated) {
        debugPrint(
            'SplashScreen: User is authenticated, preparing Home Dashboard route');
        nextScreen = const HomeDashboard(); // Ensure import is correct
      } else {
        debugPrint(
            'SplashScreen: User is NOT authenticated, preparing Login Screen route');
        nextScreen = const LoginScreen(); // Ensure import is correct
      }

      Navigator.of(context)
          .pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            debugPrint(
                'SplashScreen: Building route for ${nextScreen.runtimeType}');
            return nextScreen;
          },
          settings: RouteSettings(
              name: authProvider.isAuthenticated
                  ? '/home-dashboard'
                  : '/login-screen'),
        ),
      )
          .then((_) {
        debugPrint('SplashScreen: Navigation completed (future resolved)');
      });
    } catch (e, stack) {
      debugPrint('SplashScreen: Navigation Error: $e');
      debugPrint('SplashScreen: Stack Trace: $stack');
      // Emergency fallback
      Navigator.of(context).pushReplacementNamed('/login-screen');
    }
  }

  @override
  void dispose() {
    _failsafeTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 100.h - MediaQuery.of(context).padding.vertical),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    _buildLogo(),
                    SizedBox(height: 3.h),
                    _buildTagline(theme),
                    const Spacer(flex: 2),
                    _buildLoadingIndicator(theme),
                    SizedBox(height: 2.h),
                    _buildStatusMessage(theme),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build animated logo with pulse effect
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services,
                    size: 15.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'MediTrack',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build tagline text
  Widget _buildTagline(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        'Your Medicine Safety Companion',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator(ThemeData theme) {
    return _isInitializing
        ? SizedBox(
            width: 8.w,
            height: 8.w,
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : const Icon(
            Icons.check_circle,
            size: 32,
            color: Colors.white,
          );
  }

  /// Build status message
  Widget _buildStatusMessage(ThemeData theme) {
    return Text(
      _statusMessage,
      style: TextStyle(
        fontSize: 12.sp,
        color: Colors.white.withValues(alpha: 0.9),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
