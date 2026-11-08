import 'package:cargo_flow/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cargo_flow/providers/announcement_provider.dart';
import 'package:cargo_flow/widgets/auth_field.dart';
import 'package:cargo_flow/widgets/hero_banner.dart';
import 'package:cargo_flow/models/create_cargo.dart';
class CreateCargoScreen extends StatefulWidget {
  const CreateCargoScreen({super.key});

  @override
  State<CreateCargoScreen> createState() => _CreateCargoScreenState();
}

class _CreateCargoScreenState extends State<CreateCargoScreen> {
  static final _numbersOnly = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
  ];
  static const _decimal = TextInputType.numberWithOptions(decimal: true);

  final _formKey = GlobalKey<FormState>();

  final _fromCity = TextEditingController();
  final _toCity = TextEditingController();
  final _addressFrom = TextEditingController();
  final _addressTo = TextEditingController();
  final _distance = TextEditingController();
  final _dateFromText = TextEditingController();
  final _dateToText = TextEditingController();
  final _type = TextEditingController();
  final _height = TextEditingController();
  final _length = TextEditingController();
  final _width = TextEditingController();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _weight = TextEditingController();
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _isSubmitting = false;

  List<TextEditingController> get _all => [
    _fromCity, _toCity, _addressFrom, _addressTo, _distance,
    _dateFromText, _dateToText, _type, _height, _length, _width,
    _amount, _description,_weight
  ];

  @override
  void dispose() {
    for (final c in _all) {
      c.dispose();
    }
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)}.${d.year} ${two(d.hour)}:${two(d.minute)}';
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Обов’язкове поле' : null;

  String? _positive(String? v) {
    final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
    return (n == null || n <= 0) ? 'Введіть число' : null;
  }

  Future<void> _pickDateTime({required bool isFrom}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = isFrom ? _dateFrom : _dateTo;
    final initial = current ?? (isFrom ? now : (_dateFrom ?? now));

    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;

    final value =
    DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isFrom) {
        _dateFrom = value;
        _dateFromText.text = _fmt(value);
      } else {
        _dateTo = value;
        _dateToText.text = _fmt(value);
      }
    });
  }
  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_dateTo!.isAfter(_dateFrom!)) {
       AppSnack.info(context, "Доставка має бути пізніше за відправлення");
      return;
    }

    final cargo = CreateCargo(
      amount: _num(_amount)!,
      fromCity: _fromCity.text.trim(),
      toCity: _toCity.text.trim(),
      type: _type.text.trim(),
      distance: _num(_distance)!.round(),
      addressFrom: _addressFrom.text.trim(),
      addressTo: _addressTo.text.trim(),
      dateFrom: _dateFrom!,
      dateTo: _dateTo!,
      height: _num(_height)!,
      length: _num(_length)!,
      width: _num(_width)!,
      description: _description.text.trim(),
        weight:_num(_weight)!,
    );

    setState(() => _isSubmitting = true);
    try {
      await context.read<AnnouncementProvider>().createCargo(cargo);
      if (!mounted) return;
       AppSnack.success(context, "Оголошення успішно створено");
      await context.read<AnnouncementProvider>().fetchAnnouncements();
      dispose();
      context.go('/cargos');
    } catch (_) {
      if (mounted)   AppSnack.error(context, "Невдалось створити оголошення");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 12);
    const hgap = SizedBox(width: 8);

    return Scaffold(
      appBar: const HeroBanner.compact(
        text: 'Створити вантаж',
        additionalText: 'Вкажіть дані перевезення',
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionTitle('Маршрут'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthField(
                      controller: _fromCity,
                      hint: 'Звідки',
                      icon: Icons.trip_origin,
                      validator: _required,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  hgap,
                  Expanded(
                    child: AuthField(
                      controller: _toCity,
                      hint: 'Куди',
                      icon: Icons.location_on_outlined,
                      validator: _required,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthField(
                      controller: _addressFrom,
                      hint: 'Адреса відпр.',
                      icon: Icons.home_outlined,
                      validator: _required,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  hgap,
                  Expanded(
                    child: AuthField(
                      controller: _addressTo,
                      hint: 'Адреса дост.',
                      icon: Icons.pin_drop_outlined,
                      validator: _required,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              gap,
              Row(children: [
                Expanded(child:     AuthField(
                  controller: _distance,
                  hint: 'Відстань, км',
                  icon: Icons.route_outlined,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _positive,
                  textInputAction: TextInputAction.next,
                ),
                ),
            
                hgap,
               Expanded(child:  AuthField(
                 controller: _weight,
                 hint: 'Вага,кг',
                 icon: Icons.scale_outlined,
                 keyboardType: TextInputType.number,
                 inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                 validator: _positive,
                 textInputAction: TextInputAction.next,
               ),)
              ],),
              const _SectionTitle('Дата'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthField(
                      controller: _dateFromText,
                      hint: 'Відправлення',
                      icon: Icons.event_outlined,
                      readOnly: true,
                      onTap: () => _pickDateTime(isFrom: true),
                      validator: _required,
                    ),
                  ),
                  hgap,
                  Expanded(
                    child: AuthField(
                      controller: _dateToText,
                      hint: 'Доставка',
                      icon: Icons.event_available_outlined,
                      readOnly: true,
                      onTap: () => _pickDateTime(isFrom: false),
                      validator: _required,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionTitle('Інформація про вантаж'),
              AuthField(
                controller: _type,
                hint: 'Тип вантажу',
                icon: Icons.inventory_2_outlined,
                validator: _required,
                textInputAction: TextInputAction.next,
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthField(
                      controller: _height,
                      hint: 'Висота, м',
                      icon: Icons.height,
                      keyboardType: _decimal,
                      inputFormatters: _numbersOnly,
                      validator: _positive,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  hgap,
                  Expanded(
                    child: AuthField(
                      controller: _length,
                      hint: 'Довжина, м',
                      icon: Icons.straighten,
                      keyboardType: _decimal,
                      inputFormatters: _numbersOnly,
                      validator: _positive,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              gap,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AuthField(
                      controller: _width,
                      hint: 'Ширина, м',
                      icon: Icons.swap_horiz,
                      keyboardType: _decimal,
                      inputFormatters: _numbersOnly,
                      validator: _positive,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  hgap,
                  Expanded(
                    child: AuthField(
                      controller: _amount,
                      hint: 'Вартість, грн',
                      icon: Icons.payments_outlined,
                      keyboardType: _decimal,
                      inputFormatters: _numbersOnly,
                      validator: _positive,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                ],
              ),
              gap,
              AuthField(
                controller: _description,
                hint: 'Опис і побажання (необов’язково)',
                icon: Icons.notes_outlined,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Опублікувати вантаж'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
    ),
  );
}