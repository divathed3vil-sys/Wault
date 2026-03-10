// android/app/src/main/kotlin/com/diva/wault/MainActivity.kt
// Flutter's main Activity. Registers the platform channel that Flutter uses
// to launch WebView sessions. Channel name and method names MUST match
// WaultConstants in Dart exactly.

package com.diva.wault

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        // Must match WaultConstants.channelName in Dart
        private const val CHANNEL = "com.diva.wault/engine"

        // Must match WaultConstants.methodOpenSession in Dart
        private const val METHOD_OPEN_SESSION = "openSession"
        private const val METHOD_IS_SESSION_ACTIVE = "isSessionActive"

        // Must match WaultConstants.extra* keys in Dart
        private const val EXTRA_ACCOUNT_ID = "accountId"
        private const val EXTRA_LABEL = "label"
        private const val EXTRA_ACCENT_COLOR = "accentColor"
        private const val EXTRA_PROCESS_SLOT = "processSlot"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    METHOD_OPEN_SESSION -> {
                        try {
                            val accountId = call.argument<String>(EXTRA_ACCOUNT_ID) ?: ""
                            val label = call.argument<String>(EXTRA_LABEL) ?: "Account"
                            val accentColor = call.argument<String>(EXTRA_ACCENT_COLOR) ?: "#25D366"
                            val processSlot = call.argument<Int>(EXTRA_PROCESS_SLOT) ?: 0

                            launchWebViewSession(accountId, label, accentColor, processSlot)
                            result.success(null)
                        } catch (e: Exception) {
                            result.error("LAUNCH_ERROR", e.message, null)
                        }
                    }

                    METHOD_IS_SESSION_ACTIVE -> {
                        // V1: always false (sessions are not kept alive)
                        result.success(false)
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun launchWebViewSession(
        accountId: String,
        label: String,
        accentColor: String,
        processSlot: Int
    ) {
        // Map slot to the correct Activity class (each runs in its own process)
        val activityClass = when (processSlot) {
            0 -> WebViewSessionActivity0::class.java
            1 -> WebViewSessionActivity1::class.java
            2 -> WebViewSessionActivity2::class.java
            3 -> WebViewSessionActivity3::class.java
            4 -> WebViewSessionActivity4::class.java
            else -> WebViewSessionActivity0::class.java
        }

        val intent = Intent(this, activityClass).apply {
            putExtra(EXTRA_ACCOUNT_ID, accountId)
            putExtra(EXTRA_LABEL, label)
            putExtra(EXTRA_ACCENT_COLOR, accentColor)
            putExtra(EXTRA_PROCESS_SLOT, processSlot)
        }

        startActivity(intent)
    }
}
