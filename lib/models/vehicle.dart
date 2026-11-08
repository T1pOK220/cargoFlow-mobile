import 'package:cargo_flow/models/vehicle_card_data.dart';
import 'package:cargo_flow/models/vehicle_status.dart';
double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().replaceAll(',', '.'));
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

class Vehicle implements VehicleCardData {
  const Vehicle({
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.userId,
    required this.type,
    required this.status,
    this.capacity,
    this.year,
    this.cargoVolume,
    this.description,
    this.avatarUrl,
    this.routeId,
    this.deliveryPrice,
  });
  @override
  String get capacityText => capacity?.toString() ?? '—';

  @override
  String get deliveryPriceText =>
      deliveryPrice?.toString() ?? '—';

  @override
  String? get routeText => null;
  final int vehicleId;
  final String brand;
  final String model;
  final String plateNumber;
  final double? capacity;
  final int userId;
  final String type;
  final int? year;
  final double? cargoVolume;
  final VehicleStatus status;
  final String? description;
  final String? avatarUrl;
  final int? routeId;
  final double? deliveryPrice;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: _toInt(json['vehicle_id']) ?? 0,
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ?? '',
      capacity: _toDouble(json['capacity']),
      userId: _toInt(json['users_user_id']) ?? 0,
      type: json['type']?.toString() ?? '',
      year: _toInt(json['year']),
      cargoVolume: _toDouble(json['cargo_volume']),
      status:VehicleStatus.fromString(
        json["status"] as String,
      ),
      description: json['description']?.toString(),
      avatarUrl: json['v_avatar_url']?.toString(),
      routeId: _toInt(json['routes_route_id']),
      deliveryPrice: _toDouble(json['delivery_price']),
    );
  }

  Map<String, dynamic> toJson() => {
    'vehicle_id': vehicleId,
    'brand': brand,
    'model': model,
    'plate_number': plateNumber,
    'capacity': capacity,
    'users_user_id': userId,
    'type': type,
    'year': year,
    'cargo_volume': cargoVolume,
    'status': status,
    'description': description,
    'v_avatar_url': avatarUrl,
    'routes_route_id': routeId,
    'delivery_price': deliveryPrice,
  };

}