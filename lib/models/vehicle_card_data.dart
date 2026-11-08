import 'package:cargo_flow/models/vehicle.dart';
import 'package:cargo_flow/models/vehicle_status.dart';
abstract interface class VehicleCardData {
  int get vehicleId;
  String get brand;
  String get model;
  String get type;
  VehicleStatus get status;

  String get capacityText;
  String get deliveryPriceText;
  String? get avatarUrl;

  String? get routeText;
}