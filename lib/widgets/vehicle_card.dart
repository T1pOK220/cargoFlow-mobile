import 'package:flutter/material.dart';
import 'package:cargo_flow/theme/app_theme.dart';
import 'package:cargo_flow/models/vehicle_card_data.dart';
import 'package:cargo_flow/utils/config.dart';
class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, this.onTap});

  final VehicleCardData vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = vehicle.avatarUrl;

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
          child: Row(
            children: [
              avatar != null && avatar.isNotEmpty
                  ? Image.network(
                      '$baseUrl$avatar',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    )
                  : const SizedBox(
                      width: 100,
                      height: 100,
                      child: Icon(Icons.image_not_supported),
                    ),

              const SizedBox(width: 20),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${vehicle.brand} ${vehicle.model}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${vehicle.deliveryPriceText} грн',
                          style: const TextStyle(
                            color: AppTheme.orange,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    if (vehicle.routeText != null) Text(vehicle.routeText!),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 6,
                      children: [
                        _Tag(vehicle.type),
                        _Tag('${vehicle.capacityText} Т'),
                        _StatusTag(vehicle.status.dbValue),
                      ],
                    ),
                  ],
                ),
              ),
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag(this.status);

  final String status;

  @override
  Widget build(BuildContext context) {
    final free = status == 'Доступний';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: free ? const Color(0xFFC9F5CD) : const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: free ? const Color(0xFF157A33) : Colors.black54,
        ),
      ),
    );
  }
}
