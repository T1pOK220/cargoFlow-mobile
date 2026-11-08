import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CargoCard extends StatelessWidget {
  const CargoCard({
    super.key,
    required this.from,
    required this.to,
    required this.price,
    required this.date,
    required this.type,
    required this.distance,
    this.onTap,
  });

  final String from;
  final String to;
  final String price;
  final String date;
  final String type;
  final int distance;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE4E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('$from → $to',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  Text("$price грн",
                      style: const TextStyle(
                          color: AppTheme.orange, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 4),
              Text(formatingString(date), style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              Wrap(spacing: 6, children: [
                _Tag(type),
                _Tag("$distance км"),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F7F9),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12)),
  );
}
String formatingString(String text){
  final date = DateTime.parse(text);
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minutes = date.minute.toString().padLeft(2, '0');
  return '$month.$day,$hour:$minutes';
}