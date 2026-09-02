import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AdminSectionHeader extends StatelessWidget {
  final String title;
  final FaIconData icon;
  final Color primaryText;
  final VoidCallback? onViewAll;

  const AdminSectionHeader({
    super.key,
    required this.title,
    required this.icon,
    required this.primaryText,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: FaIcon(icon, size: 11, color: AppColors.green),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (onViewAll != null)
          InkWell(
            onTap: onViewAll,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Manage',
                    style: AppFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: AppColors.green,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
