import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cargo_flow/providers/vehicle_provider.dart';
import 'package:cargo_flow/models/vehicle_details.dart';
import 'package:cargo_flow/widgets/hero_banner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cargo_flow/utils/config.dart';
import 'package:cargo_flow/widgets/app_snack_bar.dart';
class VehicleDetailsScreen extends StatefulWidget {
  const VehicleDetailsScreen({super.key, required this.id});

  final int id;
  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() {
    return context.read<VehicleProvider>().details(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();
    final VehicleDetails? v = provider.vehicleDetails;

    return Scaffold(
      appBar: HeroBanner.compact(
        text: v == null ? 'Автомобіль' : '${v.brand} ${v.model}',
        additionalText: v?.plateNumber,
        showBack: true,
        onBack: ()=>{context.pop()},
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (provider.isLoading && v == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (v == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(provider.error ?? 'Не вдалося завантажити дані'),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _VehicleHeader(v: v),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Характеристики',
                      icon: Icons.local_shipping_outlined,
                      children: [
                        _InfoRow('Тип', v.type),
                        _InfoRow('Рік випуску', '${v.year}'),
                        _InfoRow('Номерний знак', v.plateNumber),
                        _InfoRow('Вантажопідйомність', '${_num(v.capacity)} т'),
                        _InfoRow('Об\'єм кузова', '${_num(v.cargoVolume)} м³'),
                      ],
                    ),
                    if (v.description != null && v.description!.trim().isNotEmpty)
                      _Section(
                        title: 'Опис',
                        icon: Icons.notes_outlined,
                        children: [
                          Text(
                            v.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    _Section(
                      title: 'Маршрут',
                      icon: Icons.route_outlined,
                      children: [
                        _RouteBlock(v: v),
                      ],
                    ),
                    _Section(
                      title: 'Вартість',
                      icon: Icons.payments_outlined,
                      children: [
                        _InfoRow('Ціна доставки', '${_num(v.deliveryPrice)} ₴'),
                      ],
                    ),
                    _Section(
                      title: 'Власник',
                      icon: Icons.person_outline,
                      children: [_OwnerBlock(v: v)],
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String _num(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

class _VehicleHeader extends StatelessWidget {
  const _VehicleHeader({required this.v});
  final VehicleDetails v;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: scheme.surfaceContainerHighest.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: v.vAvatarUrl != null && v.vAvatarUrl!.isNotEmpty
                ? Image.network(
              '$baseUrl${v.vAvatarUrl}',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator()),
            )
                : const _ImagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${v.brand} ${v.model}',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${v.type} • ${v.year}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(status: v.status),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.local_shipping, size: 64, color: scheme.onSurfaceVariant),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final VehicleStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = status.dbValue;
    final color = scheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
class _RouteBlock extends StatelessWidget {
  const _RouteBlock({required this.v});
  final VehicleDetails v;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget point(IconData icon, Color color, String city, String? address) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(city,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600)),
                if (address != null && address.isNotEmpty)
                  Text(address,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        point(Icons.trip_origin, scheme.primary, v.fromCity, v.addressFrom),
        Padding(
          padding: const EdgeInsets.only(left: 9),
          child: Container(
            width: 2,
            height: 24,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: scheme.outlineVariant,
          ),
        ),
        point(Icons.location_on, scheme.error, v.toCity, v.addressTo),
        const Divider(height: 24),
        _InfoRow('Відстань', '${_num(v.distance)} км'),
      ],
    );
  }
}
class _OwnerBlock extends StatelessWidget {
  const _OwnerBlock({required this.v});
  final VehicleDetails v;

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      AppSnack.error(context,'Не вдалося відкрити');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = '${v.name} ${v.lastName}'.trim();
    final hasAvatar = v.avatarUrl != null && v.avatarUrl!.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: hasAvatar ? NetworkImage('$baseUrl${v.avatarUrl}') : null,
              child: hasAvatar
                  ? null
                  : Text(
                v.name.isNotEmpty ? v.name[0].toUpperCase() : '?',
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fullName,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.phone_outlined),
          title: Text(v.phone),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launch(context, Uri(scheme: 'tel', path: v.phone)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.email_outlined),
          title: Text(v.email),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launch(context, Uri(scheme: 'mailto', path: v.email)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => _launch(context, Uri(scheme: 'tel', path: v.phone)),
            icon: const Icon(Icons.call),
            label: const Text('Зателефонувати'),
          ),
        ),
      ],
    );
  }
}