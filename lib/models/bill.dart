import 'package:cargo_flow/models/json_model.dart';

class Bill implements JsonModel {
  final int billId;
  final String billNumber;
  final String balance;
  final DateTime createAt;
  final String billTitle;

  const Bill({
    required this.billId,
    required this.billNumber,
    required this.balance,
    required this.createAt,
    required this.billTitle,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      billId: json['bill_id'] as int,
      billNumber: json['bill_number'] as String,
      balance: json['balance'].toString(),
      createAt: DateTime.parse(json['create_at'] as String),
      billTitle: json['bill_title'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'bill_id': billId,
      'bill_number': billNumber,
      'balance': balance,
      'create_at': createAt.toIso8601String(),
      'bill_title': billTitle,
    };
  }
}