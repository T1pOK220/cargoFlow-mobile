import 'package:cargo_flow/models/json_model.dart';
class Cargo implements JsonModel {
  final int cargoid;
  final double weight;
  final String type;
  final String description;
  final double amount;
  final double height;
  final double length;
  final double volume;
  final int width;
  const Cargo({
    required this.cargoid,
    required this.weight,
    required this.type,
    required this.description,
    required this.amount,
    required this.height,
    required this.length,
    required this.volume,
    required this.width,
  });
  factory Cargo.fromJson(Map<String,dynamic>json){
    return Cargo(
      cargoid:["cargo_id"] as int,
    weight: ["weight"] as double,
    type: ["type"] as String,
    description: ["description"] as String,
    amount: ["amount"] as double,
    height:["height"] as double,
    length: ["length"] as double,
    volume: ["volume"] as double,
    width: ["width"] as int,
    );
}
@override
Map<String,dynamic> toJson(){
    return {
      "weight":weight,
      "type":type,
      "description":description,
      "amount":amount,
      "height":height,
      "length":length,
      "volume":volume,
      "width":width,
    };

}
}

