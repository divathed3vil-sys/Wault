// lib/services/engine_service.dart
// Manages the platform channel that communicates with Kotlin's WebView engine.
// The channel name and method names MUST match MainActivity.kt exactly.

import 'package:flutter/services.dart';
import '../models/account.dart';
import '../utils/constants.dart';

class EngineService {
  static const MethodChannel _channel =
      MethodChannel(WaultConstants.channelName);

  /// Launches the native WebView Activity for [account].
  /// The Kotlin side creates an isolated WebView with setDataDirectorySuffix.
  static Future<void> openSession(Account account) async {
    await _channel.invokeMethod(WaultConstants.methodOpenSession, {
      WaultConstants.extraAccountId: account.id,
      WaultConstants.extraLabel: account.label,
      WaultConstants.extraAccentColor: account.accentColorHex,
      WaultConstants.extraProcessSlot: account.processSlot,
    });
  }
}
