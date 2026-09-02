import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/ai/model/ai_message.dart';

class ChatBubble extends StatelessWidget {
  final AiMessage message;
  final Function(BusRecommendation)? onBookNow;

  const ChatBubble({super.key, required this.message, this.onBookNow});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: EdgeInsets.only(
          left: isUser ? 60 : 12,
          right: isUser ? 12 : 60,
          top: 4,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.green
                    : isDark
                        ? const Color(0xFF2A2D35)
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: Text(
                message.content,
                style: AppFonts.dmSans(
                  fontSize: 14,
                  color: isUser
                      ? Colors.white
                      : isDark
                          ? Colors.white
                          : const Color(0xFF334155),
                  height: 1.5,
                ),
              ),
            ),
            if (!isUser && message.recommendations.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...message.recommendations.map(
                (rec) => _buildRecommendationCard(context, isDark, rec),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    bool isDark,
    BusRecommendation rec,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2D35) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rec.busType,
                  style: AppFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  rec.companyName,
                  style: AppFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.route, size: 11, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                '${rec.fromLocation} → ${rec.toLocation}',
                style: AppFonts.dmSans(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const FaIcon(FontAwesomeIcons.clock, size: 11, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                '${rec.departureTime} - ${rec.arrivalTime}',
                style: AppFonts.dmSans(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                '\$${rec.price.toStringAsFixed(0)}',
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => onBookNow?.call(rec),
              icon: const FaIcon(FontAwesomeIcons.ticket, size: 12),
              label: Text(
                'Book Now',
                style: AppFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
