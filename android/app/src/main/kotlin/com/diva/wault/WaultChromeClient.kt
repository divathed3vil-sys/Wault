// android/app/src/main/kotlin/com/diva/wault/WaultChromeClient.kt
// Handles file picker (send images/docs), grants camera/mic permissions,
// suppresses JS dialogs. Required for full WhatsApp Web functionality.

package com.diva.wault

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.webkit.ConsoleMessage
import android.webkit.GeolocationPermissions
import android.webkit.JsResult
import android.webkit.PermissionRequest
import android.webkit.ValueCallback
import android.webkit.WebChromeClient
import android.webkit.WebView
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts

class WaultChromeClient(
    private val activity: Activity,
    private val fileChooserCallback: (Intent) -> Unit,
    private val onFileChooserRequest: (ValueCallback<Array<Uri>>, Intent) -> Unit
) : WebChromeClient() {

    private var filePathCallback: ValueCallback<Array<Uri>>? = null

    override fun onShowFileChooser(
        webView: WebView,
        filePathCallback: ValueCallback<Array<Uri>>,
        fileChooserParams: FileChooserParams
    ): Boolean {
        this.filePathCallback = filePathCallback
        val intent = fileChooserParams.createIntent()
        onFileChooserRequest(filePathCallback, intent)
        return true
    }

    fun onFileChooserResult(uris: Array<Uri>?) {
        filePathCallback?.onReceiveValue(uris ?: emptyArray())
        filePathCallback = null
    }

    fun cancelFileChooser() {
        filePathCallback?.onReceiveValue(null)
        filePathCallback = null
    }

    override fun onPermissionRequest(request: PermissionRequest) {
        // Grant camera and microphone for WhatsApp calls
        request.grant(request.resources)
    }

    override fun onGeolocationPermissionsShowPrompt(
        origin: String,
        callback: GeolocationPermissions.Callback
    ) {
        callback.invoke(origin, false, false)
    }

    override fun onJsAlert(
        view: WebView,
        url: String,
        message: String,
        result: JsResult
    ): Boolean {
        result.confirm()
        return true
    }

    override fun onJsConfirm(
        view: WebView,
        url: String,
        message: String,
        result: JsResult
    ): Boolean {
        result.confirm()
        return true
    }

    override fun onConsoleMessage(consoleMessage: ConsoleMessage): Boolean {
        // Suppress console logs in production (quiet WebView)
        return true
    }
}
