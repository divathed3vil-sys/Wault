// lib/widgets/empty_vault.dart
// Shown on vault screen when no accounts have been added yet.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/wault_theme.dart';

class EmptyVault extends StatelessWidget {
  final VoidCallback onAddAccount;

  const EmptyVault({super.key, required this.onAddAccount});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dimmed shield icon
            Opacity(
              opacity: 0.12,
              child: CustomPaint(
                size: const Size(80, 92),
                painter: _DimShieldPainter(),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Your Vault is Empty',
              style: GoogleFonts.inter(
                color: WaultColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            Text(
              'Add your first WhatsApp account\nto get started',
              style: GoogleFonts.inter(
                color: WaultColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 36),

            _AddAccountButton(onTap: onAddAccount),
          ],
        ),
      ),
    );
  }
}

class _AddAccountButton extends StatefulWidget {
  final VoidCallback onTap;
  const _AddAccountButton({required this.onTap});

  @override
  State<_AddAccountButton> createState() => _AddAccountButtonState();
}

class _AddAccountButtonState extends State<_AddAccountButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: WaultColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: WaultColors.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Text(
                'Add Account',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DimShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.18);
    path.lineTo(w, h * 0.55);
    path.cubicTo(w, h * 0.82, w * 0.5, h, w * 0.5, h);
    path.cubicTo(w * 0.5, h, 0, h * 0.82, 0, h * 0.55);
    path.lineTo(0, h * 0.18);
    path.close();

    final paint = Paint()
      ..color = WaultColors.textPrimary
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
