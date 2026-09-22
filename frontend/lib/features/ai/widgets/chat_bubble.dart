import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/ai/model/ai_message.dart';
import 'package:frontend/features/ai/widgets/chatbot_avatar.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final AiMessage message;
  final Function(BusRecommendation)? onBookNow;

  const ChatBubble({super.key, required this.message, this.onBookNow});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final timeStr = DateFormat('hh:mm a').format(message.timestamp);

    final cardBg = isDark ? const Color(0xFF1E222B) : const Color(0xFFF8FAFC);
    final borderColor =
        isDark ? const Color(0xFF2C3240) : const Color(0xFFE2E8F0);
    final textPrimary =
        isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: isUser
          ? _buildUserMessage(context, isDark, timeStr)
          : _buildAiMessage(
              context,
              isDark,
              cardBg,
              borderColor,
              textPrimary,
              textSecondary,
              timeStr,
            ),
    );
  }

  Widget _buildUserMessage(BuildContext context, bool isDark, String timeStr) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(left: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.green, AppColors.greenBright],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: AppFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                timeStr,
                style: AppFonts.dmSans(
                  fontSize: 10,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiMessage(
    BuildContext context,
    bool isDark,
    Color cardBg,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
    String timeStr,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        margin: const EdgeInsets.only(right: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mini AI Avatar
            Container(
              margin: const EdgeInsets.only(top: 2),
              child: const ChatbotAvatar(
                size: 30,
              ),
            ),

            const SizedBox(width: 10),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: isDark ? 0.25 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.content,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        color: textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  // Bus Recommendation Cards
                  if (message.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...message.recommendations.map(
                      (rec) => _buildBoardingPassCard(
                        context,
                        isDark,
                        rec,
                        borderColor,
                        textPrimary,
                        textSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      timeStr,
                      style: AppFonts.dmSans(
                        fontSize: 10,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardingPassCard(
    BuildContext context,
    bool isDark,
    BusRecommendation rec,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    final ticketBg = isDark ? const Color(0xFF1E232E) : Colors.white;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ticketBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.03)
                  : const Color(0xFFF8FAFC),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF2B3342) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.bus,
                        color: AppColors.green,
                        size: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rec.companyName,
                      style: AppFonts.dmSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    rec.busType,
                    style: AppFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Route Timeline Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Origin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.fromLocation,
                            style: AppFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              FaIcon(
                                FontAwesomeIcons.clock,
                                size: 10,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rec.departureTime,
                                style: AppFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Route connector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.arrowRight,
                            size: 14,
                            color: AppColors.green,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'DIRECT',
                            style: AppFonts.dmSans(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Destination
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            rec.toLocation,
                            style: AppFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.clock,
                                size: 10,
                                color: textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rec.arrivalTime,
                                style: AppFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Seat & Price badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${rec.availableSeats} seats left',
                            style: AppFonts.dmSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$${rec.price.toStringAsFixed(0)}',
                            style: AppFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green,
                            ),
                          ),
                          TextSpan(
                            text: ' / seat',
                            style: AppFonts.dmSans(
                              fontSize: 11.5,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => onBookNow?.call(rec),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.green, AppColors.greenBright],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.ticket,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Select Seat & Book',
                              style: AppFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const FaIcon(
                              FontAwesomeIcons.arrowRight,
                              size: 11,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
