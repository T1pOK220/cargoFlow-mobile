import 'api_service.dart';

class VehicleService {
  final ApiService _api;

  VehicleService(this._api);

  Future<Map<String, dynamic>> getVehicles() async {
    return await _api.get('vehicles');
  }

  Future<dynamic> filtersVehicles(dynamic filters) async {
    return await _api.post('vehicles/filter', filters);
  }

  Future<Map<String, dynamic>> getVehicleDetails(int id) async {
    return await _api.get('vehicles/$id');
  }

  Future<Map<String, dynamic>> getMyVehicles() async {
    return await _api.get('vehicle/byUser');
  }

  Future<dynamic> deleteVehicle(int id) async {
    return await _api.delete("vehicle/delete/$id");
  }

  Future<dynamic> createVehicle(dynamic car) async {
    return await _api.multipartRequest("vehicle/add", car, "POST");
  }

  Future<dynamic> updateVehicle(dynamic car) async {
    return _api.multipartRequest("vehicle/edit", car, "PATCH");
  }
}
