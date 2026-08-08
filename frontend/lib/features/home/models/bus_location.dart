class BusLocation {
  final int id;
  final String locationName;

  BusLocation({required this.id, required this.locationName});

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    return BusLocation(id: json['id'], locationName: json['locationName']);
  }
}
