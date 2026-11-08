import 'package:cargo_flow/models/json_model.dart';
class Route implements JsonModel {
  final int routeId;
  final String fromCity;
  final String toCity;
  final int distance;
  final String addressFrom;
  final String addressTo;
  const Route({
    required this.routeId,
    required this.fromCity,
    required this.toCity,
    required this.addressFrom,
    required this.addressTo,
    required this.distance,
});
  factory Route.fromJson(Map<String,dynamic>json){
    return Route(
        routeId:json["vehicle_id"] as int,
        fromCity: json["from_city"] as String,
        toCity: json["to_city"] as String,
        addressFrom: json["address_from"] as String,
        addressTo: json["address_to"] as String,
        distance: json["distance"] as int
    );
  }
  @override
  Map<String,dynamic> toJson(){
    return {
      "from_city":fromCity,
      "to_city":toCity,
      "address_from":addressFrom,
      "address_to": addressTo,
      "distance": distance
    };
  }

}