import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cargo_flow/providers/announcement_provider.dart';
import 'package:cargo_flow/models/cargo_details.dart';
import 'package:cargo_flow/widgets/hero_banner.dart';
import 'package:cargo_flow/utils/config.dart';

class CargoDetailsScreen extends StatefulWidget {
  const CargoDetailsScreen({super.key, required this.id});

  final int id;

  @override
  State<CargoDetailsScreen> createState() => _CargoDetailsScreenState();
}

class _CargoDetailsScreenState extends State<CargoDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  Future<void> _refresh() {
    return context.read<AnnouncementProvider>().details(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();
    final CargoDetails? c = provider.cargoDetails;

    return Scaffold(
      appBar: HeroBanner.compact(
        text: c == null ? 'Вантаж' : c.type,
        additionalText: c == null ? null : '${c.fromCity} → ${c.toCity}',
        showBack: true,
        onBack: () => context.pop(),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (provider.isLoading && c == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (c == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: Text('Не вдалося завантажити дані')),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _CargoHeader(c: c),
                    const SizedBox(height: 16),
                    _Section(
                      title: 'Вантаж',
                      icon: Icons.inventory_2_outlined,
                      children: [
                        _InfoRow('Тип', c.type),
                        _InfoRow('Вага', '${_num(c.weight)} кг'),
                        _InfoRow('Об\'єм', '${_num(c.volume)} м³'),
                        _InfoRow(
                          'Габарити (Д×Ш×В)',
                          '${_num(c.length)} × ${_num(c.width)} × ${_num(c.height)} м',
                        ),
                      ],
                    ),
                    if (c.description != null &&
                        c.description!.trim().isNotEmpty)
                      _Section(
                        title: 'Опис',
                        icon: Icons.notes_outlined,
                        children: [
                          Text(
                            c.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    _Section(
                      title: 'Маршрут',
                      icon: Icons.route_outlined,
                      children: [_RouteBlock(c: c)],
                    ),
                    _Section(
                      title: 'Терміни',
                      icon: Icons.event_outlined,
                      children: [
                        _InfoRow('Завантаження', _dateTime(c.dateFrom)),
                        _InfoRow('Доставка до', _dateTime(c.dateTo)),
                        _InfoRow(
                          'Оголошення створено',
                          _dateTime(c.createDate),
                        ),
                      ],
                    ),
                    _Section(
                      title: 'Оплата',
                      icon: Icons.payments_outlined,
                      children: [_InfoRow('Сума', '${_num(c.amount)} ₴')],
                    ),
                    _Section(
                      title: 'Замовник',
                      icon: Icons.person_outline,
                      children: [_OwnerBlock(c: c)],
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

String _num(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1);

String _two(int n) => n.toString().padLeft(2, '0');

String _dateTime(DateTime d) =>
    '${_two(d.day)}.${_two(d.month)}.${d.year} ${_two(d.hour)}:${_two(d.minute)}';

class _CargoHeader extends StatelessWidget {
  const _CargoHeader({required this.c});
  final CargoDetails c;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: scheme.primary.withValues(alpha: 0.12),
                  child: Icon(Icons.inventory_2, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    c.type,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusChip(status: c.status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${c.fromCity} → ${c.toCity}',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${_num(c.amount)} ₴',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${_num(c.distance)} км • ${_num(c.weight)} кг',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = scheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteBlock extends StatelessWidget {
  const _RouteBlock({required this.c});
  final CargoDetails c;

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
                Text(
                  city,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (address != null && address.isNotEmpty)
                  Text(
                    address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        point(Icons.trip_origin, scheme.primary, c.fromCity, c.addressFrom),
        Padding(
          padding: const EdgeInsets.only(left: 9),
          child: Container(
            width: 2,
            height: 24,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: scheme.outlineVariant,
          ),
        ),
        point(Icons.location_on, scheme.error, c.toCity, c.addressTo),
        const Divider(height: 24),
        _InfoRow('Відстань', '${_num(c.distance)} км'),
      ],
    );
  }
}

class _OwnerBlock extends StatelessWidget {
  const _OwnerBlock({required this.c});
  final CargoDetails c;

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Не вдалося відкрити')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullName = '${c.name} ${c.lastName}'.trim();
    final hasAvatar = c.avatarUrl != null && c.avatarUrl!.isNotEmpty;

    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: hasAvatar
                  ? NetworkImage('$baseUrl${c.avatarUrl}')
                  : null,
              child: hasAvatar
                  ? null
                  : Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: theme.textTheme.titleLarge,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                fullName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.phone_outlined),
          title: Text(c.phone),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launch(context, Uri(scheme: 'tel', path: c.phone)),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          leading: const Icon(Icons.email_outlined),
          title: Text(c.email),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _launch(context, Uri(scheme: 'mailto', path: c.email)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () =>
                _launch(context, Uri(scheme: 'tel', path: c.phone)),
            icon: const Icon(Icons.call),
            label: const Text('Зателефонувати'),
          ),
        ),
      ],
    );
  }
}
