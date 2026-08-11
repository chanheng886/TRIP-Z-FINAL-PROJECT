enum BookingStatus {
  Pending,
  Confirmed,
  Cancelled;

  static BookingStatus fromString(String value) {
    return BookingStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BookingStatus.Pending,
    );
  }
}

class BookingResponse {
  final int id;
  final int userId;
  final String username;
  final DateTime bookingDate;
  final double totalAmount;
  final String paymentMethod;
  final BookingStatus bookingStatus;
  final List<String> seatNumbers;
  final String fromLocation;
  final String toLocation;
  final DateTime travelDate;
  final String departureTime;
  final String arrivalTime;

  BookingResponse({
    required this.id,
    required this.userId,
    required this.username,
    required this.bookingDate,
    required this.totalAmount,
    required this.paymentMethod,
    required this.bookingStatus,
    required this.seatNumbers,
    required this.fromLocation,
    required this.toLocation,
    required this.travelDate,
    required this.departureTime,
    required this.arrivalTime,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      id: json['id'] as int,
      userId: json['userId'] as int,
      username: json['username'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      bookingStatus: BookingStatus.fromString(json['bookingStatus'] as String),
      seatNumbers: List<String>.from(json['seatNumbers'] as List),
      fromLocation: json['fromLocation'] as String,
      toLocation: json['toLocation'] as String,
      travelDate: DateTime.parse(json['travelDate'] as String),
      departureTime: json['departureTime'] as String,
      arrivalTime: json['arrivalTime'] as String,
    );
  }
}
