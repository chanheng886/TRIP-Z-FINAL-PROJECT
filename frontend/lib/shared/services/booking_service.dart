import 'dart:convert';
import 'package:frontend/shared/services/auth_service.dart';
import 'package:frontend/shared/services/base_url.dart';
import 'package:http/http.dart' as http;

class BookingService {
  final String baseUrl = BaseUrl.booking;

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
      } else {
        throw Exception("Failed to create booking!");
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
