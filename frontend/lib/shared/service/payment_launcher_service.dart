import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:khqr_sdk/khqr_sdk.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentLauncherService {
  static const MethodChannel _nativeChannel = MethodChannel('com.tripz.payment/launcher');

  // ─── Bakong Account & Merchant Credentials ──────────────────────────────
  static String get bakongAccountId =>
      dotenv.env['BAKONG_ACCOUNT_ID']?.trim().isNotEmpty == true
          ? dotenv.env['BAKONG_ACCOUNT_ID']!.trim()
          : 'chanheng_chun1@bkrt';

  static String get bakongToken =>
      dotenv.env['BAKONG_TOKEN']?.trim() ?? '';

  static String get merchantName =>
      dotenv.env['BAKONG_MERCHANT_NAME']?.trim().isNotEmpty == true
          ? dotenv.env['BAKONG_MERCHANT_NAME']!.trim()
          : 'TRIP-Z';

  static const String _acquiringBank = 'Bakong';
  static const String _merchantCity = 'Phnom Penh';

  /// Returns true if currently using a Bakong retail testnet account
  static bool get isTestnetAccount => bakongAccountId.endsWith('@bkrt');

  // ABA Mobile identifiers
  static const String abaAndroidPackage = 'com.app.aba';
  static const String abaiOSAppId       = 'id859663424';
  static const List<String> abaPackages = [
    'com.app.aba',
    'com.ababank.aba.mobile',
    'com.aba.mobile',
    'com.ababank.mobile',
  ];

  // ─── ACLEDA / Bakong via KHQR Deep Link (amount pre-filled) ──────────────
  /// Opens ACLEDA Super App (or Bakong) directly on the payment/QR confirmation
  /// screen with the amount pre-filled using the official NBC Bakong Deep Link API.
  static Future<bool> launchAcledaSuperApp({
    double? amount,
    String? bookingCode,
  }) async {
    debugPrint('🚀 [PaymentLauncher] Launching ACLEDA via NBC Deep Link...');

    final payAmount = amount ?? 0.0;

    // ── Step 1: Generate real KHQR string ──────────────────────────────────
    final khqrString = generateKhqrString(amount: payAmount, bookingCode: bookingCode);
    debugPrint('✅ [PaymentLauncher] KHQR String: $khqrString');

    String? shortLink;
    String? fullLink;

    // ── Step 2: Request real deep link from NBC Bakong Open API ─────────────
    try {
      debugPrint('🌐 [PaymentLauncher] Requesting deep link from NBC Bakong API...');
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (bakongToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $bakongToken';
      }
      final response = await http
          .post(
            Uri.parse('https://api-bakong.nbc.gov.kh/v1/generate_deeplink_by_qr'),
            headers: headers,
            body: json.encode({'qr': khqrString}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        if (body['responseCode'] == 0 && body['data'] != null) {
          final data = body['data'] as Map<String, dynamic>;
          shortLink = data['shortLink'] as String?;
          fullLink = data['fullLink'] as String?;
          debugPrint('✅ [PaymentLauncher] NBC shortLink: $shortLink');
          debugPrint('✅ [PaymentLauncher] NBC fullLink: $fullLink');
        }
      }
    } catch (e) {
      debugPrint('⚠️ [PaymentLauncher] NBC API call error: $e');
    }

    // ── Step 3: Priority 1 — Native Intent with Deep Link / App Link ────────
    // Targets ACLEDA app directly so it handles the payment URL
    final targetUrl = shortLink ?? fullLink;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final nativeOpened = await _nativeChannel.invokeMethod<bool>('launchAcleda', {
          'url': targetUrl,
          'qr': khqrString,
        });
        if (nativeOpened == true) {
          debugPrint('✅ [PaymentLauncher] Opened ACLEDA via Native Intent with URL');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [PaymentLauncher] Native channel invocation error: $e');
      }
    }

    // ── Step 4: Priority 2 — Flutter launchUrl for NBC shortLink ────────────
    if (shortLink != null && shortLink.isNotEmpty) {
      try {
        final launched = await launchUrl(
          Uri.parse(shortLink),
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          debugPrint('✅ [PaymentLauncher] Opened via NBC shortLink: $shortLink');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [PaymentLauncher] Failed to launch shortLink: $e');
      }
    }

    if (fullLink != null && fullLink.isNotEmpty) {
      try {
        final launched = await launchUrl(
          Uri.parse(fullLink),
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          debugPrint('✅ [PaymentLauncher] Opened via NBC fullLink');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [PaymentLauncher] Failed to launch fullLink: $e');
      }
    }

    // ── Step 5: Priority 3 — Direct schemes with KHQR embedded ──────────────
    final encodedQr = Uri.encodeComponent(khqrString);
    final directSchemes = [
      'acledamobile://payment?qr=$encodedQr',
      'acledamobile://qr?data=$encodedQr',
      'acledabankqr://qr?data=$encodedQr',
      'bakong://payment?qr=$encodedQr',
      'bakong://qr?data=$encodedQr',
    ];

    for (final scheme in directSchemes) {
      try {
        final uri = Uri.parse(scheme);
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
          if (launched) {
            debugPrint('✅ [PaymentLauncher] Opened via direct scheme: $scheme');
            return true;
          }
        }
      } catch (e) {
        debugPrint('⚠️ [PaymentLauncher] Scheme $scheme error: $e');
      }
    }

    // ── Step 6: Priority 4 — Fallback to opening ACLEDA Home screen ────────
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final result = await _nativeChannel.invokeMethod<bool>('launchAcleda');
        if (result == true) {
          debugPrint('✅ [PaymentLauncher] Opened ACLEDA home screen');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [PaymentLauncher] Native fallback failed: $e');
      }
    }

    // ── Step 7: Final fallback — Play Store / App Store ────────────────────
    final storeUrl = (!kIsWeb && Platform.isIOS)
        ? 'https://apps.apple.com/kh/app/acleda-mobile/id1196285236'
        : 'https://play.google.com/store/apps/details?id=com.domain.acledabankqr';
    try {
      return await launchUrl(Uri.parse(storeUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('❌ [PaymentLauncher] All fallbacks exhausted: $e');
      return false;
    }
  }

  /// Generates the KHQR string for display as QR image in the payment screen.
  static String generateKhqrString({
    required double amount,
    String? bookingCode,
  }) {
    final expire = DateTime.now().millisecondsSinceEpoch + 3600000; // 1 hour

    // 1. Try IndividualInfo (for retail Bakong accounts such as @bkrt)
    try {
      final info = IndividualInfo(
        bakongAccountId: bakongAccountId,
        merchantName: merchantName,
        currency: KhqrCurrency.usd,
        amount: amount > 0 ? amount : null,
        billNumber: bookingCode ?? 'TRIPZ001',
        storeLabel: 'TRIP-Z Bus',
        terminalLabel: 'App',
        expirationTimestamp: expire,
      );
      final res = KhqrSdk.generateIndividual(info);
      final qr = res.data?.qr;
      if (res.status.code == 0 && qr != null && qr.isNotEmpty) {
        return qr;
      }
    } catch (e) {
      debugPrint('⚠️ [PaymentLauncher] Individual KHQR error: $e');
    }

    // 2. Fallback to MerchantInfo
    try {
      final info = MerchantInfo(
        bakongAccountId: bakongAccountId,
        acquiringBank: _acquiringBank,
        merchantId: bookingCode ?? 'TRIPZ001',
        merchantName: merchantName,
        merchantCity: _merchantCity,
        currency: KhqrCurrency.usd,
        amount: amount > 0 ? amount : null,
        expirationTimestamp: expire,
      );
      final res = KhqrSdk.generateMerchant(info);
      final qr = res.data?.qr;
      if (res.status.code == 0 && qr != null && qr.isNotEmpty) {
        return qr;
      }
    } catch (e) {
      debugPrint('⚠️ [PaymentLauncher] Merchant KHQR error: $e');
    }

    return _fallbackQr(amount, bookingCode);
  }

  static String _fallbackQr(double amount, String? bookingCode) {
    return 'TRIPZ|${bookingCode ?? "UNKNOWN"}|USD|${amount.toStringAsFixed(2)}';
  }

  /// Launches ABA Mobile App with optional PayWay deep link.
  /// If [openStoreIfNotFound] is false, does NOT redirect to Play Store if app is missing.
  static Future<bool> launchAbaMobileApp({String? deeplink, bool openStoreIfNotFound = false}) async {
    debugPrint('🚀 [PaymentLauncher] Launching ABA Mobile App...');

    // Priority 1: Native channel with deeplink & openStore flag
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final result = await _nativeChannel.invokeMethod<bool>('launchAba', {
          'url': deeplink,
          'openStore': openStoreIfNotFound,
        });
        if (result == true) {
          debugPrint('✅ [PaymentLauncher] Launched ABA Mobile via Native Intent');
          return true;
        }
      } catch (e) {
        debugPrint('⚠️ [PaymentLauncher] Native launchAba error: $e');
      }
    }

    // Priority 2: If a specific ABA Payway deeplink was provided, try it via url_launcher
    if (deeplink != null && deeplink.isNotEmpty) {
      try {
        final uri = Uri.parse(deeplink);
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
          if (launched) return true;
        }
      } catch (e) {
        debugPrint('⚠️ [PaymentLauncher] Deeplink launch error: $e');
      }
    }

    // Priority 3: Try launching by known package names
    if (!kIsWeb && Platform.isAndroid) {
      for (final pkg in abaPackages) {
        try {
          final launched = await _nativeChannel.invokeMethod<bool>('launchAppByPackage', {
            'package': pkg,
          });
          if (launched == true) return true;
        } catch (_) {}
      }
    }

    // Priority 4: Known schemes
    final schemes = ['abamobilebank://', 'abapay://', 'aba://', 'bakong://'];
    for (final scheme in schemes) {
      try {
        final uri = Uri.parse(scheme);
        if (await canLaunchUrl(uri)) {
          final launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
          if (launched) return true;
        }
      } catch (_) {}
    }

    // Priority 5: Fallback to store only if explicitly requested
    if (openStoreIfNotFound) {
      final fallbackUrl = (!kIsWeb && Platform.isIOS)
          ? 'https://apps.apple.com/kh/app/aba-mobile-bank/$abaiOSAppId'
          : 'https://play.google.com/store/apps/details?id=$abaAndroidPackage';

      try {
        return await launchUrl(Uri.parse(fallbackUrl), mode: LaunchMode.externalApplication);
      } catch (_) {
        return false;
      }
    }

    debugPrint('ℹ️ [PaymentLauncher] ABA Mobile app not installed on device.');
    return false;
  }

  /// Launches PayPal
  static Future<bool> launchPayPal() async {
    try {
      return await launchUrl(Uri.parse('https://www.paypal.com'), mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }

  /// Generic dispatcher by payment method name
  static Future<bool> launchPaymentMethod(
    String paymentMethod, {
    double? amount,
    String? bookingCode,
  }) async {
    final lower = paymentMethod.toLowerCase();
    if (lower.contains('acleda')) {
      return await launchAcledaSuperApp(amount: amount, bookingCode: bookingCode);
    } else if (lower.contains('aba')) {
      return await launchAbaMobileApp();
    } else if (lower.contains('paypal')) {
      return await launchPayPal();
    }
    return true;
  }
}
