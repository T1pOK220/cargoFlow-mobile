import 'package:cargo_flow/models/json_model.dart';

class CreateCargo implements JsonModel {
  final double amount;
  final String fromCity;
  final String toCity;
  final String type;
  final int distance;
  final String addressFrom;
  final String addressTo;
  final DateTime dateFrom;
  final DateTime dateTo;
  final double height;
  final double length;
  final double width;
  final String description;
  final double weight;
  CreateCargo({
    required this.fromCity,
    required this.toCity,
    required this.distance,
    required this.length,
    required this.type,
    required this.amount,
    required this.description,
    required this.width,
    required this.height,
    required this.addressFrom,
    required this.addressTo,
    required this.dateFrom,
    required this.dateTo,
    required this.weight,
});
  @override
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'from_city': fromCity,
      'to_city': toCity,
      'type': type,
      'distance': distance,
      'address_from': addressFrom,
      'address_to': addressTo,
      'date_from': dateFrom.toIso8601String(),
      'date_to': dateTo.toIso8601String(),
      'height': height,
      'length': length,
      'width': width,
      'description': description,
      "weight":weight,
    };
  }
  String? validate() {
    if (amount <= 0) {
      return 'Сума має бути більшою за нуль';
    }

    if (height <= 0 || length <= 0 || width <= 0) {
      return 'Габарити мають бути більшими за нуль';
    }

    if (dateTo.isBefore(dateFrom)) {
      return 'Дата доставки не може бути раніше дати відправлення';
    }

    return null;
  }
}