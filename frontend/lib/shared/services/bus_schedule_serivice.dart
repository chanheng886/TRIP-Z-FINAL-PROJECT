import 'dart:convert';
import 'package:frontend/shared/services/auth_service.dart';
import 'package:http/http.dart' as http;

class BusScheduleService {
  final String baseUrl = "http://172.16.104.48:8080/api/v1/bus-schedules";

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> searchBusSchedules({
    required int fromLocationId,
    required int toLocationId,
    required DateTime travelDate,
  }) async {
    try {
      final dateString =
          "${travelDate.year}-${travelDate.month.toString().padLeft(2, '0')}-${travelDate.day.toString().padLeft(2, '0')}";

      final uri = Uri.parse('$baseUrl/search').replace(
        queryParameters: {
          'fromLocationId': fromLocationId.toString(),
          'toLocationId': toLocationId.toString(),
          'travelDate': dateString,
        },
      );

      final response = await http.get(uri, headers: await _headers());
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load bus schedules!");
      }
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSeatMap(int busScheduleId) async {
    try {
      final uri = Uri.parse('$baseUrl/$busScheduleId/seats');
      final response = await http.get(uri, headers: await _headers());
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to load seat map!");
      }
    } catch (e) {
      print('Exception: $e');
      rethrow;
    }
  }
}

