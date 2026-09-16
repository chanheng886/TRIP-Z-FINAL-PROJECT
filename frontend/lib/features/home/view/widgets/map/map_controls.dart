import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:frontend/shared/service/user_location_service.dart';

/// Floating map control buttons: zoom in, zoom out, and recenter to GPS.
class MapControls extends StatelessWidget {
  final MapController mapController;
  final UserLocationService userLocService;
  final Color cardBg;
  final Color iconColor;

  const MapControls({
    super.key,
    required this.mapController,
    required this.userLocService,
    required this.cardBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MapControlButton(
          icon: Icons.add_rounded,
          cardBg: cardBg,
          iconColor: iconColor,
          onTap: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom + 1,
          ),
        ),
        const SizedBox(height: 8),
        _MapControlButton(
          icon: Icons.remove_rounded,
          cardBg: cardBg,
          iconColor: iconColor,
          onTap: () => mapController.move(
            mapController.camera.center,
            mapController.camera.zoom - 1,
          ),
        ),
        const SizedBox(height: 8),
        _MapControlButton(
          icon: Icons.my_location_rounded,
          cardBg: cardBg,
          iconColor: const Color(0xFF2563EB),
          onTap: () async {
            await userLocService.determinePosition();
            mapController.move(userLocService.userLatLng, 15.0);
          },
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final Color cardBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _MapControlButton({
    required this.icon,
    required this.cardBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: cardBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Icon(icon, size: 20, color: iconColor)),
      ),
    );
  }
}
