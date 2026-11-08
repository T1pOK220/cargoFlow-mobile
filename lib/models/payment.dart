
import 'package:cargo_flow/models/json_model.dart';

enum PaymentStatus {
  paid('Оплачено'),
  fail('Не оплачено');

  final String dbValue;

  const PaymentStatus(this.dbValue);

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
          (status) => status.dbValue == value,
    );
  }
}

class Payment implements JsonModel {
  final int paymentId;
  final String amount;
  final PaymentStatus status;
  final DateTime payDate;
  final String type;
  final int? senderId;
  final int? receiverId;
  final int? parentPaymentId;

  const Payment({
    required this.paymentId,
    required this.amount,
    required this.status,
    required this.payDate,
    required this.type,
    required this.senderId,
    required this.parentPaymentId,
    required this.receiverId,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'] as int,
      amount: json['amount'].toString(),
      status: PaymentStatus.fromString(
        json['status'] as String,
      ),
      payDate: DateTime.parse(json['pay_date'] as String),
      type: json['type'] as String,
      senderId: json['sender_id'] as int?,
      parentPaymentId: json['parent_payment_id'] as int?,
      receiverId: json['receiver_id'] as int?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'amount': amount,
      'status': status.dbValue,
      'pay_date': payDate.toIso8601String(),
      'type': type,
      'sender_id': senderId,
      'parent_payment_id': parentPaymentId,
      'receiver_id': receiverId,
    };
  }
}
