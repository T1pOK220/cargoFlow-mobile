import './api_service.dart';

class PaymentService {
  final ApiService _apiService;
  PaymentService(this._apiService);
  Future<Map<String, dynamic>> getBill() async {
    return await _apiService.get("payments/bill");
  }

  Future<dynamic> getPayments() async {
    return await _apiService.get("payments/byUser");
  }

  Future<dynamic> createPay(dynamic pay) async {
    return await _apiService.post("payments/create", pay);
  }

  Future<void> createBill(dynamic bill) async {
    return await _apiService.post("payments/createBill", bill);
  }

  Future<void> deposit(dynamic dep) async {
    return await _apiService.post("payments/deposit", dep);
  }
}
