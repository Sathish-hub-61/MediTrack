import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final int? count;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.label,
    this.count,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.2)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? chipColor
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? chipColor : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (count != null && count! > 0) ...[
              SizedBox(width: 1.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(minWidth: 20, minHeight: 20),
                child: Text(
                  count.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
