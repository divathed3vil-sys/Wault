// lib/widgets/account_card.dart
// Glass-style account card with press scale animation, avatar, label, chevron.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/account.dart';
import '../theme/wault_theme.dart';

class AccountCard extends StatefulWidget {
  final Account account;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const AccountCard({
    super.key,
    required this.account,
    required this.onTap,
    this.onLongPress,
  });

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    setState(() => _isPressed = false);
    HapticFeedback.lightImpact();
    widget.onTap();
  }

  void _onTapCancel() {
    _pressController.reverse();
    setState(() => _isPressed = false);
  }

  Color get _accentColor => hexColor(widget.account.accentColorHex);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onLongPress: widget.onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: WaultColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed
                  ? _accentColor.withOpacity(0.3)
                  : WaultColors.glassBorder,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar circle
                _AccountAvatar(
                  label: widget.account.label,
                  accentColor: _accentColor,
                ),

                const SizedBox(width: 14),

                // Text column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.account.label,
                        style: GoogleFonts.inter(
                          color: WaultColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tap to open',
                        style: GoogleFonts.inter(
                          color: WaultColors.textTertiary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: WaultColors.textTertiary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountAvatar extends StatelessWidget {
  final String label;
  final Color accentColor;

  const _AccountAvatar({required this.label, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final initial = label.isNotEmpty ? label[0].toUpperCase() : '?';
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: accentColor.withOpacity(0.35),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.inter(
            color: accentColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
