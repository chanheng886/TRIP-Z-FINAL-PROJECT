import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

class HotlineCard extends StatelessWidget {
  final Color cardColor;
  final bool isDarkMode;
  final String phone1;
  final String phone2;
  final VoidCallback onCardTap;
  final VoidCallback onCallPhone1;
  final VoidCallback onCallPhone2;

  const HotlineCard({
    super.key,
    required this.cardColor,
    required this.isDarkMode,
    required this.phone1,
    required this.phone2,
    required this.onCardTap,
    required this.onCallPhone1,
    required this.onCallPhone2,
  });

  @override
  Widget build(BuildContext context) {
    final primaryText =
        isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final secondaryText =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onCardTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.phone,
                          color: Color(0xFF3B82F6),
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'hotline'.tr,
                            style: AppFonts.dmSans(
                              fontSize: 13,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$phone1  •  $phone2',
                            style: AppFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'call_now'.tr,
                            style: AppFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 10,
                            color: Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Quick Call Action Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    QuickPhoneChip(
                      phone: phone1,
                      isDarkMode: isDarkMode,
                      accentColor: const Color(0xFF10B981),
                      onTap: onCallPhone1,
                    ),
                    QuickPhoneChip(
                      phone: phone2,
                      isDarkMode: isDarkMode,
                      accentColor: const Color(0xFF3B82F6),
                      onTap: onCallPhone2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuickPhoneChip extends StatelessWidget {
  final String phone;
  final bool isDarkMode;
  final Color accentColor;
  final VoidCallback onTap;

  const QuickPhoneChip({
    super.key,
    required this.phone,
    required this.isDarkMode,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDarkMode
          ? const Color(0xFF282F3D)
          : accentColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.call,
                size: 13,
                color: accentColor,
              ),
              const SizedBox(width: 6),
              Text(
                phone,
                style: AppFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
