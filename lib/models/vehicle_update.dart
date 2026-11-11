import 'package:cargo_flow/models/json_model.dart';
import 'package:cargo_flow/models/multipart.dart';
import 'package:cargo_flow/models/vehicle_status.dart';
import 'package:image_picker/image_picker.dart';

class VehicleUpdate implements JsonModel, MultipartModel {
  final int? id;
  final String? brand;
  final String? model;
  final String? plateNumber;
  final double? capacity;
  final String? type;
  final int? year;
  final double? cargoVolume;
  final VehicleStatus? status;
  final String? description;
  final String? avatarUrl;
  final XFile? file;

  const VehicleUpdate({
    this.id,
    this.brand,
    this.model,
    this.plateNumber,
    this.capacity,
    this.type,
    this.year,
    this.cargoVolume,
    this.status,
    this.description,
    this.avatarUrl,
    this.file,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'model': model,
      'plate_number': plateNumber,
      'capacity': capacity,
      'type': type,
      'year': year,
      'cargo_volume': cargoVolume,
      'status': status?.dbValue,
      'description': description,
      'v_avatar_url': avatarUrl,
    };
  }
}
