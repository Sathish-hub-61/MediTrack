# MediTrack App Fix Plan

## Phase 1: Critical Build Fixes (15-20 min)
- [x] Update Kotlin version to 2.1.0 in android/build.gradle
- [x] Clean and rebuild project

## Phase 2: Code Quality Fixes (20-30 min)
- [x] Replace critical withOpacity with withValues in UI files (medicine_card_widget, splash_screen, expired_alert_modal, home_dashboard)
- [x] Replace remaining withOpacity with withValues in other UI files (empty_state, history_screen, registration_widgets, branding_header, medicine_detail_widgets)
- [x] Remove unused imports
- [x] Fix missing curly braces
- [x] Fix unused variables
- [x] Update deprecated APIs (surfaceVariant, activeColor)

## Phase 3: Testing and Launch (10-15 min)
- [x] Run flutter build apk --release
- [x] Test core functionality in emulator
- [x] Generate signed APK if needed
- [x] Verify no SurfaceSyncGroup rendering errors (Fixed with withValues)
- [x] Confirm app flow: Splash → Login → Register → Dashboard ✅
- [x] App launches correctly with proper navigation

## Files to Edit:
- android/build.gradle (Kotlin version)
- lib/models/user_model.dart (unused import)
- lib/presentation/add_medicine_screen/add_medicine_screen.dart (withOpacity)
- lib/presentation/expired_medicine_alert_modal/expired_medicine_alert_modal.dart (withOpacity, unused var)
- lib/presentation/history_screen/history_screen.dart (withOpacity)
- lib/presentation/home_dashboard/home_dashboard_initial_page.dart (withOpacity)
- lib/presentation/home_dashboard/widgets/empty_state_widget.dart (withOpacity)
- lib/presentation/home_dashboard/widgets/medicine_card_widget.dart (withOpacity)
- lib/presentation/login_screen/login_screen.dart (surfaceVariant, withOpacity)
- lib/presentation/login_screen/widgets/otp_tab_widget.dart (curly braces)
- lib/presentation/login_screen/widgets/password_tab_widget.dart (curly braces)
- lib/presentation/medicine_detail_screen/medicine_detail_screen.dart (withOpacity, BuildContext)
- lib/presentation/profile_screen/profile_screen.dart (activeColor, withOpacity)
- lib/presentation/registration_screen/widgets/registration_form_widget.dart (withOpacity)
- lib/presentation/registration_screen/widgets/registration_header_widget.dart (withOpacity)
- lib/presentation/splash_screen/splash_screen.dart (withOpacity)
