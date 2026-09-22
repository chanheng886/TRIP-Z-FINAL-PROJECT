import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/ai/widgets/chatbot_avatar.dart';

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
    final cardBg = isDark ? const Color(0xFF1E222B) : const Color(0xFFF8FAFC);
    final borderColor =
        isDark ? const Color(0xFF2C3240) : const Color(0xFFE2E8F0);
    final textPrimary =
        isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final suggestions = [
      _SuggestionItem(
        icon: FontAwesomeIcons.bus,
        iconColor: const Color(0xFF3B82F6),
        title: 'Buses to Siem Reap',
        subtitle: 'Find next departures from Phnom Penh',
        prompt: 'Find buses from Phnom Penh to Siem Reap today',
      ),
      _SuggestionItem(
        icon: FontAwesomeIcons.water,
        iconColor: const Color(0xFF06B6D4),
        title: 'Sihanoukville Expressway',
        subtitle: 'Fast 2.5 hour VIP van & coach options',
        prompt: 'What are the fastest buses from Phnom Penh to Sihanoukville?',
      ),
      _SuggestionItem(
        icon: FontAwesomeIcons.moon,
        iconColor: const Color(0xFF8B5CF6),
        title: 'Overnight Sleeper Bus',
        subtitle: 'Night hotel-bus for long distance travel',
        prompt: 'Are there overnight sleeper buses available?',
      ),
      _SuggestionItem(
        icon: FontAwesomeIcons.tag,
        iconColor: AppColors.green,
        title: 'Budget Trips under \$12',
        subtitle: 'Best value fares currently active',
        prompt: 'Show me bus trips with tickets under \$12',
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Futuristic AI Orb
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.greenBright.withValues(alpha: 0.3),
                      AppColors.green.withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                    stops: const [0.3, 0.7, 1.0],
                  ),
                ),
              ),
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardBg,
                  border: Border.all(
                    color: AppColors.green.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.30),
                      blurRadius: 18,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: ChatbotAvatar(
                    size: 48,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title & Greeting
          Text(
            'Where to next?',
            style: AppFonts.dmSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ask me for live bus schedules, prices, or recommendations for your trip across Cambodia.',
            textAlign: TextAlign.center,
            style: AppFonts.dmSans(
              fontSize: 13,
              color: textSecondary,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),

          // Feature capability badges
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _buildFeatureBadge('⚡ Live Schedules', isDark),
              _buildFeatureBadge('🎟️ Instant Seat Booking', isDark),
              _buildFeatureBadge('💰 Best Fare Matching', isDark),
            ],
          ),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'TRY ASKING:',
              style: AppFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: textSecondary,
                letterSpacing: 0.8,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Suggestion Cards Grid
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = suggestions[index];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelectSuggestion(item.prompt),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.2 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: FaIcon(
                              item.icon,
                              color: item.iconColor,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppFonts.dmSans(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                style: AppFonts.dmSans(
                                  fontSize: 11.5,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        FaIcon(
                          FontAwesomeIcons.arrowRight,
                          size: 12,
                          color: textSecondary.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Text(
        label,
        style: AppFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
        ),
      ),
    );
  }
}

class _SuggestionItem {
  final FaIconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String prompt;

  const _SuggestionItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.prompt,
  });
}
