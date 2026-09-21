import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AdminDesktopKpiCards extends StatelessWidget {
  final int busCount;
  final int routeCount;
  final int scheduleCount;
  final Color cardBg;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const AdminDesktopKpiCards({
    super.key,
    required this.busCount,
    required this.routeCount,
    required this.scheduleCount,
    required this.cardBg,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiStatTile(
            title: 'Fleet Buses',
            count: busCount,
            subtitle: 'Registered luxury & sleeper coaches',
            icon: FontAwesomeIcons.busSimple,
            accentColor: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiStatTile(
            title: 'Inter-Provincial Routes',
            count: routeCount,
            subtitle: 'Expressways & national highways',
            icon: FontAwesomeIcons.route,
            accentColor: AppColors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKpiStatTile(
            title: 'Active Schedules',
            count: scheduleCount,
            subtitle: 'Scheduled trips available for booking',
            icon: FontAwesomeIcons.calendarCheck,
            accentColor: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiStatTile({
    required String title,
    required int count,
    required String subtitle,
    required FaIconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: FaIcon(icon, color: accentColor, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$count',
                      style: AppFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: AppFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppFonts.dmSans(fontSize: 11, color: textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
