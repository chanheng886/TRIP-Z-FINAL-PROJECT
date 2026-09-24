import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onGetStarted;

  const OnboardingScreen({
    super.key,
    required this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Bottom Cityscape & Bus Illustration from design
          Positioned.fill(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Image.asset(
                  'assets/images/onboarding_bg.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),

          // Main Foreground Content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28.0),
                            child: Column(
                              children: [
                            const SizedBox(height: 24),

                            // App Logo Badge
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00B14F).withValues(alpha: 0.32),
                                    blurRadius: 18,
                                    offset: const Offset(0, 7),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: Image.asset(
                                  'assets/images/tripz_icon.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: const Color(0xFF00B14F),
                                    child: const Icon(
                                      Icons.directions_bus_rounded,
                                      size: 42,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Brand Name: Trip Z
                            RichText(
                              text: TextSpan(
                                style: AppFonts.dmSans(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Trip ',
                                    style: TextStyle(color: Color(0xFF1E293B)),
                                  ),
                                  TextSpan(
                                    text: 'Z',
                                    style: TextStyle(color: Color(0xFF00B14F)),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Tagline
                            Text(
                              'Your ride. A smarter way.',
                              style: AppFonts.dmSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),

                            const SizedBox(height: 36),

                            // ─── 3 GUIDELINE FEATURE CARDS ────────────────────────
                            _buildFeatureRow(
                              iconWidget: const Icon(
                                Icons.location_on_rounded,
                                size: 22,
                                color: Color(0xFF00B14F),
                              ),
                              title: 'Find Routes',
                              subtitle: 'See the nearest bus and plan your trip',
                            ),

                            const SizedBox(height: 20),

                            _buildFeatureRow(
                              iconWidget: const Icon(
                                Icons.access_time_filled_rounded,
                                size: 22,
                                color: Color(0xFF00B14F),
                              ),
                              title: 'Real-time Tracking',
                              subtitle: 'Know when your bus arrives',
                            ),

                            const SizedBox(height: 20),

                            _buildFeatureRow(
                              iconWidget: const FaIcon(
                                FontAwesomeIcons.ticket,
                                size: 18,
                                color: Color(0xFF00B14F),
                              ),
                              title: 'Travel with Ease',
                              subtitle: 'Simple. Fast. Reliable.',
                            ),

                            const Spacer(),
                            const SizedBox(height: 24),

                            // ─── GET STARTED ACTION BUTTON ────────────────────────
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: onGetStarted,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00B14F),
                                  foregroundColor: Colors.white,
                                  elevation: 5,
                                  shadowColor: const Color(0xFF00B14F).withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Get Started',
                                      style: AppFonts.dmSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Step Indicator Dots (● ○ ○)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 18,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00B14F),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCBD5E1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFCBD5E1),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow({
    required Widget iconWidget,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Circular Mint Icon Container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F8EE),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00B14F).withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Center(
            child: iconWidget,
          ),
        ),

        const SizedBox(width: 16),

        // Text Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
