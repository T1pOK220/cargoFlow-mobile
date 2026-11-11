import 'package:image_picker/image_picker.dart';
import 'package:cargo_flow/models/json_model.dart';
import 'package:cargo_flow/models/multipart.dart';

class VehicleCreate implements MultipartModel, JsonModel {
  final String brand;
  final String model;
  final String typeOfVehicle;
  final int year;
  final double capacity;
  final double volume;
  final String status;
  final String plateNumber;
  final String description;
  final int deliveryPrice;
  final String fromCity;
  final String toCity;
  final int? id;
  final XFile? file;

  VehicleCreate({
    required this.brand,
    required this.model,
    required this.typeOfVehicle,
    required this.year,
    required this.capacity,
    required this.volume,
    required this.status,
    required this.plateNumber,
    required this.description,
    required this.deliveryPrice,
    required this.fromCity,
    required this.toCity,
    this.id,
    this.file,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'model': model,
      'typeOfVehicle': typeOfVehicle,
      'year': year,
      'capacity': capacity,
      'volume': volume,
      'status': status,
      'plate_number': plateNumber,
      'description': description,
      'delivery_price': deliveryPrice,
      'from_city': fromCity,
      'to_city': toCity,
      'id': id,
    };
  }
}
