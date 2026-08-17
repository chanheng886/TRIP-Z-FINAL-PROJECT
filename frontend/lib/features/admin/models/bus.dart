class Bus {
  final int id;
  final String companyName;
  final String busType;
  final String plateNumber;
  final String seatCapacity;

  Bus({
    required this.id,
    required this.companyName,
    required this.busType,
    required this.plateNumber,
    required this.seatCapacity,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'],
      companyName: json['companyName'],
      busType: json['busType'],
      plateNumber: json['plateNumber'],
      seatCapacity: json['seatCapacity']?.toString() ?? '',
    );
  }
}
