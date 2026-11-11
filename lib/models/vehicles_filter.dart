import 'package:cargo_flow/models/json_model.dart';

class VehicleFilter implements JsonModel {
  const VehicleFilter({
    this.type,
    this.capacityFrom,
    this.capacityTo,
    this.volumeFrom,
    this.volumeTo,
  });

  final String? type;
  final double? capacityFrom;
  final double? capacityTo;
  final double? volumeFrom;
  final double? volumeTo;

  bool get isEmpty =>
      type == null &&
      capacityFrom == null &&
      capacityTo == null &&
      volumeFrom == null &&
      volumeTo == null;
  @override
  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type else 'type': null,
    if (capacityFrom != null)
      'capacity_min': capacityFrom
    else
      'capacity_min': null,
    if (capacityTo != null)
      'capacity_max': capacityTo
    else
      'capacity_max': null,
    if (volumeFrom != null)
      'car_volume_min': volumeFrom
    else
      'car_volume_min': null,
    if (volumeTo != null)
      'car_volume_max': volumeTo
    else
      'car_volume_max': null,
  };
}
