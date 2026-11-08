import 'package:cargo_flow/models/cargo_details.dart';
import 'package:cargo_flow/models/cargo_filter.dart';
import 'package:cargo_flow/models/create_cargo.dart';
import 'package:cargo_flow/services/cargos_service.dart';
import 'package:flutter/material.dart';
import '../models/announcement_card.dart';
import '../utils/json_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:cargo_flow/models/create_cargo.dart';
class AnnouncementProvider extends ChangeNotifier {
  List<AnnouncementCard> announcements = [];
  final CargosService _cargosService;
  final JsonParser _jsonParser;
  CargoDetails? _cargoDetails;
  List<AnnouncementCard> _announcementsByUser = [];
  AnnouncementProvider(this._cargosService,this._jsonParser);
  bool isLoading = false;
  CargoDetails? get cargoDetails => _cargoDetails;
  List<AnnouncementCard> get announcementsByUser =>_announcementsByUser;

  Future<void> fetchAnnouncements() async {
    isLoading = true;
    notifyListeners();
    try {
      var announcementsJson = await _cargosService.getCargos();
      announcements = _jsonParser.parseList<AnnouncementCard>(announcementsJson,'cargos',AnnouncementCard.fromJson);
      notifyListeners();
    } catch (e) {
      debugPrint('Помилка завантаження оголошень: $e');
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
  Future<void> filterAnnouncements(CargoFilter filters) async{
    isLoading = true;
    notifyListeners();
    try {
      var announcementsJson = await _cargosService.filtersCargo(filters);
      announcements = _jsonParser.parseList<AnnouncementCard>(announcementsJson,'filtredCargos',AnnouncementCard.fromJson);
      notifyListeners();
    } catch (e) {
      debugPrint('Помилка завантаження оголошень: $e');
    } finally {
      isLoading = false;

      notifyListeners();
    }
  }
  Future<void> createCargo (CreateCargo cargo) async {
    try{
      await _cargosService.createCargo(cargo.toJson());
      notifyListeners();
    }
    catch(e){
      debugPrint('Невдалось створити оголошення: $e');
      notifyListeners();
    }
  }
  Future<void> details (int id) async {
    try{
      isLoading = true;
      final cargoDetails = await _cargosService.cargoDetails(id);
      _cargoDetails = CargoDetails.fromJson(cargoDetails["cargoInfo"]);
      notifyListeners();
    }
    catch(e){
      isLoading = true;
      notifyListeners();
      print(e);
    }
  }
  Future<void> announcementByUser() async {
    try{
      final announcementsByUser = await _cargosService.getCargosByUser();
      _announcementsByUser = _jsonParser.parseList(announcementsByUser, "cargosByUser", AnnouncementCard.fromJson);
    }
    catch(e){
      print(e);
    }
  }
}
