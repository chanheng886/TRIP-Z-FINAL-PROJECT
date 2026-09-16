import 'package:intl/intl.dart';

enum BusScheduleStatus {
  Available,
  Booked,
  Cancelled,
  Expired;

  static BusScheduleStatus fromString(String value) {
    return BusScheduleStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => BusScheduleStatus.Available,
    );
  }
}

class BusSchedule {
  final int id;
  final int busId;
  final String plateNumber;
  final String companyName;
  final String busType;
  final int routeId;
  final String fromLocation;
  final String toLocation;
  final DateTime travelDate;
  final String departureTime;
  final String arrivalTime;
  final double basePrice;
  final int availableSeat;
  final BusScheduleStatus status;

  String get formattedDate => DateFormat('MM dd, yyyy').format(travelDate);

  bool get isExpired {
    if (status == BusScheduleStatus.Expired) return true;
    // A schedule expires only when the travel DATE is strictly in the past.
    // A schedule for today (even with a past departure time) is still valid.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDay = DateTime(travelDate.year, travelDate.month, travelDate.day);
    return tripDay.isBefore(today);
  }

  BusSchedule({
    required this.id,
    required this.busId,
    required this.plateNumber,
    required this.companyName,
    required this.busType,
    required this.routeId,
    required this.fromLocation,
    required this.toLocation,
    required this.travelDate,
    required this.departureTime,
    required this.arrivalTime,
    required this.basePrice,
    required this.availableSeat,
    required this.status,
  });

  factory BusSchedule.fromJson(Map<String, dynamic> json) {
    final parsedStatus = BusScheduleStatus.fromString(json['status'] ?? '');
    final tDate = json['travelDate'] != null
        ? DateTime.parse(json['travelDate'])
        : DateTime.now();
    final depTime = json['departureTime']?.toString() ?? '00:00:00';

    // A schedule expires only when the travel DATE is strictly yesterday or older.
    // Schedules for today remain Available regardless of departure time.
    BusScheduleStatus finalStatus = parsedStatus;
    if (finalStatus != BusScheduleStatus.Cancelled) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tripDay = DateTime(tDate.year, tDate.month, tDate.day);
      if (tripDay.isBefore(today)) {
        finalStatus = BusScheduleStatus.Expired;
      }
    }

    return BusSchedule(
      id: json['id'],
      busId: json['busId'],
      plateNumber: json['plateNumber'],
      companyName: json['companyName'],
      busType: json['busType'],
      routeId: json['routeId'],
      fromLocation: json['fromLocation'],
      toLocation: json['toLocation'],
      travelDate: tDate,
      departureTime: depTime,
      arrivalTime: json['arrivalTime']?.toString() ?? '',
      basePrice: (json['basePrice'] is num)
          ? (json['basePrice'] as num).toDouble()
          : 0.0,
      availableSeat: json['availableSeat'] ?? 0,
      status: finalStatus,
    );
  }
}
