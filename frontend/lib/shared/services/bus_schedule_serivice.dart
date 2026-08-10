import 'dart:convert';
import 'package:http/http.dart' as http;

class BusScheduleService {
  final String baseUrl = "http://172.16.104.28:8080/api/v1/bus-schedules";

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

      final response = await http.get(uri);
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
}
