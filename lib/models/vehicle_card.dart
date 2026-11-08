import 'package:cargo_flow/models/json_model.dart';
import 'package:cargo_flow/models/vehicle_card_data.dart';
import 'package:cargo_flow/models/vehicle_status.dart';
class VehicleForCard implements JsonModel,VehicleCardData {
  final int vehicleId;
  final String brand;
  final String model;
  final String capacity;
  final String type;
  final int year;
  final String cargoVolume;
  final VehicleStatus status;
  final String deliveryPrice;
  final String fromCity;
  final String toCity;
  final String? vAvatarUrl;
  const VehicleForCard({
    required this.vehicleId,
    required this.brand,
    required this.model,
    required this.capacity,
    required this.type,
    required this.year,
    required this.cargoVolume,
    required this.status,
    required this.deliveryPrice,
    required this.fromCity,
    required this.toCity,
    required this.vAvatarUrl,
});
  @override
  String get capacityText => capacity;

  @override
  String get deliveryPriceText => deliveryPrice;

  @override
  String? get avatarUrl => vAvatarUrl;

  @override
  String? get routeText => '$fromCity → $toCity';
  factory VehicleForCard.fromJson(Map<String, dynamic> json) {
    return VehicleForCard(
      vehicleId: json["vehicle_id"] as int,
      brand: json["brand"] as String,
      model: json["model"] as String,
      capacity: json["capacity"].toString(),
      type: json["type"] as String,
      year: json["year"] as int,
      cargoVolume: json["cargo_volume"].toString(),
      status: VehicleStatus.fromString(
        json["status"] as String,
      ),
      deliveryPrice: json["delivery_price"].toString(),
      fromCity: json["from_city"] as String,
      toCity: json["to_city"] as String,
      vAvatarUrl: json["v_avatar_url"] as String?
    );
  }
  @override
  Map<String,dynamic>toJson(){
    return {
      "brand":brand,
          "model":model,
          "capacity":capacity,
          "type":type,
          "year":year,
          "cargo_volume":cargoVolume,
          "status":status,
          "delivery_price":deliveryPrice,
      "from_city":fromCity,
      "to_city":toCity,
      "v_avatar_url":vAvatarUrl,
    };
  }
}