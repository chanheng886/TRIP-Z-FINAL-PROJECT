package com.example.frontend

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.tripz.payment/launcher"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "launchAcleda" -> {
                    val url = call.argument<String>("url")
                    val qr = call.argument<String>("qr")
                    val openStore = call.argument<Boolean>("openStore") ?: false
                    val launched = launchAcledaApp(url, qr, openStore)
                    result.success(launched)
                }
                "launchAba" -> {
                    val url = call.argument<String>("url")
                    val openStore = call.argument<Boolean>("openStore") ?: false
                    val launched = launchAbaApp(url, openStore)
                    result.success(launched)
                }
                "launchAppByPackage" -> {
                    val packageName = call.argument<String>("package")
                    val launched = if (packageName != null) launchByPackage(packageName) else false
                    result.success(launched)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun launchAcledaApp(url: String? = null, qr: String? = null, openStore: Boolean = false): Boolean {
        val packages = listOf(
            "com.domain.acledabankqr",
            "com.acledabank.mobile",
            "com.acleda.mobile"
        )

        // 1. If deep link URL is provided, try launching targeting ACLEDA directly
        if (!url.isNullOrEmpty()) {
            val uri = Uri.parse(url)
            for (pkg in packages) {
                try {
                    val intent = Intent(Intent.ACTION_VIEW, uri)
                    intent.setPackage(pkg)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        return true
                    }
                } catch (_: Exception) {}
            }

            // Try general intent with the deep link URL (Bakong / ACLEDA App Link)
            try {
                val generalIntent = Intent(Intent.ACTION_VIEW, uri)
                generalIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (generalIntent.resolveActivity(packageManager) != null) {
                    startActivity(generalIntent)
                    return true
                }
            } catch (_: Exception) {}
        }

        // 2. Try direct URL schemes with QR embedded
        if (!qr.isNullOrEmpty()) {
            val encoded = Uri.encode(qr)
            val directSchemes = listOf(
                "acledamobile://payment?qr=$encoded",
                "acledamobile://qr?data=$encoded",
                "acledabankqr://qr?data=$encoded",
                "bakong://payment?qr=$encoded",
                "bakong://qr?data=$encoded"
            )
            for (scheme in directSchemes) {
                try {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(scheme))
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        return true
                    }
                } catch (_: Exception) {}
            }
        }

        // 3. Fallback: Launch the ACLEDA app main launcher activity
        for (pkg in packages) {
            val intent = packageManager.getLaunchIntentForPackage(pkg)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                return true
            }
        }

        // 4. Fallback: URL schemes (base)
        val baseSchemes = listOf("acledamobile://", "acleda://", "acledabankqr://", "bakong://")
        for (scheme in baseSchemes) {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(scheme))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (intent.resolveActivity(packageManager) != null) {
                    startActivity(intent)
                    return true
                }
            } catch (_: Exception) {}
        }

        // 5. Fallback: Open Google Play Store ONLY if explicitly requested
        if (openStore) {
            return try {
                val marketIntent = Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=com.domain.acledabankqr"))
                marketIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(marketIntent)
                true
            } catch (_: Exception) {
                try {
                    val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=com.domain.acledabankqr"))
                    webIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(webIntent)
                    true
                } catch (_: Exception) {
                    false
                }
            }
        }
        return false
    }

    private fun launchAbaApp(url: String? = null, openStore: Boolean = false): Boolean {
        val packages = listOf(
            "com.app.aba",
            "com.ababank.aba.mobile",
            "com.aba.mobile",
            "com.ababank.mobile"
        )

        // 1. If deep link URL is provided, try launching targeting ABA directly
        if (!url.isNullOrEmpty()) {
            val uri = Uri.parse(url)
            for (pkg in packages) {
                try {
                    val intent = Intent(Intent.ACTION_VIEW, uri)
                    intent.setPackage(pkg)
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    if (intent.resolveActivity(packageManager) != null) {
                        startActivity(intent)
                        return true
                    }
                } catch (_: Exception) {}
            }

            // Try general intent with the deep link URL (e.g. abamobilebank://, abapay://)
            try {
                val generalIntent = Intent(Intent.ACTION_VIEW, uri)
                generalIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (generalIntent.resolveActivity(packageManager) != null) {
                    startActivity(generalIntent)
                    return true
                }
            } catch (_: Exception) {}
        }

        // 2. Try launching ABA app main launcher activity
        for (pkg in packages) {
            val intent = packageManager.getLaunchIntentForPackage(pkg)
            if (intent != null) {
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(intent)
                return true
            }
        }

        // 3. Try known ABA URL schemes
        val baseSchemes = listOf("abamobilebank://", "abapay://", "aba://")
        for (scheme in baseSchemes) {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(scheme))
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                if (intent.resolveActivity(packageManager) != null) {
                    startActivity(intent)
                    return true
                }
            } catch (_: Exception) {}
        }

        // 4. Fallback: Google Play Store ONLY if explicitly requested
        if (openStore) {
            return try {
                val marketIntent = Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=com.app.aba"))
                marketIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(marketIntent)
                true
            } catch (_: Exception) {
                try {
                    val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=com.app.aba"))
                    webIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(webIntent)
                    true
                } catch (_: Exception) {
                    false
                }
            }
        }
        return false
    }

    private fun launchByPackage(packageName: String): Boolean {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        return if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            true
        } else {
            false
        }
    }
}
