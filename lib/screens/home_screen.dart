import 'package:cargo_flow/providers/auth_provider.dart';
import 'package:cargo_flow/utils/format.dart';
import 'package:cargo_flow/widgets/cargo_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/announcement_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onCreateCargo,
    this.onFindTransport,
    this.onSeeAll,
  });

  final VoidCallback? onCreateCargo;
  final VoidCallback? onFindTransport;
  final VoidCallback? onSeeAll;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _bannerHeight = 200;
  static const int _maxItems = 5;

  @override
  void initState() {
    super.initState();
    // Завантаження стартує одразу при створенні екрана. Викликаємо після
    // першого кадру, бо notifyListeners() під час build кидає помилку.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AnnouncementProvider>().fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final announcementProvider = context.watch<AnnouncementProvider>();
    final items = announcementProvider.announcements.take(_maxItems).toList();
    final userName = auth.user?.name;

    return Scaffold(
      backgroundColor: AppTheme.background,
      // Column замість Stack + Positioned: список починається рівно там,
      // де реально закінчується шапка, і не налазить на неї.
      body: Column(
        children: [
          HeroBanner(
            text: 'Головна',
            additionalText: userName != null
                ? 'Вітаємо, $userName'
                : 'Вітаємо',
            height: _bannerHeight,
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.orange,
              onRefresh: announcementProvider.fetchAnnouncements,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.add_rounded,
                            title: 'Створити вантаж',
                            subtitle: 'Нове оголошення',
                            filled: true,
                            onTap:
                            widget.onCreateCargo ??
                                    () => context.go('/cargo/create'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionTile(
                            icon: Icons.search_rounded,
                            title: 'Знайти транспорт',
                            subtitle: 'Підібрати авто',
                            filled: false,
                            onTap:
                            widget.onFindTransport ??
                                    () => context.go('/vehicles'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Вантажі',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontSize: 16),
                        ),
                        TextButton(
                          onPressed:
                          widget.onSeeAll ?? () => context.go('/cargos'),
                          child: const Text('Усі'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (items.isEmpty)
                      const _EmptyState()
                    else
                      for (final a in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: CargoCard(
                            key: ValueKey(a.announcementId),
                            from: a.fromCity,
                            to: a.toCity,
                            price: formatPrice(a.amount),
                            date: a.createDate,
                            type: a.type,
                            distance: a.distance,
                            onTap: () => context.push(
                              '/cargos/info/${a.announcementId}',
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 36,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'Поки що немає вантажів',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.filled,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? AppTheme.textOnPrimary : AppTheme.dark;
    final sub = filled
        ? AppTheme.textOnPrimary.withValues(alpha: 0.85)
        : AppTheme.textSecondary;

    return Material(
      color: filled ? AppTheme.orange : AppTheme.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: filled
              ? null
              : BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.inputBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: filled
                      ? AppTheme.white.withValues(alpha: 0.2)
                      : AppTheme.orange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: filled ? AppTheme.white : AppTheme.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: sub),
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