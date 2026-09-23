import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  final Duration duration;

  const SplashScreen({
    super.key,
    this.onFinished,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseScale;
  late final Animation<double> _pulseOpacity;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (smooth scale up + fade in, locked dead center)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.85, curve: Curves.easeOutBack),
      ),
    );

    // 2. Breathing ambient pulse behind logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.92, end: 1.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseOpacity = Tween<double>(begin: 0.25, end: 0.55).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();

    // 3. Guaranteed splash duration (default: 2.0s) before calling onFinished
    _timer = Timer(widget.duration, () {
      if (mounted && widget.onFinished != null) {
        widget.onFinished!();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background ambient soft gradient aura
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 0.85 * _pulseScale.value,
                      colors: [
                        AppColors.green.withValues(
                          alpha: _pulseOpacity.value * 0.35,
                        ),
                        AppColors.limeGradientEnd.withValues(
                          alpha: _pulseOpacity.value * 0.12,
                        ),
                        bgColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // Layout with equal top and bottom Spacers to guarantee DEAD-CENTER alignment
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // ─── DEAD-CENTER LOGO & BRANDING ────────────────────────────
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Animated Glowing Logo Badge
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Breathing Neon Halo
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseScale.value,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.green.withValues(
                                              alpha: _pulseOpacity.value * 0.7,
                                            ),
                                            AppColors.green.withValues(
                                              alpha: 0.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Premium App Logo Card
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: AppColors.green.withValues(
                                      alpha: 0.4,
                                    ),
                                    width: 1.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.green.withValues(
                                        alpha: 0.45,
                                      ),
                                      blurRadius: 36,
                                      spreadRadius: 3,
                                      offset: const Offset(0, 10),
                                    ),
                                    BoxShadow(
                                      color: AppColors.limeGradientEnd
                                          .withValues(alpha: 0.25),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(28),
                                  child: Image.asset(
                                    'assets/images/tripz_logo.png',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Elegant fallback if asset loading is delayed
                                      return Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.green,
                                              AppColors.limeGradientEnd,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: const Center(
                                          child: FaIcon(
                                            FontAwesomeIcons.busSimple,
                                            size: 52,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Brand Title: TRIP-Z
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'TRIP',
                                style: AppFonts.dmSans(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3.0,
                                  color: primaryTextColor,
                                ),
                              ),
                              Text(
                                '-',
                                style: AppFonts.dmSans(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  color: AppColors.green,
                                ),
                              ),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                      colors: [
                                        AppColors.greenBright,
                                        AppColors.limeGradientEnd,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                child: Text(
                                  'Z',
                                  style: AppFonts.dmSans(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Tagline
                          Text(
                            'Your Journey, Effortlessly Booked',
                            style: AppFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.1,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // ─── BOTTOM LOADING PROGRESS & FOOTER ───────────────────────
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Smooth Minimalist Progress Bar
                      SizedBox(
                        width: 120,
                        height: 3.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.green,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'TRIP-Z • Travel Across Cambodia',
                        style: AppFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.0,
                          color: secondaryTextColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
