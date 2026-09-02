import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AiChatWelcomeView extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String> onSelectSuggestion;

  const AiChatWelcomeView({
    super.key,
    required this.isDark,
    required this.onSelectSuggestion,
  });

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      'Buses to Siem Reap',
      'Budget under \$15',
      'VIP buses available',
      'Travel tips',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.robot,
                  color: AppColors.green,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hi! I\'m TripZ AI',
              style: AppFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about bus routes, prices, or get recommendations based on your budget!',
              textAlign: TextAlign.center,
              style: AppFonts.dmSans(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions.map((s) {
                return GestureDetector(
                  onTap: () => onSelectSuggestion(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2D35)
                          : AppColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      s,
                      style: AppFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
