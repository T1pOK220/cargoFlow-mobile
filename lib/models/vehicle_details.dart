class VehicleDetails {
  final int vehicleId;
  final String brand;
  final String model;
  final String plateNumber;
  final double capacity;
  final int userId;
  final String type;
  final int year;
  final double cargoVolume;
  final VehicleStatus status;
  final String? description;
  final String? vAvatarUrl;
  final double deliveryPrice;
  final int ownerId;
  final String name;
  final String lastName;
  final String phone;
  final String email;
  final String? avatarUrl;
  final String? billNumber;
  final int routeId;
  final String fromCity;
  final String toCity;
  final double distance;
  final String? addressFrom;
  final String? addressTo;

  const VehicleDetails({
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.capacity,
    required this.userId,
    required this.type,
    required this.year,
    required this.cargoVolume,
    required this.status,
    this.description,
    this.vAvatarUrl,
    required this.deliveryPrice,
    required this.ownerId,
    required this.name,
    required this.lastName,
    required this.phone,
    required this.email,
    this.avatarUrl,
    this.billNumber,
    required this.routeId,
    required this.fromCity,
    required this.toCity,
    required this.distance,
    this.addressFrom,
    this.addressTo,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      vehicleId: json['vehicle_id'] as int,
      brand: json['brand'] as String,
      model: json['model'] as String,
      plateNumber: json['plate_number'] as String,
      capacity: double.parse(json['capacity'].toString()),
      userId: json['users_user_id'] as int,
      type: json['type'] as String,
      year: json['year'] as int,
      cargoVolume: double.parse(json['cargo_volume'].toString()),
      status: VehicleStatus.fromString(json['status'] as String),
      description: json['description'] as String?,
      vAvatarUrl: json['v_avatar_url'] as String?,
      deliveryPrice: double.parse(json['delivery_price'].toString()),
      ownerId: json['user_id'] as int,
      name: json['name'] as String,
      lastName: json['last_name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      billNumber: json['bill_number'] as String?,
      routeId: json['route_id'] as int,
      fromCity: json['from_city'] as String,
      toCity: json['to_city'] as String,
      distance: double.parse(json['distance'].toString()),
      addressFrom: json['address_from'] as String?,
      addressTo: json['address_to'] as String?,
    );
  }
}

enum VehicleStatus {
  available('Доступний'),
  unavailable('Не доступний');

  final String dbValue;

  const VehicleStatus(this.dbValue);

  factory VehicleStatus.fromString(String value) {
    return VehicleStatus.values.firstWhere(
      (status) => status.dbValue == value,
      orElse: () => VehicleStatus.unavailable,
    );
  }
}
