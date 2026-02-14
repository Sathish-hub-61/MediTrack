import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? searchQuery;

  const EmptyStateWidget({super.key, this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSearchQuery = searchQuery != null && searchQuery!.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Important for Center
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearchQuery ? Icons.search_off : Icons.medication_outlined,
                color: theme.colorScheme.primary,
                size: 64,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              hasSearchQuery ? 'No medicines found' : 'No medicines added yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.5.h),
            Text(
              hasSearchQuery
                  ? 'Try adjusting your search terms or filters to find what you are looking for.'
                  : 'Your inventory is empty. Add your first medicine to start tracking expiry dates and get reminders.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearchQuery) ...[
              SizedBox(height: 4.h),
              // We have a FAB, but a central CTA is also good.
              // Let's make it a tonal button to be less "aggressive" than the FAB
              FilledButton.tonalIcon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/add-medicine-screen');
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Medicine'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
