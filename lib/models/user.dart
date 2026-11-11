import 'package:cargo_flow/models/json_model.dart';

class User implements JsonModel {
  final int? userId;
  final String name;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final String? avatarUrl;
  const User({
    this.userId,
    required this.name,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.avatarUrl,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as int,
      name: json['name'] as String,
      lastName: json["last_name"] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      password: json['password'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "last_name": lastName,
      "phone": phone,
      "email": email,
      "password": password,
    };
  }
}
