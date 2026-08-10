import 'dart:convert';
import 'package:http/http.dart' as http;

class BusLocationService {
  final String baseUrl = "http://192.168.1.14:8080/api/v1/bus-locations";

  Future<List<dynamic>> getLocations() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
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
