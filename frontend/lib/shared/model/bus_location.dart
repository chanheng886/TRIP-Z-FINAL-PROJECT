class BusLocation {
  final int id;
  final String locationName;
  final String? imageUrl;

  BusLocation({
    required this.id,
    required this.locationName,
    this.imageUrl,
  });

  factory BusLocation.fromJson(Map<String, dynamic> json) {
    return BusLocation(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      locationName: json['locationName'] ?? '',
      imageUrl: json['imageUrl'] ?? json['images_url'],
    );
  }
}
