class SeatMap {
  final int busScheduleId;
  final List<String> allSeats;
  final List<String> bookedSeats;

  SeatMap({
    required this.busScheduleId,
    required this.allSeats,
    required this.bookedSeats,
  });

  factory SeatMap.fromJson(Map<String, dynamic> json) {
    return SeatMap(
      busScheduleId: json['busScheduleId'] as int,
      allSeats: List<String>.from(json['allSeats'] as List),
      bookedSeats: List<String>.from(json['bookedSeats'] as List),
    );
  }

  List<String> get availableSeats =>
      allSeats.where((seat) => !bookedSeats.contains(seat)).toList();

  bool isBooked(String seat) => bookedSeats.contains(seat);
}
