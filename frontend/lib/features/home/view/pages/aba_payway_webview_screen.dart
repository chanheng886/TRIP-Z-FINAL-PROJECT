import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/shared/service/aba_payway_service.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// AbaPaywayWebviewScreen
///
/// Loads the ABA Payway hosted checkout page inside a WebView.
/// - Intercepts the return URL to detect successful payment
/// - Intercepts the cancel URL to detect cancellation
/// - Returns [AbaPaywayResult] via Get.back() so the caller can react
enum AbaPaywayResult { success, cancelled, error }

class AbaPaywayWebviewScreen extends StatefulWidget {
  final String checkoutUrl;
  final double amount;

  const AbaPaywayWebviewScreen({
    super.key,
    required this.checkoutUrl,
    required this.amount,
  });

  @override
  State<AbaPaywayWebviewScreen> createState() => _AbaPaywayWebviewScreenState();
}

class _AbaPaywayWebviewScreenState extends State<AbaPaywayWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    // Use a desktop Chrome User-Agent so ABA's server renders the full hosted
    // checkout page instead of showing a mobile "Open ABA App" redirect.
    const desktopUserAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
        'AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/124.0.0.0 Safari/537.36';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(desktopUserAgent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() => _isLoading = true);
            // Block app-intent schemes that can slip through onPageStarted
            if (_isAppIntentUrl(url)) {
              debugPrint(
                '[AbaWebview] Blocked app-intent in onPageStarted: $url',
              );
              return;
            }
            _handleUrlNavigation(url);
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onWebResourceError: (error) {
            debugPrint('[AbaWebview] Resource error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('[AbaWebview] NavigationRequest: $url');

            // 1. Block ALL app-intent / deep-link schemes that open native apps.
            //    ABA Payway redirects mobile browsers to these when it detects Android.
            //    Without this, Android falls back to opening Google Play Store.
            if (_isAppIntentUrl(url)) {
              debugPrint('[AbaWebview] Blocked app-intent scheme: $url');
              return NavigationDecision.prevent;
            }

            // 2. Intercept success or cancel URLs
            if (_handleUrlNavigation(url)) {
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    final raw = widget.checkoutUrl.trim();
    if (raw.startsWith('<!DOCTYPE') ||
        raw.startsWith('<html') ||
        raw.startsWith('<form')) {
      debugPrint(
        '[AbaWebview] Loading self-submitting HTML form for ABA Payway',
      );
      _controller.loadHtmlString(
        raw,
        baseUrl: 'https://checkout-sandbox.payway.com.kh',
      );
    } else {
      debugPrint('[AbaWebview] Loading URL: $raw');
      _controller.loadRequest(Uri.parse(raw));
    }
  }

  /// Returns true for any URL scheme that would open a native app or the Play Store.
  /// ABA Payway uses these schemes to deep-link into ABA Mobile when it detects
  /// a mobile browser User-Agent.
  bool _isAppIntentUrl(String url) {
    const blockedSchemes = [
      'intent://',
      'market://',
      'abamobile://',
      'abamobilebank://',
      'abapay://',
      'com.aba.mobile://',
      'android-app://',
    ];
    final lower = url.toLowerCase();
    return blockedSchemes.any((scheme) => lower.startsWith(scheme));
  }

  /// Intercepts URLs to detect payment success or cancellation.
  bool _handleUrlNavigation(String url) {
    if (_hasNavigated) return true;

    final successUrl = AbaPaywayService.successReturnUrl;
    final cancelUrl = AbaPaywayService.cancelReturnUrl;

    if (url.startsWith(successUrl)) {
      _hasNavigated = true;
      debugPrint('[AbaWebview] Payment SUCCESS detected at: $url');
      Get.back(result: AbaPaywayResult.success);
      return true;
    } else if (url.startsWith(cancelUrl)) {
      _hasNavigated = true;
      debugPrint('[AbaWebview] Payment CANCELLED detected at: $url');
      Get.back(result: AbaPaywayResult.cancelled);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF16181F) : Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (!_hasNavigated) {
              _hasNavigated = true;
              Get.back(result: AbaPaywayResult.cancelled);
            }
          },
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ABA Brand Color Dot
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF005A9C),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'ABA Payway',
              style: AppFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          // Secure badge
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 4),
                Text(
                  'Secure',
                  style: AppFonts.dmSans(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: isDark ? const Color(0xFF2C3242) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ABA Payway WebView
          WebViewWidget(controller: _controller),

          // Loading overlay
          if (_isLoading)
            Container(
              color: isDark
                  ? const Color(0xFF16181F).withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.9),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ABA Logo Placeholder
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF005A9C),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF005A9C,
                            ).withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: FaIcon(
                          FontAwesomeIcons.buildingColumns,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Loading ABA Payway...',
                      style: AppFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'USD ${widget.amount.toStringAsFixed(2)}',
                      style: AppFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Color(0xFF005A9C)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
