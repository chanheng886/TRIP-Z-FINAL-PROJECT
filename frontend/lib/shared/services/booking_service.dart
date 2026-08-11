import 'dart:convert';
import 'package:http/http.dart' as http;

class BookingService {
  final String baseUrl = "http://172.16.104.14:8080/api/v1/booking";

  Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> bookingJson,
  ) async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
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
}
