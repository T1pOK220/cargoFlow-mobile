import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cargo_flow/models/cargo_filter.dart';
import 'package:cargo_flow/providers/announcement_provider.dart';
import 'package:cargo_flow/widgets/auth_field.dart';
import 'package:cargo_flow/widgets/cargo_card.dart';
import 'package:cargo_flow/widgets/hero_banner.dart';

class CargosScreen extends StatefulWidget {
  const CargosScreen({super.key});

  @override
  State<CargosScreen> createState() => _CargosScreenState();
}

class _CargosScreenState extends State<CargosScreen> {
  static final _numbersOnly = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
  ];
  static const _decimal = TextInputType.numberWithOptions(decimal: true);

  final _fromCity = TextEditingController();
  final _toCity = TextEditingController();
  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  final _weight = TextEditingController();

  List<TextEditingController> get _all => [
    _fromCity,
    _toCity,
    _minPrice,
    _maxPrice,
    _weight,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnnouncementProvider>().fetchAnnouncements();
    });
  }

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  bool get _hasFilters => _all.any((c) => c.text.trim().isNotEmpty);

  CargoFilter _currentFilter() => CargoFilter(
    fromCity: _fromCity.text.trim(),
    toCity: _toCity.text.trim(),
    amountFrom: _num(_minPrice),
    amountTo: _num(_maxPrice),
    weight: _num(_weight),
  );

  void _applyFilters() {
    FocusScope.of(context).unfocus();
    context.read<AnnouncementProvider>().filterAnnouncements(_currentFilter());
  }

  void _resetFilters() {
    FocusScope.of(context).unfocus();
    for (final c in _all) {
      c.clear();
    }
    context.read<AnnouncementProvider>().fetchAnnouncements();
  }

  Future<void> _refresh() async {
    final provider = context.read<AnnouncementProvider>();
    if (_hasFilters) {
      await provider.filterAnnouncements(_currentFilter());
    } else {
      await provider.fetchAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnnouncementProvider>();

    return Scaffold(
      appBar: HeroBanner.compact(
        text: 'Вантажі',
        additionalText: provider.isLoading
            ? null
            : '${provider.announcements.length} оголошень',
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildFilters()),
            ..._buildList(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const gap = SizedBox(height: 12);
    const hgap = SizedBox(width: 8);

    return ExpansionTile(
      leading: const Icon(Icons.filter_list),
      title: const Text(
        'Фільтри',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      initiallyExpanded: false,
      maintainState: true,
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      children: [
        Row(
          children: [
            Expanded(
              child: AuthField(
                controller: _fromCity,
                hint: 'Звідки',
                icon: Icons.trip_origin,
                textInputAction: TextInputAction.next,
              ),
            ),
            hgap,
            Expanded(
              child: AuthField(
                controller: _toCity,
                hint: 'Куди',
                icon: Icons.location_on_outlined,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        gap,
        Row(
          children: [
            Expanded(
              child: AuthField(
                controller: _minPrice,
                hint: 'Від, грн',
                icon: Icons.payments_outlined,
                keyboardType: _decimal,
                inputFormatters: _numbersOnly,
                textInputAction: TextInputAction.next,
              ),
            ),
            hgap,
            Expanded(
              child: AuthField(
                controller: _maxPrice,
                hint: 'До, грн',
                icon: Icons.payments_outlined,
                keyboardType: _decimal,
                inputFormatters: _numbersOnly,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        gap,
        AuthField(
          controller: _weight,
          hint: 'Вага, кг',
          icon: Icons.scale_outlined,
          keyboardType: _decimal,
          inputFormatters: _numbersOnly,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _applyFilters(),
        ),
        gap,
        Row(
          children: [
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _applyFilters,
                child: const Text('Знайти'),
              ),
            ),
            hgap,
            Expanded(
              child: OutlinedButton(
                onPressed: _resetFilters,
                child: const Text('Скинути'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildList(AnnouncementProvider provider) {
    final items = provider.announcements;

    if (provider.isLoading && items.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              _hasFilters
                  ? 'За вашими фільтрами нічого не знайдено'
                  : 'Оголошень поки немає',
            ),
          ),
        ),
      ];
    }

    return [
      if (provider.isLoading)
        const SliverToBoxAdapter(child: LinearProgressIndicator(minHeight: 2)),
      SliverPadding(
        padding: const EdgeInsets.all(12),
        sliver: SliverList.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final a = items[index];
            return CargoCard(
              key: ValueKey(a.announcementId),
              from: a.fromCity,
              to: a.toCity,
              price: _formatPrice(a.amount),
              date: a.createDate,
              type: a.type,
              distance: a.distance,
              onTap: () => context.push('/cargos/info/${a.announcementId}'),
            );
          },
        ),
      ),
    ];
  }
}

String _formatPrice(Object amount) {
  final v = double.tryParse(amount.toString());
  if (v == null) return amount.toString();
  return v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
}

// String _formatDate(Object value) {
//   final d = DateTime.tryParse(value.toString())?.toLocal();
//   if (d == null) return value.toString();
//   String two(int n) => n.toString().padLeft(2, '0');
//   return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
// }
