import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseUrl {
  // On Chrome / Web, always connect directly to localhost.
  // On real mobile device, use IP_ADDRESS from .env (matching your machine's Wi-Fi IP).
  static String get _ip {
    if (kIsWeb) return 'localhost';
    final envIp = dotenv.env['IP_ADDRESS']?.trim();
    if (envIp != null && envIp.isNotEmpty) return envIp;
    return '172.16.104.29';
  }

  static String get baseUrl => "http://$_ip:8080/api/v1";

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
