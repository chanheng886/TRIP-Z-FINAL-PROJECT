class BusRoute {
  final int id;
  final String fromLocation;
  final String toLocation;

  BusRoute({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['id'],
      fromLocation: json['fromLocation'],
      toLocation: json['toLocation'],
    );
  }
}
