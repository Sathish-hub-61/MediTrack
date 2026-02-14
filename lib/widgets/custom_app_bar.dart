import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom app bar for healthcare medication tracking application.
/// Implements Medical Clarity Design with clean, accessible layout.
///
/// Features:
/// - Prominent search/filter access for urgent medicine identification
/// - Optional action buttons for quick access to critical functions
/// - Consistent elevation and styling across light/dark themes
/// - Accessibility-optimized touch targets (minimum 48dp)
/// - Support for leading navigation and trailing actions
enum CustomAppBarVariant {
  /// Standard app bar with title and optional actions
  standard,

  /// App bar with integrated search field
  search,

  /// App bar with back button for detail screens
  detail,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar title text
  final String title;

  /// App bar variant (standard, search, detail)
  final CustomAppBarVariant variant;

  /// Optional leading widget (overrides default back button)
  final Widget? leading;

  /// Optional trailing action buttons
  final List<Widget>? actions;

  /// Search field controller (required for search variant)
  final TextEditingController? searchController;

  /// Search field hint text
  final String searchHint;

  /// Callback when search text changes
  final ValueChanged<String>? onSearchChanged;

  /// Callback when search is submitted
  final ValueChanged<String>? onSearchSubmitted;

  /// Whether to show back button (for detail variant)
  final bool showBackButton;

  /// Custom back button callback
  final VoidCallback? onBackPressed;

  /// Whether to center the title
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.leading,
    this.actions,
    this.searchController,
    this.searchHint = 'Search medicines...',
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine system UI overlay style based on theme brightness
    final overlayStyle = theme.brightness == Brightness.light
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;

    switch (variant) {
      case CustomAppBarVariant.search:
        return AppBar(
          systemOverlayStyle: overlayStyle,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          leading: leading,
          title: _buildSearchField(context),
          actions: actions,
        );

      case CustomAppBarVariant.detail:
        return AppBar(
          systemOverlayStyle: overlayStyle,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          leading:
              leading ??
              (showBackButton
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      tooltip: 'Back',
                      onPressed:
                          onBackPressed ?? () => Navigator.of(context).pop(),
                    )
                  : null),
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: centerTitle,
          actions: actions,
        );

      case CustomAppBarVariant.standard:
      default:
        return AppBar(
          systemOverlayStyle: overlayStyle,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          leading: leading,
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: centerTitle,
          actions: actions,
        );
    }
  }

  /// Builds integrated search field for quick medicine lookup
  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFFFAFAFA) // Surface color
            : const Color(0xFF2D2D2D), // Card color for dark theme
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: theme.brightness == Brightness.light
              ? const Color(0xFF757575).withValues(alpha: 0.3) // Neutral color
              : const Color(0xFF9E9E9E).withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: onSearchChanged,
        onSubmitted: onSearchSubmitted,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: searchHint,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.brightness == Brightness.light
                ? const Color(0xFF757575) // Neutral color
                : const Color(0xFF9E9E9E),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: theme.brightness == Brightness.light
                ? const Color(0xFF757575)
                : const Color(0xFF9E9E9E),
            size: 20,
          ),
          suffixIcon: searchController?.text.isNotEmpty ?? false
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: theme.brightness == Brightness.light
                        ? const Color(0xFF757575)
                        : const Color(0xFF9E9E9E),
                    size: 20,
                  ),
                  onPressed: () {
                    searchController?.clear();
                    onSearchChanged?.call('');
                  },
                  tooltip: 'Clear search',
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          isDense: true,
        ),
      ),
    );
  }
}
