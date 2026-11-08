import 'dart:typed_data';
import 'package:cargo_flow/models/vehicle_create.dart';
import 'package:cargo_flow/providers/vehicle_provider.dart';
import 'package:cargo_flow/theme/app_theme.dart';
import 'package:cargo_flow/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class VehicleCreateScreen extends StatefulWidget {
  const VehicleCreateScreen({super.key});

  @override
  State<VehicleCreateScreen> createState() => _VehicleCreateScreenState();
}

class _VehicleCreateScreenState extends State<VehicleCreateScreen> {
  static const _types = [
    'Вантажівка',
    'Фургон',
    'Рефрижератор',
    'Тягач',
    'Бус',
  ];
  static const _statuses = [
    'Доступний',
    'Зайнятий',
    'На обслуговуванні',
  ];

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _plate = TextEditingController();
  final _capacity = TextEditingController();
  final _volume = TextEditingController();
  final _fromCity = TextEditingController();
  final _toCity = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();

  String _type = _types.first;
  String _status = _statuses.first;
  XFile? _image;
  Uint8List? _imageBytes;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [
      _brand,
      _model,
      _year,
      _plate,
      _capacity,
      _volume,
      _fromCity,
      _toCity,
      _price,
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
      _image = picked;
      _imageBytes = bytes;
    });
  }

  double? _parseDouble(String s) =>
      double.tryParse(s.trim().replaceAll(',', '.'));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = VehicleCreate(
      brand: _brand.text.trim(),
      model: _model.text.trim(),
      typeOfVehicle: _type,
      year: int.parse(_year.text.trim()),
      capacity: _parseDouble(_capacity.text)!,
      volume: _parseDouble(_volume.text)!,
      status: _status,
      plateNumber: _plate.text.trim().toUpperCase(),
      description: _description.text.trim(),
      deliveryPrice: int.parse(_price.text.trim()),
      fromCity: _fromCity.text.trim(),
      toCity: _toCity.text.trim(),
      file: _image,
    );

    setState(() => _loading = true);
    try {
      await context.read<VehicleProvider>().createVehicle(data);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        AppSnack.error(context, "Не вдалося створити транспорт");
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Обов\'язкове поле' : null;

  String? _positiveNumber(String? v) {
    final n = _parseDouble(v ?? '');
    return (n == null || n <= 0) ? 'Введіть число' : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Додати транспорт')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: 'Фото',
                children: [_buildImagePicker()],
              ),
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
                  _dropdown(
                    value: _type,
                    items: _types,
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
                          validator: (v) {
                            final y = int.tryParse(v ?? '');
                            final max = DateTime.now().year + 1;
                            return (y == null || y < 1950 || y > max)
                                ? 'Некоректний рік'
                                : null;
                          },
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
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                          validator: _positiveNumber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _field(
                          controller: _volume,
                          hint: 'Об\'єм, м³',
                          icon: Icons.inventory_2_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [_decimalFormatter],
                          validator: _positiveNumber,
                        ),
                      ),
                    ],
                  ),
                  _dropdown(
                    value: _status,
                    items: _statuses,
                    icon: Icons.flag_outlined,
                    hint: 'Статус',
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Section(
                title: 'Маршрут і ціна',
                children: [
                  _field(
                    controller: _fromCity,
                    hint: 'Місто відправлення',
                    icon: Icons.trip_origin,
                    validator: _required,
                    textCapitalization: TextCapitalization.words,
                  ),
                  _field(
                    controller: _toCity,
                    hint: 'Місто призначення',
                    icon: Icons.location_on_outlined,
                    validator: _required,
                    textCapitalization: TextCapitalization.words,
                  ),
                  _field(
                    controller: _price,
                    hint: 'Ціна доставки, грн',
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      return (n == null || n <= 0) ? 'Введіть суму' : null;
                    },
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
                    : const Text('Створити'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
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
        child: _imageBytes == null
            ? const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined,
                size: 36, color: AppTheme.inputIcon),
            SizedBox(height: 8),
            Text(
              'Додати фото',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        )
            : Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(_imageBytes!, fit: BoxFit.cover),
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: AppTheme.dark.withValues(alpha: 0.7),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: AppTheme.white, size: 20),
                  onPressed: () => setState(() {
                    _image = null;
                    _imageBytes = null;
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final _decimalFormatter =
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

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
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        // ignore: deprecated_member_use
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
        ),
        items: [
          for (final i in items) DropdownMenuItem(value: i, child: Text(i)),
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