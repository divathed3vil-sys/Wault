// lib/screens/vault_screen.dart
// Main screen — shows the list of WhatsApp accounts (or empty state).
// Handles staggered card animations, FAB, and navigation to sessions.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../services/engine_service.dart';
import '../theme/wault_theme.dart';
import '../utils/constants.dart';
import '../widgets/account_card.dart';
import '../widgets/empty_vault.dart';
import '../widgets/wault_fab.dart';
import 'add_account_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen>
    with TickerProviderStateMixin {
  List<Account> _accounts = [];
  bool _isLoading = true;

  // One animation controller per card for stagger
  final List<AnimationController> _cardControllers = [];
  final List<Animation<double>> _cardOpacities = [];
  final List<Animation<Offset>> _cardSlides = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    for (final c in _cardControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    final accounts = await AccountService.loadAccounts();
    if (mounted) {
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
      _initCardAnimations();
      _staggerCards();
    }
  }

  void _initCardAnimations() {
    // Dispose old controllers
    for (final c in _cardControllers) {
      c.dispose();
    }
    _cardControllers.clear();
    _cardOpacities.clear();
    _cardSlides.clear();

    for (int i = 0; i < _accounts.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: WaultConstants.cardAnimDuration,
      );
      _cardControllers.add(ctrl);
      _cardOpacities.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic),
        ),
      );
      _cardSlides.add(
        Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic),
        ),
      );
    }
  }

  void _staggerCards() async {
    for (int i = 0; i < _cardControllers.length; i++) {
      await Future.delayed(WaultConstants.cardStaggerDelay);
      if (mounted) _cardControllers[i].forward();
    }
  }

  Future<void> _onAccountAdded(List<Account> updatedAccounts) async {
    setState(() => _accounts = updatedAccounts);
    _initCardAnimations();
    _staggerCards();
  }

  Future<void> _onCardTap(Account account) async {
    HapticFeedback.lightImpact();
    await EngineService.openSession(account);
  }

  void _showAddSheet() {
    showAddAccountSheet(
      context,
      onAccountAdded: _onAccountAdded,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: WaultColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: WaultColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: WaultColors.primary,
                strokeWidth: 2,
              ),
            )
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_accounts.isEmpty) {
      return EmptyVault(onAddAccount: _showAddSheet);
    }

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _VaultHeader(accountCount: _accounts.length),
            ),

            // Account cards
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _accounts.length) return null;

                  final card = AccountCard(
                    account: _accounts[index],
                    onTap: () => _onCardTap(_accounts[index]),
                    onLongPress: () => _showDeleteDialog(_accounts[index]),
                  );

                  if (index < _cardControllers.length) {
                    return FadeTransition(
                      opacity: _cardOpacities[index],
                      child: SlideTransition(
                        position: _cardSlides[index],
                        child: card,
                      ),
                    );
                  }
                  return card;
                },
                childCount: _accounts.length,
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),

        // FAB — hidden when vault is full
        if (_accounts.length < WaultConstants.maxAccounts)
          Positioned(
            right: 0,
            bottom: 0,
            child: WaultFab(onTap: _showAddSheet),
          ),
      ],
    );
  }

  Future<void> _showDeleteDialog(Account account) async {
    HapticFeedback.mediumImpact();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: WaultColors.elevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: WaultColors.glassBorder, width: 0.5),
        ),
        title: Text(
          'Remove Account',
          style: GoogleFonts.inter(
            color: WaultColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Remove "${account.label}" from your vault?\n\nYour WhatsApp session data will remain on the device.',
          style: GoogleFonts.inter(
            color: WaultColors.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: WaultColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Remove',
              style: GoogleFonts.inter(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final updated = await AccountService.deleteAccount(account.id);
      setState(() => _accounts = updated);
      _initCardAnimations();
      _staggerCards();
    }
  }
}

class _VaultHeader extends StatelessWidget {
  final int accountCount;
  const _VaultHeader({required this.accountCount});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPad + 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Mini shield icon
              CustomPaint(
                size: const Size(22, 26),
                painter: _MiniShieldPainter(),
              ),
              const SizedBox(width: 10),
              Text(
                'WAult',
                style: GoogleFonts.inter(
                  color: WaultColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$accountCount / 5 account${accountCount == 1 ? '' : 's'}',
            style: GoogleFonts.inter(
              color: WaultColors.textTertiary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniShieldPainter extends CustomPainter {
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

    canvas.drawPath(
      path,
      Paint()
        ..color = WaultColors.primary
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
