import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  final Duration duration;

  const SplashScreen({
    super.key,
    this.onFinished,
    this.duration = const Duration(milliseconds: 2500),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _progressController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _progressAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (gentle scale up + fade in)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    // 2. Animated progress bar (fills smoothly across the duration)
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.duration.inMilliseconds * 0.85).round(),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.05, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _entranceController.forward();
    _progressController.forward();

    // 3. Trigger onFinished after guaranteed duration
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
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Illustration (Mint hills and circular accents from design)
          Positioned.fill(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Image.asset(
                  'assets/images/splash_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Elegant fallback background if asset loading is delayed
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Color(0xFFF0FDF4)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Dead-Center Logo, Branding & Progress Bar
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Green Rounded App Logo
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00B14F).withValues(alpha: 0.35),
                              blurRadius: 24,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Image.asset(
                            'assets/images/tripz_icon.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF00B14F),
                              child: const Icon(
                                Icons.directions_bus_rounded,
                                size: 52,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // App Name: Trip Z
                      RichText(
                        text: TextSpan(
                          style: AppFonts.dmSans(
                            fontSize: 34,
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

                      // Modern Pill Progress Bar
                      Container(
                        width: 76,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F7EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00B14F),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
