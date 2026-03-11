import 'package:flutter/material.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/login_screen/otp_verification_screen.dart';

import '../presentation/expired_medicine_alert_modal/expired_medicine_alert_modal.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/medicine_detail_screen/medicine_detail_screen.dart';
import '../presentation/history_screen/history_screen.dart';
import '../presentation/profile_screen/profile_screen.dart';
import '../presentation/add_medicine_screen/add_medicine_screen.dart';
import '../presentation/add_medicine_screen/edit_medicine_screen.dart';
import '../models/medicine_model.dart';
import '../presentation/ai_assistant_screen/ai_assistant_screen.dart';
import '../presentation/forgot_password_screen/forgot_password_screen.dart';

import '../presentation/common_screens/common_screens.dart';

class AppRoutes {
  static const String initial = '/'; // Splash is initial
  static const String expiredMedicineAlertModal =
      '/expired-medicine-alert-modal';
  static const String splash = '/splash-screen';
  static const String medicineDetail = '/medicine-detail-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String login = '/login-screen';
  static const String registration = '/registration-screen';

  static const String historyScreen = '/history-screen';
  static const String profileScreen = '/profile-screen';
  static const String addMedicineScreen = '/add-medicine-screen';
  static const String editMedicineScreen = '/edit-medicine-screen';
  static const String otpVerification = '/otp-verification-screen';
  static const String aiAssistant = '/ai-assistant-screen';
  static const String forgotPassword = '/forgot-password-screen';

  static const String settingsScreen = '/settings-screen';
  static const String helpSupportScreen = '/help-support-screen';
  static const String privacySecurityScreen = '/privacy-security-screen';
  static const String notificationsScreen = '/notifications-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    registration: (context) => const RegistrationScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    expiredMedicineAlertModal: (context) => const ExpiredMedicineAlertModal(),
    historyScreen: (context) => const HistoryScreen(),
    profileScreen: (context) => const ProfileScreen(),
    addMedicineScreen: (context) => const AddMedicineScreen(),
    editMedicineScreen: (context) {
      final medicine =
          ModalRoute.of(context)!.settings.arguments as MedicineModel;
      return EditMedicineScreen(medicine: medicine);
    },
    otpVerification: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return OtpVerificationScreen(
        phoneNumber: args['phoneNumber'],
        registrationData: args['registrationData'],
      );
    },
    aiAssistant: (context) => const AIAssistantScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),

    // Medicine Detail Screen
    medicineDetail: (context) => const MedicineDetailScreen(),

    // Common Screens
    settingsScreen: (context) => const SettingsScreen(),
    helpSupportScreen: (context) => const HelpSupportScreen(),
    privacySecurityScreen: (context) => const PrivacySecurityScreen(),
    notificationsScreen: (context) => const NotificationsScreen(),
  };
}
