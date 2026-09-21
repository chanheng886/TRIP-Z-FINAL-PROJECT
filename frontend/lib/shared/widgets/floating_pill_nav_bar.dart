import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class PillNavItem {
  final dynamic icon;
  final dynamic activeIcon;
  final String label;

  const PillNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

/// A modern floating frosted-glass / see-through capsule bottom navigation bar.
/// Uses BackdropFilter and translucent surfaces so content underneath can be seen through.
class FloatingPillNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<PillNavItem> items;
  final Color activeColor;
  final Widget? trailing;

  const FloatingPillNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.activeColor = const Color(0xff4FD18B),
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Translucent see-through frosted glass background
    final barBg = isDarkMode
        ? const Color(0xFF14161C).withValues(alpha: 0.68)
        : Colors.white.withValues(alpha: 0.72);

    final barBorder = isDarkMode
        ? Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1.0)
        : Border.all(color: Colors.black.withValues(alpha: 0.08), width: 1.0);

    final inactiveColor = isDarkMode
        ? const Color(0xFFA0AEC0)
        : const Color(0xFF64748B);

    final activePillBg = isDarkMode
        ? activeColor.withValues(alpha: 0.22)
        : activeColor.withValues(alpha: 0.15);

    final activePillBorder = isDarkMode
        ? Border.all(color: activeColor.withValues(alpha: 0.38), width: 1.0)
        : Border.all(color: activeColor.withValues(alpha: 0.25), width: 1.0);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 4),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        decoration: BoxDecoration(
                          color: barBg,
                          borderRadius: BorderRadius.circular(36),
                          border: barBorder,
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.black.withValues(alpha: 0.35)
                                  : Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: activeColor.withValues(alpha: isDarkMode ? 0.08 : 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: List.generate(items.length, (index) {
                            final item = items[index];
                            final isSelected = index == currentIndex;
                            return _NavItemWidget(
                              item: item,
                              isSelected: isSelected,
                              isDarkMode: isDarkMode,
                              activeColor: activeColor,
                              inactiveColor: inactiveColor,
                              activePillBg: activePillBg,
                              activePillBorder: activePillBorder,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                onTap(index);
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 12),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemWidget extends StatelessWidget {
  final PillNavItem item;
  final bool isSelected;
  final bool isDarkMode;
  final Color activeColor;
  final Color inactiveColor;
  final Color activePillBg;
  final BoxBorder activePillBorder;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.isDarkMode,
    required this.activeColor,
    required this.inactiveColor,
    required this.activePillBg,
    required this.activePillBorder,
    required this.onTap,
  });

  Widget _buildIcon(dynamic iconData, Color color, double size) {
    if (iconData is Widget) return iconData;
    if (iconData is FaIconData) {
      return FaIcon(iconData, size: size, color: color);
    }
    if (iconData is IconData) {
      return Icon(iconData, size: size, color: color);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = AppFonts.dmSans(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: activeColor,
      letterSpacing: -0.2,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: isSelected
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
              : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? activePillBg : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            border: isSelected ? activePillBorder : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildIcon(
                isSelected ? item.activeIcon : item.icon,
                isSelected ? activeColor : inactiveColor,
                19,
              ),
              if (isSelected) ...[
                const SizedBox(width: 7),
                Text(
                  item.label,
                  maxLines: 1,
                  softWrap: false,
                  style: textStyle,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
