class Passenger {
  final String name;
  final String seatNumber;

  Passenger({required this.name, required this.seatNumber});

  Map<String, dynamic> toJson() {
    return {'name': name, 'seatNumber': seatNumber};
  }
}
