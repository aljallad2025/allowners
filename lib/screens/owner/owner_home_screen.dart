import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/session_provider.dart';
import '../../services/owner_service.dart';
import 'owner_bookings_screen.dart';
import 'owner_maintenance_screen.dart';
import 'owner_revenue_screen.dart';
import 'owner_documents_screen.dart';
import 'owner_decisions_screen.dart';
import 'owner_community_screen.dart';
import 'owner_marketplace_screen.dart';
import 'owner_messages_screen.dart';

class OwnerHomeScreen extends ConsumerStatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  ConsumerState<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends ConsumerState<OwnerHomeScreen> {
  final _service = OwnerService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getDashboard();
  }

  void _reload() => setState(() => _future = _service.getDashboard());

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider).user;

    final quickLinks = [
      (
        icon: Icons.calendar_month_outlined,
        title: AppStrings.t(isArabic, 'owner_bookings'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerBookingsScreen())),
      ),
      (
        icon: Icons.bar_chart_outlined,
        title: AppStrings.t(isArabic, 'financial_reports'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerRevenueScreen())),
      ),
      (
        icon: Icons.build_outlined,
        title: AppStrings.t(isArabic, 'maintenance_requests'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerMaintenanceScreen())),
      ),
      (
        icon: Icons.folder_outlined,
        title: AppStrings.t(isArabic, 'contracts_docs'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerDocumentsScreen())),
      ),
      (
        icon: Icons.how_to_vote_outlined,
        title: AppStrings.t(isArabic, 'voting_decisions'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerDecisionsScreen())),
      ),
      (
        icon: Icons.groups_outlined,
        title: AppStrings.t(isArabic, 'owners_community'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerCommunityScreen())),
      ),
      (
        icon: Icons.storefront_outlined,
        title: AppStrings.t(isArabic, 'units_marketplace'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerMarketplaceScreen())),
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        title: AppStrings.t(isArabic, 'messages'),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerMessagesScreen())),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimens.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.t(isArabic, 'hello'),
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                Text(user?.fullName ?? '', style: textTheme.headlineMedium),
                const SizedBox(height: AppDimens.lg),

                FutureBuilder<Map<String, dynamic>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppDimens.xl),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return _ErrorRetry(isArabic: isArabic, onRetry: _reload);
                    }
                    final stats = snapshot.data ?? {};
                    final units = (stats['units_count'] ?? 0).toString();
                    final revenue = (stats['revenue'] is num) ? (stats['revenue'] as num).toStringAsFixed(0) : '0';
                    final pending = (stats['pending_bookings'] ?? 0).toString();

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                icon: Icons.apartment_rounded,
                                label: AppStrings.t(isArabic, 'nav_units'),
                                value: units,
                              ),
                            ),
                            const SizedBox(width: AppDimens.md),
                            Expanded(
                              child: _MetricCard(
                                icon: Icons.account_balance_wallet_rounded,
                                label: AppStrings.t(isArabic, 'nav_revenue'),
                                value: '$revenue ${AppStrings.t(isArabic, 'sar')}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimens.md),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                icon: Icons.hourglass_top_rounded,
                                label: AppStrings.t(isArabic, 'pending_bookings'),
                                value: pending,
                              ),
                            ),
                            const SizedBox(width: AppDimens.md),
                            Expanded(
                              child: _MetricCard(
                                icon: Icons.calendar_month_rounded,
                                label: AppStrings.t(isArabic, 'owner_bookings'),
                                value: (stats['bookings_count'] ?? 0).toString(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: AppDimens.xl),

                Text(AppStrings.t(isArabic, 'quick_links'), style: textTheme.titleMedium),
                const SizedBox(height: AppDimens.md),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppDimens.md,
                  crossAxisSpacing: AppDimens.md,
                  childAspectRatio: 1.5,
                  children: quickLinks.map((link) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      onTap: link.onTap,
                      child: Container(
                        padding: const EdgeInsets.all(AppDimens.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(link.icon, color: AppColors.goldDark, size: 24),
                            Text(
                              link.title,
                              style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.goldDark, size: 22),
          const SizedBox(height: AppDimens.sm),
          Text(value, style: Theme.of(context).textTheme.titleMedium, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onRetry;
  const _ErrorRetry({required this.isArabic, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.lg),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 32),
          const SizedBox(height: AppDimens.sm),
          Text(AppStrings.t(isArabic, 'error_loading'), textAlign: TextAlign.center),
          const SizedBox(height: AppDimens.sm),
          OutlinedButton(onPressed: onRetry, child: Text(AppStrings.t(isArabic, 'retry'))),
        ],
      ),
    );
  }
}
