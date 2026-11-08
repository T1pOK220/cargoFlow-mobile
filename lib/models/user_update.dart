import 'package:cargo_flow/models/json_model.dart';

class UserUpdate implements JsonModel {
  final String name;
  final String lastName;
  final String email;
  final String phone;

  const UserUpdate({
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  factory UserUpdate.fromJson(Map<String, dynamic> json) {
    return UserUpdate(
      name: json['name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'last_name': lastName,
      'phone': phone,
      'email': email
    };
  }
}