import 'api_service.dart';

class CargosService {
  final ApiService _api;

  CargosService(this._api);

  Future<dynamic> getCargos() async {
    return await _api.get('cargos');
  }

  Future<dynamic> filtersCargo(dynamic filters) async {
    return await _api.post('cargos/filter', filters);
  }

  Future<dynamic> createCargo(dynamic cargo) async {
    return await _api.post("cargos/create", cargo);
  }

  Future<Map<String, dynamic>> cargoDetails(int id) async {
    return await _api.get('cargos/info/$id');
  }

  Future<dynamic> getCargosByUser() async {
    return await _api.get('cargos/byUser');
  }
}
