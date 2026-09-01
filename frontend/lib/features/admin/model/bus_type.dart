class BusType {
  final int id;
  final String busType;

  BusType({required this.id, required this.busType});

  factory BusType.fromJson(Map<String, dynamic> json) {
    return BusType(id: json['id'], busType: json['busType']);
  }
}
