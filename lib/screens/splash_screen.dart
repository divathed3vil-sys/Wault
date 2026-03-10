// lib/screens/splash_screen.dart
// Animated splash screen. Shows WAult logo with scale + fade,
// "a project by DIVA" subtitle, green radial glow, then transitions to vault.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/wault_theme.dart';
import '../utils/constants.dart';
import 'vault_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _glowController;
  late AnimationController _exitController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _glowPulse;
  late Animation<double> _exitOpacity;
  late Animation<Offset> _exitSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: WaultColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _logoController = AnimationController(
      vsync: this,
      duration: WaultConstants.splashLogoDuration,
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _exitController = AnimationController(
      vsync: this,
      duration: WaultConstants.splashExitDuration,
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _glowPulse = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    _exitSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.05),
    ).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(WaultConstants.splashTextDelay + const Duration(milliseconds: 200));
    _textController.forward();

    await Future.delayed(
      WaultConstants.splashTotalDuration - WaultConstants.splashTextDelay -
          const Duration(milliseconds: 200) - WaultConstants.splashExitDuration,
    );
    _exitController.forward();

    await Future.delayed(WaultConstants.splashExitDuration);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const VaultScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: WaultConstants.screenTransitionDuration,
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _glowController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WaultColors.background,
      body: FadeTransition(
        opacity: _exitOpacity,
        child: SlideTransition(
          position: _exitSlide,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glow + Logo stack
                AnimatedBuilder(
                  animation: Listenable.merge(
                      [_logoController, _glowController]),
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Green radial glow
                        Opacity(
                          opacity: _glowPulse.value * _logoOpacity.value,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Color(0x6025D366),
                                  Color(0x2025D366),
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Logo
                        Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: const _WaultShieldLogo(size: 88),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 28),

                // WAult wordmark
                FadeTransition(
                  opacity: _textOpacity,
                  child: Text(
                    'WAult',
                    style: GoogleFonts.inter(
                      color: WaultColors.textPrimary,
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                FadeTransition(
                  opacity: _subtitleOpacity,
                  child: Text(
                    'a project by DIVA',
                    style: GoogleFonts.inter(
                      color: WaultColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom shield logo painted with Canvas containing the letter W.
class _WaultShieldLogo extends StatelessWidget {
  final double size;
  const _WaultShieldLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.15),
      painter: _ShieldPainter(),
    );
  }
}

class _ShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Shield path
    final shieldPath = Path();
    shieldPath.moveTo(w * 0.5, 0);
    shieldPath.lineTo(w, h * 0.18);
    shieldPath.lineTo(w, h * 0.55);
    shieldPath.cubicTo(w, h * 0.82, w * 0.5, h, w * 0.5, h);
    shieldPath.cubicTo(w * 0.5, h, 0, h * 0.82, 0, h * 0.55);
    shieldPath.lineTo(0, h * 0.18);
    shieldPath.close();

    // Shield fill
    final fillPaint = Paint()
      ..color = const Color(0xFF1A1A24)
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, fillPaint);

    // Shield border with green gradient
    final borderPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF25D366), Color(0xFF1A8C44)],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(shieldPath, borderPaint);

    // Draw "W" letter inside shield
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'W',
        style: TextStyle(
          color: const Color(0xFF25D366),
          fontSize: w * 0.52,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (w - textPainter.width) / 2,
        h * 0.25,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
