class BusStation {
  final int id;
  final String name;
  final String nameKh;
  final String city;
  final String address;
  final String addressKh;
  final double latitude;
  final double longitude;
  final List<String> operators;
  final String openingHours;
  final String phone;
  final String imageUrl;
  final List<String> facilities;
  final double rating;

  const BusStation({
    required this.id,
    required this.name,
    required this.nameKh,
    required this.city,
    required this.address,
    required this.addressKh,
    required this.latitude,
    required this.longitude,
    required this.operators,
    required this.openingHours,
    required this.phone,
    required this.imageUrl,
    required this.facilities,
    required this.rating,
  });

  String localizedName(bool isKhmer) => isKhmer ? nameKh : name;
  String localizedAddress(bool isKhmer) => isKhmer ? addressKh : address;

  factory BusStation.fromJson(Map<String, dynamic> json) {
    return BusStation(
      id: json['id'] as int,
      name: json['name'] as String,
      nameKh: json['nameKh'] as String? ?? json['name'] as String,
      city: json['city'] as String,
      address: json['address'] as String,
      addressKh: json['addressKh'] as String? ?? json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      operators: List<String>.from(json['operators'] ?? []),
      openingHours: json['openingHours'] as String? ?? '06:00 AM - 10:00 PM',
      phone: json['phone'] as String? ?? '+855 23 888 999',
      imageUrl: json['imageUrl'] as String? ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.7,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameKh': nameKh,
      'city': city,
      'address': address,
      'addressKh': addressKh,
      'latitude': latitude,
      'longitude': longitude,
      'operators': operators,
      'openingHours': openingHours,
      'phone': phone,
      'imageUrl': imageUrl,
      'facilities': facilities,
      'rating': rating,
    };
  }
}
