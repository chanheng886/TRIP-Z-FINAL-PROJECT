import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class QuickActionItem {
  final String label;
  final FaIconData icon;
  final VoidCallback onTap;

  const QuickActionItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class AdminQuickActions extends StatelessWidget {
  final List<QuickActionItem> actions;
  final bool isDark;

  const AdminQuickActions({
    super.key,
    required this.actions,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final a = actions[index];
          return InkWell(
            onTap: a.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.green.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(a.icon, size: 11, color: AppColors.green),
                  const SizedBox(width: 6),
                  Text(
                    a.label,
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
