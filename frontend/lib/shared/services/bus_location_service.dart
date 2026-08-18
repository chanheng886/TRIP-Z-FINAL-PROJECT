import 'dart:convert';
import 'package:frontend/shared/services/auth_service.dart';
import 'package:http/http.dart' as http;

class BusLocationService {
  final String baseUrl = "http://172.16.104.48:8080/api/v1/bus-locations";

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getLocations() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: await _headers(),
      );
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load bus locaitons!");
      }
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }
}
