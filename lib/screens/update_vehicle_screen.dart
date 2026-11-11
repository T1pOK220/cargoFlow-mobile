import 'dart:typed_data';

import 'package:cargo_flow/models/vehicle.dart';
import 'package:cargo_flow/models/vehicle_status.dart';
import 'package:cargo_flow/models/vehicle_update.dart';
import 'package:cargo_flow/providers/vehicle_provider.dart';
import 'package:cargo_flow/theme/app_theme.dart';
import 'package:cargo_flow/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cargo_flow/utils/config.dart';

/// Базова адреса сервера для відображення поточного фото.
/// Замініть на вашу змінну/константу baseUrl.

/// Екран редагування транспорту.
///
/// Приймає поточний [Vehicle], щоб заповнити форму, і відправляє зміни через
/// [VehicleProvider.updateVehicle]. Після успіху закривається з `true`.
class VehicleEditScreen extends StatefulWidget {
  const VehicleEditScreen({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<VehicleEditScreen> createState() => _VehicleEditScreenState();
}

class _VehicleEditScreenState extends State<VehicleEditScreen> {
  static const _baseTypes = [
    'Вантажівка',
    'Фургон',
    'Рефрижератор',
    'Тягач',
    'Бус',
  ];

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _brand;
  late final TextEditingController _model;
  late final TextEditingController _year;
  late final TextEditingController _plate;
  late final TextEditingController _capacity;
  late final TextEditingController _volume;
  late final TextEditingController _description;

  late final List<String> _types;
  late String _type;
  late VehicleStatus _status;
  bool _loading = false;

  final _picker = ImagePicker();
  XFile? _newImage; // нове фото (null, якщо не змінювали)
  Uint8List? _newImageBytes; // для прев'ю

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;

    _brand = TextEditingController(text: v.brand);
    _model = TextEditingController(text: v.model);
    _year = TextEditingController(text: v.year?.toString() ?? '');
    _plate = TextEditingController(text: v.plateNumber);
    _capacity = TextEditingController(text: _fmt(v.capacity));
    _volume = TextEditingController(text: _fmt(v.cargoVolume));
    _description = TextEditingController(text: v.description ?? '');

    // Якщо поточного типу немає у стандартному списку, додаємо його,
    // щоб dropdown не падав.
    _types = {..._baseTypes, if (v.type.isNotEmpty) v.type}.toList();
    _type = v.type.isNotEmpty ? v.type : _types.first;

    _status = VehicleStatus.values.firstWhere(
      (s) => s.dbValue == v.status,
      orElse: () => VehicleStatus.values.first,
    );
  }

  @override
  void dispose() {
    for (final c in [
      _brand,
      _model,
      _year,
      _plate,
      _capacity,
      _volume,
      _description,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _newImage = picked;
      _newImageBytes = bytes;
    });
  }

  String _fmt(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.toInt().toString() : v.toString();
  }

  double? _parseDouble(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final description = _description.text.trim();

    final data = VehicleUpdate(
      id: widget.vehicle.vehicleId,
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      plateNumber: _plate.text.trim().toUpperCase(),
      capacity: _parseDouble(_capacity.text),
      type: _type,
      year: int.tryParse(_year.text.trim()),
      cargoVolume: _parseDouble(_volume.text),
      status: _status,
      description: description.isEmpty ? null : description,
      avatarUrl: widget.vehicle.avatarUrl,
      file: _newImage,
    );

    setState(() => _loading = true);
    try {
      await context.read<VehicleProvider>().updateVehicle(data);
      AppSnack.error(context, "Зміни збережено");
      if (mounted) Navigator.of(context).pop(true);
      await context.read<VehicleProvider>().getMyVehicles();
    } catch (e) {
      if (mounted) {
        AppSnack.error(context, "Не вдалося зберегти зміни");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Обов\'язкове поле' : null;

  String? _optionalPositiveNumber(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = _parseDouble(v);
    return (n == null || n <= 0) ? 'Введіть число' : null;
  }

  String? _optionalYear(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final y = int.tryParse(v);
    final max = DateTime.now().year + 1;
    return (y == null || y < 1950 || y > max) ? 'Некоректний рік' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редагувати транспорт')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(title: 'Фото', children: [_buildImagePicker()]),
              const SizedBox(height: 16),
              _Section(
                title: 'Основна інформація',
                children: [
                  _field(
                    controller: _brand,
                    hint: 'Марка',
                    icon: Icons.local_shipping_outlined,
                    validator: _required,
                    textCapitalization: TextCapitalization.words,
                  ),
                  _field(
                    controller: _model,
                    hint: 'Модель',
                    icon: Icons.directions_car_outlined,
                    validator: _required,
                  ),
                  _dropdown<String>(
                    value: _type,
                    items: _types,
                    label: (t) => t,
                    icon: Icons.category_outlined,
                    hint: 'Тип транспорту',
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _field(
                          controller: _year,
                          hint: 'Рік',
                          icon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          validator: _optionalYear,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: _field(
                          controller: _plate,
                          hint: 'Номерний знак',
                          icon: Icons.pin_outlined,
                          validator: _required,
                          textCapitalization: TextCapitalization.characters,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Характеристики',
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _field(
                          controller: _capacity,
                          hint: 'Вантажопідйомність',
                          icon: Icons.scale_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [_decimalFormatter],
                          validator: _optionalPositiveNumber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          controller: _volume,
                          hint: 'Об\'єм, м³',
                          icon: Icons.inventory_2_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [_decimalFormatter],
                          validator: _optionalPositiveNumber,
                        ),
                      ),
                    ],
                  ),
                  _dropdown<VehicleStatus>(
                    value: _status,
                    items: VehicleStatus.values,
                    label: (s) => s.dbValue,
                    icon: Icons.flag_outlined,
                    hint: 'Статус',
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Опис',
                children: [
                  _field(
                    controller: _description,
                    hint: 'Короткий опис',
                    icon: Icons.notes_outlined,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.white,
                        ),
                      )
                    : const Text('Зберегти'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final currentUrl = widget.vehicle.avatarUrl;

    final Widget content;
    if (_newImageBytes != null) {
      content = Image.memory(_newImageBytes!, fit: BoxFit.cover);
    } else if (currentUrl != null && currentUrl.isNotEmpty) {
      content = Image.network(
        '$baseUrl$currentUrl',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _photoPlaceholder(),
      );
    } else {
      content = _photoPlaceholder();
    }

    return InkWell(
      onTap: _loading ? null : _pickImage,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.backgroundAuth,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.inputBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            content,
            Positioned(
              bottom: 8,
              right: 8,
              child: _roundButton(Icons.edit_outlined, _pickImage),
            ),
            if (_newImageBytes != null)
              Positioned(
                top: 8,
                right: 8,
                child: _roundButton(
                  Icons.close,
                  () => setState(() {
                    _newImage = null;
                    _newImageBytes = null;
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _photoPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 36, color: AppTheme.inputIcon),
        SizedBox(height: 8),
        Text('Додати фото', style: TextStyle(color: AppTheme.textSecondary)),
      ],
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: AppTheme.dark.withValues(alpha: 0.7),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.white, size: 20),
        onPressed: _loading ? null : onPressed,
      ),
    );
  }

  static final _decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9.,]'),
  );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.next,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
      ),
    );
  }

  Widget _dropdown<T>({
    required T value,
    required List<T> items,
    required String Function(T) label,
    required IconData icon,
    required String hint,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        // ignore: deprecated_member_use
        value: value,
        isExpanded: true,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
        items: [
          for (final i in items)
            DropdownMenuItem<T>(value: i, child: Text(label(i))),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
