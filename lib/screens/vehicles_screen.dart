import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cargo_flow/models/vehicles_filter.dart';
import 'package:cargo_flow/providers/vehicle_provider.dart';
import 'package:cargo_flow/theme/app_theme.dart';
import 'package:cargo_flow/widgets/hero_banner.dart';
import 'package:cargo_flow/widgets/vehicle_card.dart';

class _Range {
  const _Range(this.label, this.from, this.to);
  final String label;
  final double? from;
  final double? to;
}
const _capacityRanges = [
  _Range('1–3 т', 1, 3),
  _Range('3–5 т', 3, 5),
  _Range('5–10 т', 5, 10),
  _Range('10+ т', 10, null),
];

const _volumeRanges = [
  _Range('10–20 м³', 10, 20),
  _Range('20–40 м³', 20, 40),
  _Range('40–60 м³', 40, 60),
  _Range('60+ м³', 60, null),
];
List<String> types = [];
class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  String? _type;
  _Range? _capacity;
  _Range? _volume;

  int get _activeCount =>
      [_type, _capacity, _volume].where((e) => e != null).length;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final provider = context.read<VehicleProvider>();

      await provider.fetchVehicles();

      if (!mounted) return;

      setState(() {
        types = provider.types;
      });
    });
  }

  VehicleFilter _currentFilter() => VehicleFilter(
    type: _type,
    capacityFrom: _capacity?.from,
    capacityTo: _capacity?.to,
    volumeFrom: _volume?.from,
    volumeTo: _volume?.to,
  );

  void _apply() =>
      context.read<VehicleProvider>().filterVehicles(_currentFilter());

  void _selectType(String value) {
    setState(() => _type = _type == value ? null : value);
    _apply();
  }

  void _selectCapacity(_Range value) {
    setState(() => _capacity = _capacity == value ? null : value);
    _apply();
  }

  void _selectVolume(_Range value) {
    setState(() => _volume = _volume == value ? null : value);
    _apply();
  }

  void _reset() {
    setState(() {
      _type = null;
      _capacity = null;
      _volume = null;
    });
    _apply();
  }

  Future<void> _refresh() =>
      context.read<VehicleProvider>().filterVehicles(_currentFilter());

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      appBar: HeroBanner.compact(
        text: 'Транспорт',
        additionalText: provider.isLoading
            ? null
            : 'Знайдено: ${provider.vehicles.length}',
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
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
    return ExpansionTile(
      leading: const Icon(Icons.filter_list),
      title: Text(
        _activeCount == 0 ? 'Фільтри' : 'Фільтри ($_activeCount)',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      maintainState: true,
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Тип транспорту'),
        _chips<String>(
          items: types,
          label: (t) => t,
          selected: _type,
          onTap: _selectType,
        ),
        const _SectionTitle('Вантажопідйомність'),
        _chips<_Range>(
          items: _capacityRanges,
          label: (r) => r.label,
          selected: _capacity,
          onTap: _selectCapacity,
        ),
        const _SectionTitle('Об’єм кузова'),
        _chips<_Range>(
          items: _volumeRanges,
          label: (r) => r.label,
          selected: _volume,
          onTap: _selectVolume,
        ),
        if (_activeCount > 0)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Скинути'),
            ),
          ),
      ],
    );
  }

  Widget _chips<T>({
    required List<T> items,
    required String Function(T) label,
    required T? selected,
    required ValueChanged<T> onTap,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        for (final item in items)
          ChoiceChip(
            label: Text(label(item)),
            selected: item == selected,
            showCheckmark: false,
            selectedColor: AppTheme.orange,
            labelStyle: TextStyle(
              color: item == selected ? Colors.white : null,
              fontWeight: FontWeight.w500,
            ),
            onSelected: (_) => onTap(item),
          ),
      ],
    );
  }

  List<Widget> _buildList(VehicleProvider provider) {
    final items = provider.vehicles;

    if (provider.isLoading && items.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (provider.error != null && items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(provider.error!),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _apply,
                  child: const Text('Спробувати ще'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    if (items.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text(
              _activeCount > 0
                  ? 'За вашими фільтрами нічого не знайдено'
                  : 'Транспорту поки немає',
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
            final v = items[index];
            return VehicleCard(
              vehicle: v,
              onTap: () => context.push('/vehicles/${v.vehicleId}'),
            );
          },
        ),
      ),
    ];
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  );
}