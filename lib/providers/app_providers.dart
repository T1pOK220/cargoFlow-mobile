import 'package:cargo_flow/providers/auth_provider.dart';
import 'package:cargo_flow/providers/payment_provider.dart';
import 'package:cargo_flow/providers/vehicle_provider.dart';
import 'package:cargo_flow/services/auth_service.dart';
import 'package:cargo_flow/services/payment_service.dart';
import 'package:cargo_flow/services/token_storage.dart';
import 'package:cargo_flow/utils/json_parser.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/cargos_service.dart';
import '../providers/announcement_provider.dart';
import '../services/vehicle_service.dart';

class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TokenStorage>(create: (_) => TokenStorage()),
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<JsonParser>(create: (_) => JsonParser()),
        Provider<CargosService>(
          create: (context) => CargosService(context.read<ApiService>()),
        ),
        Provider<VehicleService>(
          create: (context) => VehicleService(context.read<ApiService>()),
        ),
        Provider<PaymentService>(
          create: (context) => PaymentService(context.read<ApiService>()),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(
            context.read<ApiService>(),
            context.read<TokenStorage>(),
          ),
        ),
        ChangeNotifierProvider<AnnouncementProvider>(
          create: (context) => AnnouncementProvider(
            context.read<CargosService>(),
            context.read<JsonParser>(),
          ),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<JsonParser>(),
          ),
        ),
        ChangeNotifierProvider<PaymentProvider>(
          create: (context) => PaymentProvider(
            context.read<JsonParser>(),
            context.read<PaymentService>(),
          ),
        ),
        ChangeNotifierProvider<VehicleProvider>(
          create: (context) => VehicleProvider(
            context.read<VehicleService>(),
            context.read<JsonParser>(),
          ),
        ),
      ],
      child: child,
    );
  }
}
