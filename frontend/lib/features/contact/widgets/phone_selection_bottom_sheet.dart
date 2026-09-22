import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';

class PhoneSelectionBottomSheet extends StatelessWidget {
  final String phone1;
  final String phone2;
  final bool isDarkMode;
  final ValueChanged<String> onSelectPhone;

  const PhoneSelectionBottomSheet({
    super.key,
    required this.phone1,
    required this.phone2,
    required this.isDarkMode,
    required this.onSelectPhone,
  });

  static Future<void> show({
    required BuildContext context,
    required String phone1,
    required String phone2,
    required bool isDarkMode,
    required ValueChanged<String> onSelectPhone,
  }) {
    final sheetBg = isDarkMode ? const Color(0xFF1E222B) : Colors.white;

    return showModalBottomSheet(
      context: context,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => PhoneSelectionBottomSheet(
        phone1: phone1,
        phone2: phone2,
        isDarkMode: isDarkMode,
        onSelectPhone: (selected) {
          Navigator.of(ctx).pop();
          onSelectPhone(selected);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryText =
        isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final secondaryText =
        isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final itemBg =
        isDarkMode ? const Color(0xFF282F3D) : const Color(0xFFF8FAFC);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'select_phone_number'.tr,
              style: AppFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'select_phone_subtitle'.tr,
              style: AppFonts.dmSans(
                fontSize: 13,
                color: secondaryText,
              ),
            ),
            const SizedBox(height: 18),

            // Line 1
            PhoneOptionTile(
              number: phone1,
              label: 'hotline_line1'.tr,
              bgColor: itemBg,
              primaryText: primaryText,
              secondaryText: secondaryText,
              accentColor: const Color(0xFF10B981),
              onTap: () => onSelectPhone(phone1),
            ),
            const SizedBox(height: 10),

            // Line 2
            PhoneOptionTile(
              number: phone2,
              label: 'hotline_line2'.tr,
              bgColor: itemBg,
              primaryText: primaryText,
              secondaryText: secondaryText,
              accentColor: const Color(0xFF3B82F6),
              onTap: () => onSelectPhone(phone2),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class PhoneOptionTile extends StatelessWidget {
  final String number;
  final String label;
  final Color bgColor;
  final Color primaryText;
  final Color secondaryText;
  final Color accentColor;
  final VoidCallback onTap;

  const PhoneOptionTile({
    super.key,
    required this.number,
    required this.label,
    required this.bgColor,
    required this.primaryText,
    required this.secondaryText,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.phone_forwarded,
                    color: accentColor,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        color: secondaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      number,
                      style: AppFonts.dmSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.call,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'call_now'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
