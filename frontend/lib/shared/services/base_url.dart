import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseUrl {
  // Update IP port here, becuase i run the app on real device
  static final String _ip = dotenv.env['IP_ADDRESS'] ?? 'localhost';
  static final String baseUrl = "http://$_ip:8080/api/v1";

  static final String auth = "$baseUrl/auth";
  static final String booking = "$baseUrl/booking";
  static final String busSchedules = "$baseUrl/bus-schedules";
  static final String busLocations = "$baseUrl/bus-locations";
  static final String ai = "$baseUrl/ai";
  static final String buses = "$baseUrl/buses";
  static final String busRoutes = "$baseUrl/bus-route";
  static final String busTypes = "$baseUrl/bus-type";
  static final String busCompany = "$baseUrl/bus-company";
}
