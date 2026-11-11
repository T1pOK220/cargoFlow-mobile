import 'package:cargo_flow/models/vehicle_create.dart';
import 'package:cargo_flow/models/vehicle_details.dart';
import 'package:cargo_flow/models/vehicle_update.dart';
import 'package:cargo_flow/services/vehicle_service.dart';
import 'package:cargo_flow/utils/json_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:cargo_flow/models/vehicle_card.dart';
import 'package:cargo_flow/models/vehicles_filter.dart';
import 'package:cargo_flow/models/vehicle.dart';

class VehicleProvider extends ChangeNotifier {
  List<VehicleForCard> _vehicles = [];
  bool _isLoading = false;
  String? _error;
  List<String> _types = [];
  VehicleDetails? _vehicleDetails;
  final VehicleService _vehicleService;
  final JsonParser _jsonParser;
  List<Vehicle> _myVehicles = [];
  VehicleProvider(this._vehicleService, this._jsonParser);
  List<VehicleForCard> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get types => _types;
  VehicleDetails? get vehicleDetails => _vehicleDetails;
  List<Vehicle> get myVehicles => _myVehicles;

  Future<void> fetchVehicles() async {
    try {
      _isLoading = true;
      notifyListeners();

      final vehicles = await _vehicleService.getVehicles();

      _vehicles = _jsonParser.parseList(
        vehicles,
        "cars",
        VehicleForCard.fromJson,
      );

      _types = _vehicles.map((v) => v.type).toSet().toList();
    } catch (e, stackTrace) {
      debugPrint('Помилка завантаження автомобілів: $e');
      debugPrint('Помилка: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterVehicles(VehicleFilter filter) async {
    try {
      if (filter.isEmpty) return await fetchVehicles();
      final vehicles = await _vehicleService.filtersVehicles(filter);
      _vehicles = _jsonParser.parseList(
        vehicles,
        "cars",
        VehicleForCard.fromJson,
      );
      notifyListeners();
    } catch (e) {
      print(e);
      notifyListeners();
    }
  }

  Future<void> details(int id) async {
    try {
      _isLoading = true;
      final info = await _vehicleService.getVehicleDetails(id);
      _vehicleDetails = VehicleDetails.fromJson(info["carInfo"]);
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getMyVehicles() async {
    try {
      _isLoading = true;
      final myVehicles = await _vehicleService.getMyVehicles();
      _myVehicles = _jsonParser.parseList(myVehicles, "cars", Vehicle.fromJson);
      notifyListeners();
    } catch (e) {
      print(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteVehicle(int id) async {
    await _vehicleService.deleteVehicle(id);
    notifyListeners();
  }

  Future<void> createVehicle(VehicleCreate vehicle) async {
    await _vehicleService.createVehicle(vehicle);
    notifyListeners();
  }

  Future<void> updateVehicle(VehicleUpdate vehicle) async {
    await _vehicleService.updateVehicle(vehicle);
    notifyListeners();
  }
}
