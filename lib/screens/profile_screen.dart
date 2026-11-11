import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cargo_flow/utils/config.dart';
import 'package:cargo_flow/models/user.dart';
import 'package:cargo_flow/providers/announcement_provider.dart';
import 'package:cargo_flow/providers/auth_provider.dart';
import 'package:cargo_flow/providers/payment_provider.dart';
import 'package:cargo_flow/providers/vehicle_provider.dart';
import 'package:cargo_flow/utils/format.dart';
import 'package:cargo_flow/widgets/auth_field.dart';
import 'package:cargo_flow/widgets/cargo_card.dart';
import 'package:cargo_flow/widgets/hero_banner.dart';
import 'package:cargo_flow/widgets/info_section.dart';
import 'package:cargo_flow/widgets/dialog_deposit.dart';
import 'package:cargo_flow/models/payment.dart';
import 'package:cargo_flow/theme/app_theme.dart';
import 'package:cargo_flow/widgets/app_snack_bar.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().getUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: HeroBanner.compact(
          text: 'Мій профіль',
          additionalText:
          user == null ? null : '${user.name} ${user.lastName}',
        ),
        body: user == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            _ProfileHeader(user: user),
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Мої вантажі'),
                Tab(text: 'Платежі'),
                Tab(text: 'Транспорт'),
                Tab(text: 'Налаштування'),
              ],
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _MyCargosTab(),
                  _PaymentsTab(),
                  _VehiclesTab(),
                  _SettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
            hasAvatar ? NetworkImage('$baseUrl${user.avatarUrl}') : null,
            child: hasAvatar
                ? null
                : Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name} ${user.lastName}'.trim(),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                _IconLine(Icons.phone_outlined, user.phone),
                _IconLine(Icons.email_outlined, user.email),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(children: [
        Icon(icon, size: 15, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
        ),
      ]),
    );
  }
}
class _MyCargosTab extends StatefulWidget {
  const _MyCargosTab();

  @override
  State<_MyCargosTab> createState() => _MyCargosTabState();
}

class _MyCargosTabState extends State<_MyCargosTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AnnouncementProvider>().announcementByUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AnnouncementProvider>();
    final items = p.announcementsByUser;

    if (p.isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: p.announcementByUser,
      child: items.isEmpty
          ? ListView(children: const [
        SizedBox(height: 120),
        Center(child: Text('Ви ще не створювали вантажів')),
      ])
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final a = items[i];
          return CargoCard(
            key: ValueKey(a.announcementId),
            from: a.fromCity,
            to: a.toCity,
            price: a.amount,
            date: a.createDate,
            type: a.type,
            distance: a.distance,
            onTap: () => context.push('/cargos/${a.announcementId}'),
          );
        },
      ),
    );
  }
}
class _PaymentsTab extends StatefulWidget {
  const _PaymentsTab();

  @override
  State<_PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<_PaymentsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted){context.read<PaymentProvider>().getPayments();
      context.read<PaymentProvider>().getBill();
      }

    });
  }

  Future<void> _deposit() async {
    final bill = context.read<PaymentProvider>().bill;

    final data = await showDialog<DepositData>(
      context: context,
      builder: (_) => DepositDialog(initialAccount: bill?.billNumber),
    );
    if (data == null || !mounted) return;

    try {
      await context.read<PaymentProvider>().deposit(data.account, data.amount);
      if (mounted) AppSnack.success(context, 'Рахунок поповнено');
    } catch (_) {
      if (mounted) AppSnack.error(context, 'Не вдалося поповнити рахунок');
    }
  }
  Future<void> _createBill() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _CreateBillDialog(),
    );
    if (result == null || !mounted) return;

    try {
      await context.read<PaymentProvider>().createBill(
        bill_title: result["bill_title"],
        bill_number: result['bill_number']!,
      );
      if (mounted) AppSnack.success(context, 'Рахунок створено');
    } catch (e, st) {
      debugPrint('createBill error: $e\n$st');
      if (mounted) AppSnack.error(context, 'Не вдалося створити рахунок');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<PaymentProvider>();

    if (p.isLoading && p.bill == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final bill = p.bill;

    return RefreshIndicator(
      onRefresh: () async {
        await p.getBill();
        await p.getPayments();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (bill != null)
            InfoSection(
              title: 'Рахунок',
              icon: Icons.account_balance_wallet_outlined,
              children: [
                InfoRow('Номер рахунку', bill.billNumber ?? '—'),
                InfoRow('Баланс', '${bill.balance} грн'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _deposit,
                    icon: const Icon(Icons.add_card),
                    label: const Text('Поповнити рахунок'),
                  ),
                ),
              ],
            )
          else
            InfoSection(
              title: 'Рахунок',
              icon: Icons.account_balance_wallet_outlined,
              children: [
                const Text('У вас ще немає рахунку'),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _createBill,
                    icon: const Icon(Icons.add),
                    label: const Text('Створити рахунок'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          InfoSection(
            title: 'Історія платежів',
            icon: Icons.receipt_long_outlined,
            children: p.payments.isEmpty
                ? const [Text('Платежів поки немає')]
                : [for (final pay in p.payments) _PaymentTile(pay)],
          ),
        ],
      ),
    );
  }
}
class _CreateBillDialog extends StatefulWidget {
  const _CreateBillDialog({super.key});

  @override
  State<_CreateBillDialog> createState() => _CreateBillDialogState();
}

class _CreateBillDialogState extends State<_CreateBillDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _number = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _number.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'bill_title': _name.text.trim(),
      'bill_number': _number.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Новий рахунок'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Назва',
                hintText: 'Наприклад, Основний',
              ),
              validator: (v) {
                if (v == null || v.trim().length < 2) {
                  return 'Введіть назву (мінімум 2 символи)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _number,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Номер рахунку',
                hintText: 'хххх-хххх-хххх-хххх',
              ),
              validator: (v) {
                final ok = RegExp(r'^\d{4} \d{4} \d{4} \d{4}$')
                    .hasMatch(v ?? '');
                return ok ? null : 'Формат: хххх хххх хххх хххх';
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Створити'),
        ),
      ],
    );
  }
}
class _PaymentTile extends StatelessWidget {
  const _PaymentTile(this.p);

  final Payment p;

  @override
  Widget build(BuildContext context) {
    final amount = double.parse(p.amount);

    final income = amount >= 0;

    final color = income ? AppTheme.green : AppTheme.red;

    final sign = income ? '+' : '−';

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,

      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          income ? Icons.south_west : Icons.north_east,
          size: 18,
          color: color,
        ),
      ),

      title: Text(
        p.type,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),

      subtitle: Text(formatDate(p.payDate)),

      trailing: Text(
        '$sign${formatPrice(amount.abs())} ₴',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _VehiclesTab extends StatefulWidget {
  const _VehiclesTab();

  @override
  State<_VehiclesTab> createState() => _VehiclesTabState();
}

class _VehiclesTabState extends State<_VehiclesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<VehicleProvider>().getMyVehicles();
    });
  }

  Future<void> _delete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити автомобіль?'),
        content: const Text('Цю дію не можна скасувати.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Скасувати')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Видалити')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<VehicleProvider>().deleteVehicle(id);
    } catch (_) {
      if (mounted) AppSnack.error(context, 'Не вдалося видалити автомобіль');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<VehicleProvider>();
    final items = p.myVehicles;
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: p.getMyVehicles,
          child: items.isEmpty
              ? Center(
            child: Text(
              'У вас ще немає автомобілів',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                letterSpacing: 0.3,
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final v = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                color: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE4E7EB)),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.push('/vehicles/${v.vehicleId}'),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.local_shipping_outlined,
                                color: AppTheme.orange,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${v.brand} ${v.model}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.dark,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: v.avatarUrl != null && v.avatarUrl!.isNotEmpty
                              ? Image.network(
                            '$baseUrl${v.avatarUrl}',
                            width: double.infinity,
                            height: 170,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _imagePlaceholder(),
                          )
                              : _imagePlaceholder(),
                        ),

                        const SizedBox(height: 14),
                        InfoRow('Номерний знак', v.plateNumber),
                        InfoRow('Тип транспорту', v.type),
                        InfoRow('Вантажопідйомність', '${v.capacity ?? '—'} т'),
                        InfoRow('Статус', v.status.dbValue),

                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFE4E7EB)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  context.push('/vehicles/edit',extra: v),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Редагувати'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.orange,
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton.icon(
                              onPressed: () => _delete(v.vehicleId),
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Видалити'),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: FilledButton.icon(
            onPressed: () => context.push('/vehicle/add'),
            icon: const Icon(Icons.add),
            label: const Text('Додати автомобіль'),
          ),
        ),
      ],
    );
  }
}
Widget _imagePlaceholder() {
  return Container(
    width: double.infinity,
    height: 170,
    color: AppTheme.background,
    child: const Icon(
      Icons.image_not_supported_outlined,
      size: 42,
      color: AppTheme.textSecondary,
    ),
  );
}
class _SettingsTab extends StatefulWidget {
  const _SettingsTab();

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  final _profileKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _repeatPassword = TextEditingController();

  bool _showPasswords = false;
  bool _savingProfile = false;
  bool _savingPassword = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().user!;
    _name = TextEditingController(text: u.name);
    _lastName = TextEditingController(text: u.lastName);
    _email = TextEditingController(text: u.email);
    _phone = TextEditingController(text: u.phone);
  }

  @override
  void dispose() {
    for (final c in [
      _name, _lastName, _email, _phone, _oldPassword, _newPassword, _repeatPassword,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Обов’язкове поле' : null;

  String? _emailRule(String? v) {
    if (_required(v) != null) return 'Обов’язкове поле';
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v!.trim())
        ? null
        : 'Некоректний email';
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (!_profileKey.currentState!.validate()) return;
    setState(() => _savingProfile = true);
    try {
      await context.read<AuthProvider>().updateProfile(
        name:_name.text.trim(),
        lastName:_lastName.text.trim(),
        email:_email.text.trim(),
        phone:_phone.text.trim(),
      );
      if (mounted) AppSnack.success(context, 'Дані збережено');
    } catch (_) {
      if (mounted) AppSnack.error(context, 'Не вдалося зберегти дані');
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }
  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();
    if (!_passwordKey.currentState!.validate()) return;
    setState(() => _savingPassword = true);
    try {
      await context.read<AuthProvider>().changePassword(
        _oldPassword.text,
        _newPassword.text,
      );
      _oldPassword.clear();
      _newPassword.clear();
      _repeatPassword.clear();
      if (mounted) AppSnack.success(context, 'Пароль змінено');
    } catch (_) {
      if (mounted) AppSnack.error(context, 'Не вдалося змінити пароль');
    } finally {
      if (mounted) setState(() => _savingPassword = false);
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logOut();
    if (mounted) context.go('/login');
  }

  Future<void> _deleteAccount() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Видалити профіль?'),
        content: const Text('Усі ваші дані буде втрачено. Цю дію не можна скасувати.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Скасувати')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Видалити')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await context.read<AuthProvider>().deleteAccount();
      if (mounted) context.go('/login');
    } catch (_) {
      if (mounted) AppSnack.error(context, 'Не вдалося видалити профіль');
    }
  }

  Widget get _visibilityToggle => IconButton(
    icon: Icon(_showPasswords
        ? Icons.visibility_outlined
        : Icons.visibility_off_outlined),
    onPressed: () => setState(() => _showPasswords = !_showPasswords),
  );

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 12);
    return ListView(
      padding: const EdgeInsets.all(16),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        InfoSection(
          title: 'Персональні дані',
          icon: Icons.person_outline,
          children: [
            Form(
              key: _profileKey,
              child: Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AuthField(
                        controller: _name,
                        hint: 'Ім’я',
                        icon: Icons.person_outline,
                        validator: _required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AuthField(
                        controller: _lastName,
                        hint: 'Прізвище',
                        icon: Icons.badge_outlined,
                        validator: _required,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
                gap,
                AuthField(
                  controller: _email,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _emailRule,
                  textInputAction: TextInputAction.next,
                ),
                gap,
                AuthField(
                  controller: _phone,
                  hint: 'Номер телефону',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _required,
                ),
                gap,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _savingProfile ? null : _saveProfile,
                    child: _savingProfile
                        ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.white))
                        : const Text('Зберегти'),
                  ),
                ),
              ]),
            ),
          ],
        ),
        InfoSection(
          title: 'Зміна пароля',
          icon: Icons.lock_outline,
          children: [
            Form(
              key: _passwordKey,
              child: Column(children: [
                AuthField(
                  controller: _oldPassword,
                  hint: 'Поточний пароль',
                  icon: Icons.lock_outline,
                  obscureText: !_showPasswords,
                  suffix: _visibilityToggle,
                  validator: _required,
                  textInputAction: TextInputAction.next,
                ),
                gap,
                AuthField(
                  controller: _newPassword,
                  hint: 'Новий пароль',
                  icon: Icons.lock_reset_outlined,
                  obscureText: !_showPasswords,
                  validator: (v) =>
                  (v == null || v.length < 6) ? 'Мінімум 6 символів' : null,
                  textInputAction: TextInputAction.next,
                ),
                gap,
                AuthField(
                  controller: _repeatPassword,
                  hint: 'Повторіть новий пароль',
                  icon: Icons.lock_reset_outlined,
                  obscureText: !_showPasswords,
                  validator: (v) =>
                  v != _newPassword.text ? 'Паролі не збігаються' : null,
                  onSubmitted: (_) => _changePassword(),
                ),
                gap,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _savingPassword ? null : _changePassword,
                    child: _savingPassword
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.white,
                      ),
                    )
                        : const Text('Змінити пароль'),
                  ),
                )
              ]),
            ),
          ],
        ),
        OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Вийти'),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: _deleteAccount,
          style: TextButton.styleFrom(foregroundColor: AppTheme.red),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Видалити профіль'),
        ),
      ],
    );
  }
}
