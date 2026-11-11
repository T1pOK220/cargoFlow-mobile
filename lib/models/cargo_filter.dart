import 'package:cargo_flow/models/json_model.dart';

class CargoFilter implements JsonModel {
  final String? fromCity;
  final String? toCity;
  final double? amountFrom;
  final double? amountTo;
  final double? weight;

  CargoFilter({
    this.fromCity,
    this.toCity,
    this.amountFrom,
    this.amountTo,
    this.weight,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (fromCity != null && fromCity!.trim().isNotEmpty)
        'from_city': fromCity!.trim()
      else
        "from_city": null,
      if (toCity != null && toCity!.trim().isNotEmpty)
        'to_city': toCity!.trim()
      else
        "to_city": null,
      if (amountFrom != null)
        'amount_from': amountFrom
      else
        "amount_from": null,
      if (amountTo != null) 'amount_to': amountTo else "amount_to": null,
      if (weight != null) 'weight': weight else "weight": null,
    };
  }
}
