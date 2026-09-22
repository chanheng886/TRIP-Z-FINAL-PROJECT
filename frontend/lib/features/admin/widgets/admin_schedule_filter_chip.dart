import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AdminScheduleFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final String filterValue;
  final bool isSelected;
  final Color activeColor;
  final bool isDark;
  final ValueChanged<String> onSelected;

  const AdminScheduleFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.filterValue,
    required this.isSelected,
    required this.activeColor,
    required this.isDark,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(filterValue),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: isDark ? 0.22 : 0.12)
              : (isDark ? const Color(0xFF181B22) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF2C313C) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppFonts.dmSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? activeColor
                    : (isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? activeColor
                    : (isDark
                          ? const Color(0xFF2C313C)
                          : const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: AppFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
