import 'package:cargo_flow/models/user.dart';
import 'package:cargo_flow/models/user_update.dart';
import 'package:cargo_flow/services/auth_service.dart';
import 'package:cargo_flow/utils/json_parser.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final JsonParser _jsonParser;
  bool isLoading = false;
  bool isAuthorized = false;
  User? _user;
  AuthProvider(this._authService, this._jsonParser);
  User? get user => _user;
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String lastName,
    required String phone,
  }) async {
    try {
      isLoading = true;
      User user = User(
        name: name,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
      );
      await _authService.register(user);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(e as String?);
      isLoading = false;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading = true;
      notifyListeners();

      final authorized = await _authService.login(email, password);

      final success = authorized['success'] == true;

      if (!success) {
        isAuthorized = false;
        _user = null;
        return false;
      }

      _user = User.fromJson(Map<String, dynamic>.from(authorized['user']));

      isAuthorized = true;

      return true;
    } catch (e) {
      debugPrint('Login error: $e');

      isAuthorized = false;
      _user = null;

      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyToken() async {
    try {
      var _isAuthorized = await _authService.verifyToken();
      isAuthorized = _isAuthorized;
      notifyListeners();
    } catch (e) {
      _authService.logOut();
      isAuthorized = false;
      notifyListeners();
    }
  }

  Future<void> getUser() async {
    try {
      isLoading = true;
      notifyListeners();
      final response = await _authService.getUser();
      _user = User.fromJson(response);
    } catch (e, stack) {
      debugPrintStack(stackTrace: stack);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(
  { required String name,
    required String lastName,
     required String email,
    required String phone,}
  ) async {
    try {
      final user = UserUpdate(
        name: name,
        lastName: lastName,
        email: email,
        phone: phone,
      );
      final updateUser = await _authService.updateProfile(user);
      _user = User.fromJson(updateUser["user"]);
      notifyListeners();
    } catch (e) {
      print(e);
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    await _authService.logOut();
    isAuthorized = false;
    _user = null;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _authService.deleteAccount();
    logOut();
    _user = null;
  }
  Future<void> changePassword(String oldPassword, String newPassword) async {
    Map<String, dynamic> changeRequest = {
      "oldPassword": oldPassword,
      "NewPassword": newPassword,
    };
    await _authService.changePassword(changeRequest);
    notifyListeners();
  }
}
