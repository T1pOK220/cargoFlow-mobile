import 'package:cargo_flow/models/json_model.dart';
class AnnouncementCard implements JsonModel {
  final int announcementId;
  final String createDate;
  final String amount;
  final String fromCity;
  final String toCity;
  final String type;
  final int distance;

  const AnnouncementCard({
    required this.announcementId,
    required this.createDate,
    required this.amount,
    required this.type,
    required this.distance,
    required this.fromCity,
    required this.toCity,
  });

  factory AnnouncementCard.fromJson(Map<String, dynamic> json) {
    return AnnouncementCard(
      announcementId: json["announcement_id"] as int,
      createDate: json["create_date"] as String,
      amount: json["amount"].toString(),
      distance: json["distance"] as int,
      toCity: json["to_city"] as String,
      fromCity: json["from_city"] as String,
      type: json["type"] as String,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      "announcement_id": announcementId,
      "create_date": createDate,
      "amount": amount,
      "from_city": fromCity,
      "to_city": toCity,
      "type": type,
      "distance": distance,
    };
  }
}
