import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseUrl {
  /// Default production / deployed backend URL
  static const String defaultBackendUrl = 'https://tripz-backend-1mm1.onrender.com';

  /// Root URL of the backend (e.g. "https://tripz-backend-1mm1.onrender.com" or "http://localhost:8080")
  static String get rootUrl {
    final backendUrl = dotenv.env['BACKEND_URL']?.trim();
    if (backendUrl != null && backendUrl.isNotEmpty) {
      return backendUrl.endsWith('/')
          ? backendUrl.substring(0, backendUrl.length - 1)
          : backendUrl;
    }
    final envIp = dotenv.env['IP_ADDRESS']?.trim();
    if (envIp != null && envIp.isNotEmpty && envIp != 'localhost') {
      return 'http://$envIp:8080';
    }
    return defaultBackendUrl;
  }

  static String get baseUrl => "$rootUrl/api/v1";

  static String get auth => "$baseUrl/auth";
  static String get booking => "$baseUrl/booking";
  static String get busSchedules => "$baseUrl/bus-schedules";
  static String get busLocations => "$baseUrl/bus-locations";
  static String get ai => "$baseUrl/ai";
  static String get buses => "$baseUrl/buses";
  static String get busRoutes => "$baseUrl/bus-route";
  static String get busTypes => "$baseUrl/bus-type";
  static String get busCompany => "$baseUrl/bus-company";
}
