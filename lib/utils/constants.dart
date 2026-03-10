// lib/utils/constants.dart
// Central constants for WAult. Everything referenced across files lives here.

class WaultConstants {
  // ── Platform Channel ──────────────────────────────────────────────────────
  static const String channelName = 'com.diva.wault/engine';
  static const String methodOpenSession = 'openSession';
  static const String methodIsSessionActive = 'isSessionActive';

  // Intent extra keys (must match Kotlin side exactly)
  static const String extraAccountId = 'accountId';
  static const String extraLabel = 'label';
  static const String extraAccentColor = 'accentColor';
  static const String extraProcessSlot = 'processSlot';

  // ── App Limits ────────────────────────────────────────────────────────────
  static const int maxAccounts = 5;

  // ── Storage Keys ─────────────────────────────────────────────────────────
  static const String prefAccountsKey = 'wault_accounts';

  // ── Accent Color Palette ──────────────────────────────────────────────────
  // 8 colors cycle as accounts are created
  static const List<String> accentPalette = [
    '#25D366', // green
    '#53BDEB', // blue
    '#FF6B9D', // pink
    '#FFB340', // orange
    '#A78BFA', // purple
    '#34D399', // teal
    '#F472B6', // rose
    '#60A5FA', // sky
  ];

  // ── Animation Durations ───────────────────────────────────────────────────
  static const Duration splashLogoDuration = Duration(milliseconds: 600);
  static const Duration splashTextDelay = Duration(milliseconds: 400);
  static const Duration splashTotalDuration = Duration(milliseconds: 2500);
  static const Duration splashExitDuration = Duration(milliseconds: 400);
  static const Duration cardStaggerDelay = Duration(milliseconds: 80);
  static const Duration cardAnimDuration = Duration(milliseconds: 350);
  static const Duration screenTransitionDuration = Duration(milliseconds: 350);
}
