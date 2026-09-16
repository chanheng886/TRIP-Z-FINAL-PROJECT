import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';

/// A horizontal scrollable row of city filter chips.
class MapCityFilterChips extends StatelessWidget {
  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String> onCityChanged;
  final Color cardBg;
  final Color textPrimary;

  const MapCityFilterChips({
    super.key,
    required this.cities,
    required this.selectedCity,
    required this.onCityChanged,
    required this.cardBg,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final city = cities[index];
          final isSelected = selectedCity == city;
          return GestureDetector(
            onTap: () => onCityChanged(city),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF22C55E) : cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  city,
                  style: AppFonts.dmSans(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : textPrimary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
