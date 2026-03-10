// android/app/src/main/kotlin/com/diva/wault/WaultWebViewClient.kt
// Custom WebViewClient for WAult. Handles URL filtering (WhatsApp domains only),
// CSS injection, JS behavior injection after page load.

package com.diva.wault

import android.content.Intent
import android.graphics.Bitmap
import android.net.Uri
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient

class WaultWebViewClient(
    private val accentColorHex: String,
    private val onPageStarted: () -> Unit = {},
    private val onPageFinished: () -> Unit = {}
) : WebViewClient() {

    // WhatsApp-related domains that are allowed to load inside the WebView
    private val allowedDomains = setOf(
        "web.whatsapp.com",
        "whatsapp.com",
        "www.whatsapp.com",
        "static.whatsapp.net",
        "mmg.whatsapp.net",
        "pps.whatsapp.net",
        "media.whatsapp.net",
        "crashlogs.whatsapp.net"
    )

    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
        val host = request.url.host ?: return true
        val isAllowed = allowedDomains.any { host == it || host.endsWith(".$it") }
        return if (isAllowed) {
            false // let the WebView handle it
        } else {
            // Open in external browser
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(request.url.toString()))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                view.context.startActivity(intent)
            } catch (_: Exception) { /* ignore */ }
            true
        }
    }

    override fun onPageStarted(view: WebView, url: String, favicon: Bitmap?) {
        super.onPageStarted(view, url, favicon)
        onPageStarted()
    }

    override fun onPageFinished(view: WebView, url: String) {
        super.onPageFinished(view, url)
        injectCss(view)
        injectBehaviorJs(view)
        onPageFinished()
    }

    override fun onReceivedError(
        view: WebView,
        request: WebResourceRequest,
        error: WebResourceError
    ) {
        // Only care about main frame errors
        if (request.isForMainFrame) {
            super.onReceivedError(view, request, error)
        }
    }

    // ── CSS Injection ─────────────────────────────────────────────────────────

    private fun injectCss(view: WebView) {
        val accentColor = accentColorHex.replace("#", "")
        val css = """
            /* WAult CSS Injection — wault-style */
            body, html {
                background-color: #0b141a !important;
                overflow: hidden;
            }
            
            /* Hide WhatsApp Web top header */
            header[data-testid="chatlist-header"],
            [data-testid="chatlist-header"],
            ._ao3e {
                display: none !important;
            }
            
            /* Hide download/get app banners */
            [data-testid="get-desktop-app-banner"],
            ._ak_b, ._ak_c, ._ak_d {
                display: none !important;
            }
            
            /* Custom thin scrollbar */
            ::-webkit-scrollbar {
                width: 3px !important;
                height: 3px !important;
            }
            ::-webkit-scrollbar-track {
                background: transparent !important;
            }
            ::-webkit-scrollbar-thumb {
                background: rgba(255,255,255,0.2) !important;
                border-radius: 2px !important;
            }
            
            /* Disable text selection except in compose areas */
            * {
                -webkit-user-select: none !important;
                user-select: none !important;
                -webkit-tap-highlight-color: transparent !important;
            }
            [contenteditable="true"],
            [contenteditable="true"] *,
            textarea, input[type="text"] {
                -webkit-user-select: text !important;
                user-select: text !important;
            }
            
            /* No overscroll bounce */
            body {
                overscroll-behavior: none !important;
            }
            
            /* Top padding for custom native bar (48dp at ~2.75dpr ≈ 132px, use safe value) */
            #app, #main, [data-testid="default-user"],
            ._ajvx { 
                padding-top: 48px !important;
                box-sizing: border-box !important;
            }
            
            /* Accent gradient line at top of page */
            body::before {
                content: '' !important;
                position: fixed !important;
                top: 0 !important;
                left: 0 !important;
                right: 0 !important;
                height: 2px !important;
                background: linear-gradient(90deg, #${accentColor} 0%, rgba(${hexToRgb(accentColorHex)}, 0.4) 100%) !important;
                z-index: 99999 !important;
                pointer-events: none !important;
            }
        """.trimIndent()

        val js = """
            (function() {
                try {
                    var existing = document.getElementById('wault-css-injection');
                    if (existing) existing.remove();
                    var style = document.createElement('style');
                    style.id = 'wault-css-injection';
                    style.textContent = `${css.replace("`", "\\`")}`;
                    document.head.appendChild(style);
                } catch(e) {}
            })();
        """.trimIndent()

        view.evaluateJavascript(js, null)
    }

    // ── JS Behavior Injection ─────────────────────────────────────────────────

    private fun injectBehaviorJs(view: WebView) {
        val js = """
            (function() {
                try {
                    // Disable pinch-to-zoom via touch events
                    if (!window.__waultZoomDisabled) {
                        window.__waultZoomDisabled = true;
                        document.addEventListener('touchstart', function(e) {
                            if (e.touches.length > 1) {
                                e.preventDefault();
                            }
                        }, { passive: false, capture: true });
                        
                        // Disable double-tap zoom
                        var lastTouchEnd = 0;
                        document.addEventListener('touchend', function(e) {
                            var now = Date.now();
                            if (now - lastTouchEnd < 300) {
                                e.preventDefault();
                            }
                            lastTouchEnd = now;
                        }, false);
                    }
                    
                    // Disable pull-to-refresh (prevent touchmove at scroll top)
                    if (!window.__waultPTRDisabled) {
                        window.__waultPTRDisabled = true;
                        document.addEventListener('touchmove', function(e) {
                            if (document.documentElement.scrollTop === 0 && 
                                e.touches[0].clientY > e.touches[0].screenY) {
                                e.preventDefault();
                            }
                        }, { passive: false });
                    }
                    
                    // Disable context menu
                    if (!window.__waultContextDisabled) {
                        window.__waultContextDisabled = true;
                        document.addEventListener('contextmenu', function(e) {
                            e.preventDefault();
                        }, true);
                    }
                    
                    // Disable drag
                    if (!window.__waultDragDisabled) {
                        window.__waultDragDisabled = true;
                        document.addEventListener('dragstart', function(e) {
                            e.preventDefault();
                        }, true);
                    }
                    
                } catch(e) {}
            })();
        """.trimIndent()

        view.evaluateJavascript(js, null)
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private fun hexToRgb(hex: String): String {
        val clean = hex.replace("#", "")
        val r = clean.substring(0, 2).toInt(16)
        val g = clean.substring(2, 4).toInt(16)
        val b = clean.substring(4, 6).toInt(16)
        return "$r,$g,$b"
    }
}
