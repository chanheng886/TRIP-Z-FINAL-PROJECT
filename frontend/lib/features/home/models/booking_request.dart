import 'passenger.dart';

class BookingRequest {
  final int customerId;
  final int busScheduleId;
  final String paymentMethod;
  final List<Passenger> passengers;

  BookingRequest({
    required this.customerId,
    required this.busScheduleId,
    required this.paymentMethod,
    required this.passengers,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'busScheduleId': busScheduleId,
      'paymentMethod': paymentMethod,
      'passengers': passengers.map((p) => p.toJson()).toList(),
    };
  }
}
