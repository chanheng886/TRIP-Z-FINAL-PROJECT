import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AdminHeroBanner extends StatelessWidget {
  final double totalRevenue;
  final int totalBookings;
  final int confirmedBookings;
  final int totalBuses;
  final int totalRoutes;
  final bool isDark;
  final VoidCallback onViewBookings;

  const AdminHeroBanner({
    super.key,
    required this.totalRevenue,
    required this.totalBookings,
    required this.confirmedBookings,
    required this.totalBuses,
    required this.totalRoutes,
    required this.isDark,
    required this.onViewBookings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1C1C1F), Color(0xFF121214)]
              : const [Color(0xFF1A1A2E), Color(0xFF2E3048)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2E) : const Color(0xFF3B3D58),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL REVENUE',
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF9CA3AF),
                        letterSpacing: 1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${totalRevenue.toStringAsFixed(2)}',
                      style: AppFonts.dmSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onViewBookings,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.green.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Bookings',
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.greenBright,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 13,
                        color: AppColors.greenBright,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBannerMiniStat(
                  'Bookings',
                  '$totalBookings',
                  '$confirmedBookings paid',
                  AppColors.greenBright,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _buildBannerMiniStat(
                  'Buses',
                  '$totalBuses',
                  'Fleet count',
                  AppColors.green,
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _buildBannerMiniStat(
                  'Routes',
                  '$totalRoutes',
                  'Active lines',
                  AppColors.greenBright,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerMiniStat(
    String label,
    String value,
    String sub,
    Color accent,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: AppFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: accent,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          sub,
          style: AppFonts.dmSans(fontSize: 10, color: const Color(0xFF9CA3AF)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
