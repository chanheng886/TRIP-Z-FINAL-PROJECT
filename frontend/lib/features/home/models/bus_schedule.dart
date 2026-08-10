import 'package:intl/intl.dart';

enum BusScheduleStatus {
  Available,
  Booked;

  static BusScheduleStatus fromString(String value) {
    return BusScheduleStatus.values.firstWhere(
      (e) => e.name == value,
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
    return BusSchedule(
      id: json['id'],
      busId: json['busId'],
      plateNumber: json['plateNumber'],
      companyName: json['companyName'],
      busType: json['busType'],
      routeId: json['routeId'],
      fromLocation: json['fromLocation'],
      toLocation: json['toLocation'],
      travelDate: json['travelDate'] != null
          ? DateTime.parse(json['travelDate'])
          : DateTime.now(),
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      basePrice: json['basePrice'],
      availableSeat: json['availableSeat'],
      status: BusScheduleStatus.fromString(json['status']),
    );
  }
}
