import 'dart:convert';
import 'package:frontend/shared/service/auth_service.dart';
import 'package:frontend/shared/service/base_url.dart';
import 'package:http/http.dart' as http;

class BookingService {
  String get baseUrl => BaseUrl.booking;

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> bookingJson,
  ) async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.post(
        uri,
        headers: await _headers(),
        body: json.encode(bookingJson),
      );
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw Exception("Session expired. Please log in again to complete your booking.");
      } else {
        String msg = "Failed to create booking!";
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            msg = decoded['message'].toString();
          }
        } catch (_) {}
        throw Exception(msg);
      }
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getBookingsByUserId(int userId) async {
    try {
      final uri = Uri.parse('$baseUrl/user/$userId');
      final response = await http.get(uri, headers: await _headers());
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load bookings!");
      }
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }
}
