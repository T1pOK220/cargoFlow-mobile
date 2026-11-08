import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cargo_flow/widgets/auth_field.dart';
typedef DepositData = ({String account, double amount});

String formatAccount(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
  final buffer = StringBuffer();
  for (var i = 0; i < limited.length; i++) {
    if (i > 0 && i % 4 == 0) buffer.write('-');
    buffer.write(limited[i]);
  }
  return buffer.toString();
}

class _AccountNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = formatAccount(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class DepositDialog extends StatefulWidget {
  const DepositDialog({super.key,this.initialAccount});
  final String? initialAccount;

  @override
  State<DepositDialog> createState() => DepositDialogState();
}

class DepositDialogState extends State<DepositDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _account;
  final _amount = TextEditingController();

  @override
  void initState() {
    super.initState();
    _account = TextEditingController(
      text: formatAccount(widget.initialAccount ?? ''),
    );
  }

  @override
  void dispose() {
    _account.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop<DepositData>(context, (
    account: _account.text.trim(),
    amount: double.parse(_amount.text.trim().replaceAll(',', '.')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Поповнити рахунок'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AuthField(
              controller: _account,
              hint: 'Номер рахунку',
              icon: Icons.account_balance_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [_AccountNumberFormatter()],
              validator: (v) =>
              RegExp(r'^\d{4}-\d{4}-\d{4}-\d{4}$').hasMatch(v ?? '')
                  ? null
                  : 'Формат: 0000-0000-0000-0000',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            AuthField(
              controller: _amount,
              hint: 'Сума, грн',
              icon: Icons.payments_outlined,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              validator: (v) {
                final n =
                double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                return (n == null || n <= 0) ? 'Введіть суму' : null;
              },
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Поповнити'),
        ),
      ],
    );
  }
}