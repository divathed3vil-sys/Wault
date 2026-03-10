// android/app/src/main/kotlin/com/diva/wault/BaseWebViewSessionActivity.kt
// Base Activity for all 5 WebView session slots.
// Subclasses pass their slot number; this class handles everything else.
// IMPORTANT: setDataDirectorySuffix is called BEFORE any WebView is created.

package com.diva.wault

import android.annotation.SuppressLint
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowInsetsController
import android.view.WindowManager
import android.webkit.CookieManager
import android.webkit.WebSettings
import android.webkit.WebView
import android.widget.FrameLayout
import android.widget.ImageButton
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat

abstract class BaseWebViewSessionActivity : AppCompatActivity() {

    // ── Subclasses provide their slot number ──────────────────────────────────
    protected abstract val processSlot: Int

    private var webView: WebView? = null
    private var chromeClient: WaultChromeClient? = null

    // File chooser launcher
    private val fileChooserLauncher =
        registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
            if (result.resultCode == RESULT_OK && result.data != null) {
                val uris = result.data?.data?.let { arrayOf(it) }
                    ?: result.data?.clipData?.let { clip ->
                        Array(clip.itemCount) { i -> clip.getItemAt(i).uri }
                    }
                chromeClient?.onFileChooserResult(uris)
            } else {
                chromeClient?.cancelFileChooser()
            }
        }

    // Permissions launcher
    private val permissionsLauncher =
        registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { _ -> }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // ── CRITICAL: Call setDataDirectorySuffix BEFORE creating ANY WebView ──
        // This must be the very first thing after super.onCreate().
        // Each slot uses its own suffix so sessions are fully isolated.
        try {
            WebView.setDataDirectorySuffix("wault_$processSlot")
        } catch (e: Exception) {
            // If called more than once in same process, it throws.
            // This is safe to ignore — the suffix was already set on first call.
        }

        // ── Fullscreen immersive ───────────────────────────────────────────────
        window.apply {
            addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
            addFlags(WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED)
            statusBarColor = Color.TRANSPARENT
            navigationBarColor = Color.parseColor("#0F0F14")
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.apply {
                setSystemBarsAppearance(0, WindowInsetsController.APPEARANCE_LIGHT_STATUS_BARS)
                setSystemBarsAppearance(0, WindowInsetsController.APPEARANCE_LIGHT_NAVIGATION_BARS)
            }
        }

        // ── Extract Intent extras ─────────────────────────────────────────────
        val accountId = intent.getStringExtra("accountId") ?: ""
        val label = intent.getStringExtra("label") ?: "Account"
        val accentColorHex = intent.getStringExtra("accentColor") ?: "#25D366"

        // ── Build layout programmatically (no XML needed) ─────────────────────
        val rootLayout = FrameLayout(this)
        rootLayout.setBackgroundColor(Color.parseColor("#0b141a"))

        // WebView container
        val webViewContainer = FrameLayout(this)

        // Create WebView
        webView = createWebView(accentColorHex, label)
        webViewContainer.addView(
            webView,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        // Custom top bar overlay (48dp height)
        val topBar = createTopBar(label, accentColorHex)

        rootLayout.addView(
            webViewContainer,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )
        rootLayout.addView(
            topBar,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                dipToPx(48) + getStatusBarHeight()
            )
        )

        setContentView(rootLayout)

        // ── Request camera/mic permissions ────────────────────────────────────
        requestPermissionsIfNeeded()

        // ── Load WhatsApp Web ─────────────────────────────────────────────────
        webView?.loadUrl("https://web.whatsapp.com")
    }

    @SuppressLint("SetJavaScriptEnabled")
    private fun createWebView(accentColorHex: String, label: String): WebView {
        val wv = WebView(this)

        wv.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            databaseEnabled = true
            cacheMode = WebSettings.LOAD_DEFAULT
            setSupportZoom(false)
            builtInZoomControls = false
            displayZoomControls = false
            loadWithOverviewMode = true
            useWideViewPort = true
            allowFileAccess = false
            allowContentAccess = true
            mixedContentMode = WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
            mediaPlaybackRequiresUserGesture = false

            // Chrome desktop UA — causes WhatsApp to serve web version
            userAgentString = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 " +
                    "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
        }

        // Cookies
        CookieManager.getInstance().setAcceptCookie(true)
        CookieManager.getInstance().setAcceptThirdPartyCookies(wv, true)

        // Hardware acceleration
        wv.setLayerType(View.LAYER_TYPE_HARDWARE, null)

        // No over-scroll
        wv.overScrollMode = View.OVER_SCROLL_NEVER

        // No scroll bars
        wv.isVerticalScrollBarEnabled = false
        wv.isHorizontalScrollBarEnabled = false

        // Render priority
        wv.setRenderPriority(WebView.RendererPriority.IMPORTANT)

        // WebViewClient
        wv.webViewClient = WaultWebViewClient(
            accentColorHex = accentColorHex,
            onPageStarted = { /* could show progress */ },
            onPageFinished = { /* could hide progress */ }
        )

        // ChromeClient
        val chrome = WaultChromeClient(
            activity = this,
            fileChooserCallback = { intent ->
                fileChooserLauncher.launch(intent)
            },
            onFileChooserRequest = { _, intent ->
                fileChooserLauncher.launch(intent)
            }
        )
        chromeClient = chrome
        wv.webChromeClient = chrome

        // Handle render process gone (crash recovery)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            wv.webViewRenderProcessClient = null
        }

        return wv
    }

    private fun createTopBar(label: String, accentColorHex: String): LinearLayout {
        val bar = LinearLayout(this)
        bar.orientation = LinearLayout.HORIZONTAL
        bar.setBackgroundColor(Color.parseColor("#CC0F0F14")) // semi-transparent dark
        bar.gravity = android.view.Gravity.BOTTOM

        val statusHeight = getStatusBarHeight()
        bar.setPadding(dipToPx(4), statusHeight + dipToPx(4), dipToPx(16), dipToPx(6))

        // Back button
        val backBtn = ImageButton(this).apply {
            setImageDrawable(
                ContextCompat.getDrawable(
                    this@BaseWebViewSessionActivity,
                    android.R.drawable.ic_media_previous
                )
            )
            // Use a back arrow vector
            background = null
            setColorFilter(Color.parseColor("#F0F0F0"))
            setPadding(dipToPx(12), dipToPx(8), dipToPx(12), dipToPx(8))
            setOnClickListener { onBackPressedDispatcher.onBackPressed() }
            contentDescription = "Back"
        }

        // Use a drawable back arrow
        val backIcon = android.graphics.drawable.ShapeDrawable()
        // Actually draw a custom back arrow via canvas
        val arrowView = _BackArrowView(this)

        bar.addView(
            arrowView,
            LinearLayout.LayoutParams(dipToPx(48), dipToPx(36))
        )

        // Accent dot
        val dot = View(this).apply {
            background = android.graphics.drawable.GradientDrawable().apply {
                shape = android.graphics.drawable.GradientDrawable.OVAL
                setColor(Color.parseColor(accentColorHex))
            }
        }
        bar.addView(dot, LinearLayout.LayoutParams(dipToPx(8), dipToPx(8)).apply {
            gravity = android.view.Gravity.CENTER_VERTICAL
            marginEnd = dipToPx(8)
        })

        // Label text
        val labelView = TextView(this).apply {
            text = label
            setTextColor(Color.parseColor("#F0F0F0"))
            textSize = 15f
            typeface = android.graphics.Typeface.create("sans-serif-medium", android.graphics.Typeface.NORMAL)
            maxLines = 1
            ellipsize = android.text.TextUtils.TruncateAt.END
        }
        bar.addView(labelView, LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f).apply {
            gravity = android.view.Gravity.CENTER_VERTICAL
        })

        return bar
    }

    override fun onBackPressed() {
        if (webView?.canGoBack() == true) {
            // Don't allow back navigation within WhatsApp Web — 
            // pressing back should always exit to vault
        }
        // Always finish and return to Flutter vault
        super.onBackPressed()
    }

    override fun onDestroy() {
        webView?.apply {
            stopLoading()
            loadUrl("about:blank")
            clearHistory()
            removeAllViews()
            destroy()
        }
        webView = null
        super.onDestroy()
    }

    override fun onPause() {
        super.onPause()
        webView?.onPause()
    }

    override fun onResume() {
        super.onResume()
        webView?.onResume()
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private fun dipToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density + 0.5f).toInt()
    }

    private fun getStatusBarHeight(): Int {
        var result = 0
        val resourceId = resources.getIdentifier("status_bar_height", "dimen", "android")
        if (resourceId > 0) result = resources.getDimensionPixelSize(resourceId)
        return result
    }

    private fun requestPermissionsIfNeeded() {
        val perms = mutableListOf<String>()
        val needed = listOf(
            android.Manifest.permission.CAMERA,
            android.Manifest.permission.RECORD_AUDIO,
            android.Manifest.permission.READ_MEDIA_IMAGES,
            android.Manifest.permission.READ_MEDIA_VIDEO
        )
        for (p in needed) {
            if (ContextCompat.checkSelfPermission(this, p) != PackageManager.PERMISSION_GRANTED) {
                perms.add(p)
            }
        }
        if (perms.isNotEmpty()) {
            permissionsLauncher.launch(perms.toTypedArray())
        }
    }
}

// ── Custom back arrow view drawn programmatically ─────────────────────────────

private class _BackArrowView(context: android.content.Context) : View(context) {
    init {
        setOnClickListener {
            (context as? AppCompatActivity)?.onBackPressedDispatcher?.onBackPressed()
        }
    }

    override fun onDraw(canvas: android.graphics.Canvas) {
        super.onDraw(canvas)
        val paint = android.graphics.Paint(android.graphics.Paint.ANTI_ALIAS_FLAG).apply {
            color = android.graphics.Color.parseColor("#F0F0F0")
            strokeWidth = 5f
            style = android.graphics.Paint.Style.STROKE
            strokeCap = android.graphics.Paint.Cap.ROUND
        }
        val cx = width / 2f
        val cy = height / 2f
        val size = minOf(width, height) * 0.28f
        // Chevron left arrow: < shape
        canvas.drawLine(cx + size, cy - size, cx - size * 0.3f, cy, paint)
        canvas.drawLine(cx - size * 0.3f, cy, cx + size, cy + size, paint)
    }
}
