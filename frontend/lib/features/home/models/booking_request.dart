import 'passenger.dart';

class BookingRequest {
  final int busScheduleId;
  final String bookerName;
  final String phone;
  final String? email;
  final String gender;
  final String paymentMethod;
  final List<Passenger> passengers;

  BookingRequest({
    required this.busScheduleId,
    required this.bookerName,
    required this.phone,
    this.email,
    required this.gender,
    required this.paymentMethod,
    required this.passengers,
  });

  Map<String, dynamic> toJson() {
    return {
      'busScheduleId': busScheduleId,
      'bookerName': bookerName,
      'phone': phone,
      'email': email,
      'gender': gender,
      'paymentMethod': paymentMethod,
      'passengers': passengers.map((p) => p.toJson()).toList(),
    };
  }
}
