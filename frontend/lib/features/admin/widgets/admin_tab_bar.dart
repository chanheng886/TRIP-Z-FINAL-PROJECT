import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AdminTabItem {
  final String title;
  final FaIconData icon;

  const AdminTabItem({required this.title, required this.icon});
}

class AdminTabBar extends StatelessWidget {
  final ScrollController scrollController;
  final List<AdminTabItem> tabs;
  final int currentTabIndex;
  final ValueChanged<int> onTabSelected;
  final int? Function(int index) getTabCount;
  final bool isDark;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;

  const AdminTabBar({
    super.key,
    required this.scrollController,
    required this.tabs,
    required this.currentTabIndex,
    required this.onTabSelected,
    required this.getTabCount,
    required this.isDark,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: ListView.separated(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = currentTabIndex == index;
          final count = getTabCount(index);

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onTabSelected(index),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [AppColors.green, AppColors.greenBright],
                        )
                      : null,
                  color: isSelected ? null : cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.green : borderColor,
                    width: isSelected ? 1.6 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.green.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : AppColors.green.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: FaIcon(
                          tab.icon,
                          size: 11,
                          color: isSelected ? Colors.white : AppColors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      tab.title,
                      style: AppFonts.dmSans(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: isSelected ? Colors.white : secondaryText,
                      ),
                    ),
                    if (count != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : (isDark
                                    ? const Color(0xFF2C2C30)
                                    : const Color(0xFFE2E2E6)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: AppFonts.dmSans(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : primaryText,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
