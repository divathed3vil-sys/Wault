// lib/widgets/wault_fab.dart
// Floating action button with an infinite slowly-rotating sweep gradient glow.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/wault_theme.dart';

class WaultFab extends StatefulWidget {
  final VoidCallback onTap;
  const WaultFab({super.key, required this.onTap});

  @override
  State<WaultFab> createState() => _WaultFabState();
}

class _WaultFabState extends State<WaultFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20, bottom: 28),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Rotating gradient ring
                Transform.rotate(
                  angle: _glowController.value * 2 * math.pi,
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: const [
                          Colors.transparent,
                          Color(0x4025D366),
                          Color(0xCC25D366),
                          Color(0x4025D366),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                        startAngle: 0,
                        endAngle: 2 * math.pi,
                      ),
                    ),
                  ),
                ),
                // Button core
                child!,
              ],
            );
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: WaultColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: WaultColors.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.black,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}
