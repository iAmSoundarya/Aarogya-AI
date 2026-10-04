import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _particleCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _pillsFade;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));
    _pillsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _textCtrl,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut)));

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1600));
    _navigate();
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone =
        prefs.getBool(AppConstants.keyOnboardingDone) ?? false;
    final modelDownloaded =
        prefs.getBool(AppConstants.keyModelDownloaded) ?? false;
    if (!mounted) return;
    if (!onboardingDone) {
      context.go(AppRoutes.onboarding);
    } else if (!modelDownloaded) {
      context.go(AppRoutes.modelDownload);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _pulseCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // Deep green gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A3D0A),
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Animated floating particles
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _ParticlePainter(_particleCtrl.value),
            ),
          ),

          // Large background circle (decorative)
          Positioned(
            right: -size.width * 0.25,
            top: -size.height * 0.1,
            child: AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) => Container(
                width: size.width * 0.9,
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white
                      .withOpacity(0.03 + _pulseCtrl.value * 0.02),
                ),
              ),
            ),
          ),
          Positioned(
            left: -size.width * 0.3,
            bottom: -size.height * 0.05,
            child: Container(
              width: size.width * 0.7,
              height: size.width * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGold.withOpacity(0.05),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Logo icon with pulse ring
                AnimatedBuilder(
                  animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
                  builder: (_, __) => FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulse ring
                          Container(
                            width: 110 + _pulseCtrl.value * 12,
                            height: 110 + _pulseCtrl.value * 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.accentGold
                                    .withOpacity(0.15 + _pulseCtrl.value * 0.1),
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Inner ring
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                          ),
                          // Icon
                          const Icon(
                            Icons.health_and_safety_rounded,
                            size: 52,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App name + tagline
                SlideTransition(
                  position: _textSlide,
                  child: FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        // App name
                        const Text(
                          'AarogyaAI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Gold accent bar
                        AnimatedBuilder(
                          animation: _textCtrl,
                          builder: (_, __) => Container(
                            width: 180 * _textCtrl.value,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  AppTheme.accentGold,
                                  Colors.transparent,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tagline
                        FadeTransition(
                          opacity: _taglineFade,
                          child: Text(
                            'Healthcare Intelligence Without Internet',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.80),
                              fontSize: 14,
                              letterSpacing: 0.3,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Feature pills
                FadeTransition(
                  opacity: _pillsFade,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: const [
                      _FeaturePill('🌐 Offline'),
                      _FeaturePill('🗣️ Multilingual'),
                      _FeaturePill('🔒 Private'),
                      _FeaturePill('🧠 Edge AI'),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Loading dots
                FadeTransition(
                  opacity: _pillsFade,
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (_, __) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final delay = i / 3;
                        final val =
                            (((_pulseCtrl.value + delay) % 1.0)).clamp(0.2, 1.0);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.accentGold.withOpacity(val),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // NIELIT branding at bottom
                FadeTransition(
                  opacity: _pillsFade,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      'Powered by NIELIT',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12,
                        letterSpacing: 0.5,
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

class _FeaturePill extends StatelessWidget {
  const _FeaturePill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.20)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

// Particle painter for background visual
class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.t);
  final double t;

  static final _rng = math.Random(42);
  static final _particles = List.generate(18, (i) => [
    _rng.nextDouble(), // x
    _rng.nextDouble(), // y
    _rng.nextDouble() * 0.4 + 0.05, // size
    _rng.nextDouble(), // phase
  ]);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final phase = (t + p[3]) % 1.0;
      final y = (p[1] - phase * 0.3) % 1.0;
      final opacity = (math.sin(phase * math.pi)).clamp(0.0, 1.0) * 0.25;
      final paint = Paint()
        ..color = AppTheme.accentGold.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(p[0] * size.width, y * size.height),
        p[2] * 4,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t;
}
