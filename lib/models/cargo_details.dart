class CargoDetails{
  final int announcementId;
  final int cargoId;
  final DateTime createDate;
  final String status;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String type;
  final String? description;
  final double weight;
  final double amount;
  final double height;
  final double length;
  final double width;
  final double volume;
  final String fromCity;
  final String toCity;
  final double distance;
  final String? addressFrom;
  final String? addressTo;
  final String name;
  final String lastName;
  final String phone;
  final String email;
  final String? avatarUrl;

  const CargoDetails({
    required this.announcementId,
    required this.cargoId,
    required this.createDate,
    required this.status,
    required this.dateFrom,
    required this.dateTo,
    required this.type,
    this.description,
    required this.weight,
    required this.amount,
    required this.height,
    required this.length,
    required this.width,
    required this.volume,
    required this.fromCity,
    required this.toCity,
    required this.distance,
    this.addressFrom,
    this.addressTo,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.email,
    this.avatarUrl,
  });

  factory CargoDetails.fromJson(Map<String, dynamic> json) {
    return CargoDetails(
      announcementId: _toInt(json['announcement_id']),
      cargoId: _toInt(json['cargo_id']),
      createDate: DateTime.parse(json['create_date'] as String).toLocal(),
      status: json['status'] as String,
      dateFrom: DateTime.parse(json['date_from'] as String).toLocal(),
      dateTo: DateTime.parse(json['date_to'] as String).toLocal(),
      type: json['type'] as String,
      description: json['description'] as String?,
      weight: _toDouble(json['weight']),
      amount: _toDouble(json['amount']),
      height: _toDouble(json['height']),
      length: _toDouble(json['length']),
      width: _toDouble(json['width']),
      volume: _toDouble(json['volume']),
      fromCity: json['from_city'] as String,
      toCity: json['to_city'] as String,
      distance: _toDouble(json['distance']),
      addressFrom: json['address_from'] as String?,
      addressTo: json['address_to'] as String?,
      name: json['name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.')) ?? 0;
  return 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}