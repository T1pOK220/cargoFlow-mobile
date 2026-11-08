import 'package:cargo_flow/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum _SnackType { success, error, info }
class AppSnack {
  AppSnack._();

  static void success(BuildContext context, String message) =>
      _show(context, message, _SnackType.success);

  static void error(BuildContext context, String message) =>
      _show(context, message, _SnackType.error);

  static void info(BuildContext context, String message) =>
      _show(context, message, _SnackType.info);

  static void _show(BuildContext context, String message, _SnackType type) {
    final (color, icon) = switch (type) {
      _SnackType.success => (AppTheme.green, Icons.check_circle_outline),
      _SnackType.error => (AppTheme.red, Icons.error_outline),
      _SnackType.info => (AppTheme.orange, Icons.info_outline),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.white,
          elevation: 4,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          duration: Duration(seconds: type == _SnackType.error ? 4 : 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: color.withValues(alpha: 0.35)),
          ),
          content: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.dark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}