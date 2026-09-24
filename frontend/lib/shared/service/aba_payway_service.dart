import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:frontend/shared/service/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// AbaPaywayService
///
/// Communicates with the Spring Boot backend to generate a signed
/// ABA Payway checkout HTML form that the Flutter WebView will load.
class AbaPaywayService {
  static String get _baseUrl => BaseUrl.rootUrl;

  /// Reads the JWT token from SharedPreferences (same key used by AuthService).
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Requests a signed ABA Payway checkout HTML form from the backend.
  ///
  /// [bookingId] - the booking ID (use 0 before booking is confirmed)
  /// [amount]    - total amount in USD
  ///
  /// Throws [Exception] on HTTP error or network timeout.
  static Future<AbaCheckoutResult> createCheckoutUrl({
    required int bookingId,
    required double amount,
  }) async {
    debugPrint('[AbaPayway] Requesting checkout: bookingId=$bookingId, amount=$amount');

    final token = await _getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final uri = Uri.parse('$_baseUrl/payment/aba/checkout');
    debugPrint('[AbaPayway] POST $uri');
    final response = await http
        .post(
          uri,
          headers: headers,
          body: json.encode({
            'bookingId': bookingId,
            'amount': amount,
            'currency': 'USD',
          }),
        )
        .timeout(const Duration(seconds: 20));

    debugPrint('[AbaPayway] HTTP ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200) {
      final body = json.decode(response.body) as Map<String, dynamic>;
      final checkoutUrl = body['checkoutUrl'] as String? ?? '';
      final transactionId = body['transactionId'] as String? ?? '';
      final qrString = body['qrString'] as String?;
      final qrImage = body['qrImage'] as String?;
      final abapayDeeplink = body['abapayDeeplink'] as String?;

      debugPrint('[AbaPayway] Checkout received. transactionId=$transactionId, hasQr=${qrString != null}');
      return AbaCheckoutResult(
        checkoutUrl: checkoutUrl,
        transactionId: transactionId,
        qrString: qrString,
        qrImage: qrImage,
        abapayDeeplink: abapayDeeplink,
      );
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized (401). Token may be expired — please log in again.');
    } else {
      throw Exception('Backend error ${response.statusCode}: ${response.body}');
    }
  }

  /// Polls the transaction status from the backend (which queries ABA /check-transaction-2).
  static Future<AbaTransactionStatus> checkTransaction(String tranId) async {
    try {
      final uri = Uri.parse('$_baseUrl/payment/aba/check-transaction?tran_id=$tranId');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = json.decode(response.body) as Map<String, dynamic>;
        return AbaTransactionStatus(
          tranId: body['tranId'] ?? tranId,
          isApproved: body['isApproved'] == true,
          paymentStatus: body['paymentStatus'] ?? 'UNKNOWN',
          paymentStatusCode: body['paymentStatusCode'] ?? -1,
          message: body['message'] ?? '',
        );
      }
      return AbaTransactionStatus(
        tranId: tranId,
        isApproved: false,
        paymentStatus: 'ERROR',
        paymentStatusCode: -1,
        message: 'HTTP ${response.statusCode}',
      );
    } catch (e) {
      return AbaTransactionStatus(
        tranId: tranId,
        isApproved: false,
        paymentStatus: 'NETWORK_ERROR',
        paymentStatusCode: -1,
        message: e.toString(),
      );
    }
  }

  /// Triggers a test approval on the backend for sandbox testing.
  static Future<bool> simulatePaymentApproval(String tranId) async {
    try {
      final uri = Uri.parse('$_baseUrl/payment/aba/simulate-approval?tran_id=$tranId');
      final response = await http.post(uri).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('[AbaPayway] simulatePaymentApproval failed: $e');
      return false;
    }
  }

  /// Return URL that ABA Payway redirects the WebView to after successful payment.
  /// The WebView intercepts this URL to close and trigger booking confirmation.
  static String get successReturnUrl => '$_baseUrl/payment/aba/return';

  /// Cancel URL that ABA Payway redirects the WebView to when user cancels.
  static String get cancelReturnUrl => '$_baseUrl/payment/aba/cancel';
}

/// Result returned from [AbaPaywayService.createCheckoutUrl].
class AbaCheckoutResult {
  final String checkoutUrl;
  final String transactionId;
  final String? qrString;
  final String? qrImage;
  final String? abapayDeeplink;

  const AbaCheckoutResult({
    required this.checkoutUrl,
    required this.transactionId,
    this.qrString,
    this.qrImage,
    this.abapayDeeplink,
  });
}

/// Status returned from [AbaPaywayService.checkTransaction].
class AbaTransactionStatus {
  final String tranId;
  final bool isApproved;
  final String paymentStatus;
  final int paymentStatusCode;
  final String message;

  const AbaTransactionStatus({
    required this.tranId,
    required this.isApproved,
    required this.paymentStatus,
    required this.paymentStatusCode,
    required this.message,
  });
}


