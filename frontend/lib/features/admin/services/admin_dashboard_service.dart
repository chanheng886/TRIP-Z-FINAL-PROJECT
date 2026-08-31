import 'dart:convert';
import 'package:frontend/shared/services/auth_service.dart';
import 'package:frontend/shared/services/base_url.dart';
import 'package:http/http.dart' as http;

class AdminDashboardService {
  final String baseUrl = BaseUrl.baseUrl;

  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getLocations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bus-locations'),
      headers: await _headers(),
    );
    return _decodeList(response, fallback: "Failed to load locations!");
  }

  Future<List<dynamic>> getCompanies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bus-company'),
      headers: await _headers(),
    );
    return _decodeList(response, fallback: "Failed to load companies!");
  }

  Future<List<dynamic>> getBuses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/buses'),
      headers: await _headers(),
    );
    return _decodeList(response, fallback: "Failed to load buses!");
  }

  Future<List<dynamic>> getRoutes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bus-route'),
      headers: await _headers(),
    );
    return _decodeList(response, fallback: "Failed to load routes!");
  }

  Future<List<dynamic>> getBusTypes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bus-type'),
      headers: await _headers(),
    );
    return _decodeList(response, fallback: "Failed to load bus types!");
  }

  Future<List<dynamic>> getSchedules() async {
    final response = await http.get(
      Uri.parse('$baseUrl/bus-schedules'),
      headers: await _headers(),
    );
    return _decodeList(response, fallback: "Failed to load schedules!");
  }

  Future<List<dynamic>> getBookings() async {
    final response = await http.get(
      Uri.parse('$baseUrl/booking'),
      headers: await _headers(),
    );
    return _decodeList(response, fallback: "Failed to load bookings!");
  }

  Future<List<dynamic>> getBookingsByDate(String date) async {
    final response = await http.get(
      Uri.parse('$baseUrl/booking/date/$date'),
      headers: await _headers(),
    );
    return _decodeList(
      response,
      fallback: "Failed to load bookings for this date!",
    );
  }

  Future<Map<String, dynamic>> createLocation({
    required String locationName,
    required String imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bus-locations/create'),
      headers: await _headers(),
      body: json.encode({'locationName': locationName, 'imageUrl': imageUrl}),
    );
    return _decodeMap(response, fallback: "Failed to create location!");
  }

  Future<Map<String, dynamic>> createCompany({
    required String companyName,
    required String imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bus-company'),
      headers: await _headers(),
      body: json.encode({'companyName': companyName, 'imageUrl': imageUrl}),
    );
    return _decodeMap(response, fallback: "Failed to create company!");
  }

  Future<Map<String, dynamic>> createBusType({required String busType}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bus-type'),
      headers: await _headers(),
      body: json.encode({'busType': busType}),
    );
    return _decodeMap(response, fallback: "Failed to create bus type!");
  }

  Future<Map<String, dynamic>> createBus({
    required String companyName,
    required String busType,
    required int seatCapacity,
    required String plateNumber,
    required String imageUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/buses'),
      headers: await _headers(),
      body: json.encode({
        'companyName': companyName,
        'busType': busType,
        'seatCapacity': seatCapacity,
        'plateNumber': plateNumber,
        'imageUrl': imageUrl,
      }),
    );
    return _decodeMap(response, fallback: "Failed to create bus!");
  }

  Future<Map<String, dynamic>> createRoute({
    required String fromLocation,
    required String toLocation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bus-route'),
      headers: await _headers(),
      body: json.encode({
        'fromLocation': fromLocation,
        'toLocation': toLocation,
      }),
    );
    return _decodeMap(response, fallback: "Failed to create route!");
  }

  Future<Map<String, dynamic>> createBusSchedule({
    required int busId,
    required int routeId,
    required String travelDate,
    required String departureTime,
    required String arrivalTime,
    required int availableSeat,
    required String status,
    required double basePrice,
    required int busTypeId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bus-schedules'),
      headers: await _headers(),
      body: json.encode({
        'busId': busId,
        'routeId': routeId,
        'travelDate': travelDate,
        'departureTime': departureTime,
        'arrivalTime': arrivalTime,
        'availableSeat': availableSeat,
        'status': status,
        'basePrice': basePrice,
        'busTypeId': busTypeId,
      }),
    );
    return _decodeMap(response, fallback: "Failed to create bus schedule!");
  }

  Future<Map<String, dynamic>> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/booking/$bookingId/status'),
      headers: await _headers(),
      body: json.encode({'status': status}),
    );
    return _decodeMap(response, fallback: "Failed to update booking status!");
  }

  List<dynamic> _decodeList(
    http.Response response, {
    required String fallback,
  }) {
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception(_extractError(response, fallback: fallback));
  }

  Map<String, dynamic> _decodeMap(
    http.Response response, {
    required String fallback,
  }) {
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    }
    throw Exception(_extractError(response, fallback: fallback));
  }

  String _extractError(http.Response response, {required String fallback}) {
    try {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded['message'] != null) {
        return decoded['message'].toString();
      }
      if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
        final first = decoded.first as Map;
        if (first['message'] != null) return first['message'].toString();
      }
    } catch (_) {}
    return fallback;
  }
}
