import 'package:cargo_flow/providers/announcement_provider.dart';
import 'package:cargo_flow/routes/router.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cargo_flow/providers/announcement_provider.dart';
class CargoFlowApp extends StatelessWidget {
const CargoFlowApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp.router(
debugShowCheckedModeBanner: false,
title: 'CargoFlow',
theme: AppTheme.lightTheme,
  builder: (context, child) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: const TextScaler.linear(1.15),
      ),
      child: child!,
    );
  },
routerConfig: appRouter,
);
}
}

