enum MessageRole { user, assistant }

class BusRecommendation {
  final int busScheduleId;
  final String companyName;
  final String busType;
  final String fromLocation;
  final String toLocation;
  final String departureTime;
  final String arrivalTime;
  final double price;
  final int availableSeats;

  BusRecommendation({
    required this.busScheduleId,
    required this.companyName,
    required this.busType,
    required this.fromLocation,
    required this.toLocation,
    required this.departureTime,
    required this.arrivalTime,
    required this.price,
    required this.availableSeats,
  });

  factory BusRecommendation.fromJson(Map<String, dynamic> json) {
    return BusRecommendation(
      busScheduleId: json['busScheduleId'],
      companyName: json['companyName'],
      busType: json['busType'],
      fromLocation: json['fromLocation'],
      toLocation: json['toLocation'],
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      price: (json['price'] as num).toDouble(),
      availableSeats: json['availableSeats'],
    );
  }
}

class AiMessage {
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final List<BusRecommendation> recommendations;

  AiMessage({
    required this.content,
    required this.role,
    DateTime? timestamp,
    List<BusRecommendation>? recommendations,
  })  : timestamp = timestamp ?? DateTime.now(),
        recommendations = recommendations ?? [];

  Map<String, String> toChatJson() {
    return {
      'role': role == MessageRole.user ? 'user' : 'model',
      'content': content,
    };
  }
}
