class Company {
  final int id;
  final String companyName;
  final String imageUrl;

  Company({
    required this.id,
    required this.companyName,
    required this.imageUrl,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      companyName: json['companyName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
