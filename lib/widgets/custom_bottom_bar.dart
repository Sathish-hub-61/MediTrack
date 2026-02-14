import 'package:flutter/material.dart';

/// Custom bottom navigation bar for healthcare medication tracking application.
/// Implements bottom-heavy interaction zone for comfortable thumb reach during one-handed operation.
///
/// Features:
/// - Fixed type navigation for consistent layout
/// - Smart notification badges for contextual urgency
/// - Minimum 48dp touch targets for accessibility
/// - Color-coded active states matching Health Status Spectrum
///
/// Navigation items match Mobile Navigation Hierarchy:
/// 1. Home/Dashboard - Medicine monitoring dashboard (core safety function)
/// 2. History - Disposal and usage timeline (secondary reference)
/// 3. Profile - Settings and notification preferences (configuration access)
class CustomBottomBar extends StatelessWidget {
  /// Current selected index (0-based)
  final int currentIndex;

  /// Callback when navigation item is tapped
  final Function(int) onTap;

  /// Optional badge count for Home tab (expired medicines alert)
  final int? homeBadgeCount;

  /// Optional badge count for History tab (pending disposal actions)
  final int? historyBadgeCount;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.homeBadgeCount,
    this.historyBadgeCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: theme.brightness == Brightness.light
          ? const Color(0xFF757575) // Neutral color for light theme
          : const Color(0xFF9E9E9E), // Neutral color for dark theme
      selectedFontSize: 12,
      unselectedFontSize: 12,
      elevation: 8.0,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
      ),
      items: [
        // Home/Dashboard Tab - Core safety function for medicine monitoring
        BottomNavigationBarItem(
          icon: _buildIconWithBadge(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            isActive: currentIndex == 0,
            badgeCount: homeBadgeCount,
            context: context,
          ),
          label: 'Home',
          tooltip: 'Medicine monitoring dashboard',
        ),

        // History Tab - Secondary reference for disposal and usage timeline
        BottomNavigationBarItem(
          icon: _buildIconWithBadge(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            isActive: currentIndex == 1,
            badgeCount: historyBadgeCount,
            context: context,
          ),
          label: 'History',
          tooltip: 'Disposal and usage timeline',
        ),

        // Profile Tab - Configuration access for settings and notifications
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 2 ? Icons.person : Icons.person_outline,
            size: 24,
          ),
          label: 'Profile',
          tooltip: 'Settings and notification preferences',
        ),
      ],
    );
  }

  /// Builds an icon with optional badge indicator for critical alerts
  /// Implements smart notification badges without creating notification fatigue
  Widget _buildIconWithBadge({
    required IconData icon,
    required IconData activeIcon,
    required bool isActive,
    int? badgeCount,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);

    // Use error color for critical medication alerts (expired medicines)
    final badgeColor = theme.brightness == Brightness.light
        ? const Color(0xFFD32F2F) // Error color for light theme
        : const Color(0xFFEF5350); // Error color for dark theme

    if (badgeCount == null || badgeCount == 0) {
      return Icon(isActive ? activeIcon : icon, size: 24);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(isActive ? activeIcon : icon, size: 24),
        Positioned(
          right: -8,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            child: Text(
              badgeCount > 99 ? '99+' : badgeCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
