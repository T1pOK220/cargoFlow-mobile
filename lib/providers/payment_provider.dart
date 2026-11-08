
import 'package:cargo_flow/services/payment_service.dart';
import 'package:cargo_flow/utils/json_parser.dart';
import 'package:flutter/material.dart';
import 'package:cargo_flow/models/bill.dart';
import 'package:cargo_flow/models/payment.dart';

class PaymentProvider extends ChangeNotifier {
  final JsonParser _jsonParser;
  final PaymentService _paymentService;

  bool isLoading = false;

  PaymentProvider(this._jsonParser, this._paymentService);

  Bill? _bill;
  List<Payment> _payments = [];

  Bill? get bill => _bill;
  List<Payment> get payments => _payments;

  Future<void> getBill() async {
    try {
      isLoading = true;
      notifyListeners();

      final bill = await _paymentService.getBill();
      _bill = Bill.fromJson(bill["bill"]);
    } catch (e) {
      debugPrint('Помилка отримання рахунку: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPayments() async {
    try {
      isLoading = true;
      notifyListeners();

      final payments = await _paymentService.getPayments();

      _payments = _jsonParser.parseList(
        payments,
        "payments",
        Payment.fromJson,
      );

      debugPrint('Отримано платежів: ${_payments.length}');
    } catch (e) {
      debugPrint('Помилка отримання платежів: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deposit(String billNumber, double amount) async {
    try {
      isLoading = true;
      final paymentRequest = {
        "bill_number": billNumber,
        "sum": amount,
      };

      await _paymentService.deposit(paymentRequest);
      notifyListeners();
    } catch (e) {
      debugPrint('Помилка поповнення: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
