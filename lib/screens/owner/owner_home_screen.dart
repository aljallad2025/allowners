import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/owner_provider.dart';
import 'owner_hotels_screen.dart';
import 'owner_bookings_screen.dart';
import 'owner_maintenance_screen.dart';
import 'community_screen.dart';
import 'marketplace_screen.dart';
import 'messages_screen.dart';
import 'voting_screen.dart';
import '../shared/coming_soon_screen.dart';

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(currentProfileProvider).asData?.value;
    final unitsAsync = ref.watch(ownerUnitsProvider);
    final revenueAsync = ref.watch(ownerMonthlyRevenueProvider);

    final quickLinks = [
      (
        icon: Icons.apartment_outlined,
        title: AppStrings.t(isArabic, 'my_hotels'),
        builder: (BuildContext context) => const OwnerHotelsScreen(),
      ),
      (
        icon: Icons.calendar_month_outlined,
        title: AppStrings.t(isArabic, 'owner_bookings'),
        builder: (BuildContext context) => const OwnerBookingsScreen(),
      ),
      (
        icon: Icons.bar_chart_outlined,
        title: AppStrings.t(isArabic, 'financial_reports'),
        builder: (BuildContext context) =>
            ComingSoonScreen(icon: Icons.bar_chart_outlined, title: AppStrings.t(isArabic, 'financial_reports')),
      ),
      (
        icon: Icons.folder_outlined,
        title: AppStrings.t(isArabic, 'contracts_docs'),
        builder: (BuildContext context) =>
            ComingSoonScreen(icon: Icons.folder_outlined, title: AppStrings.t(isArabic, 'contracts_docs')),
      ),
      (
        icon: Icons.build_outlined,
        title: AppStrings.t(isArabic, 'maintenance_requests'),
        builder: (BuildContext context) => const OwnerMaintenanceScreen(),
      ),
      (
        icon: Icons.how_to_vote_outlined,
        title: AppStrings.t(isArabic, 'voting_decisions'),
        builder: (BuildContext context) => const VotingScreen(),
      ),
      (
        icon: Icons.groups_outlined,
        title: AppStrings.t(isArabic, 'owners_community'),
        builder: (BuildContext context) => const CommunityScreen(),
      ),
      (
        icon: Icons.storefront_outlined,
        title: AppStrings.t(isArabic, 'units_marketplace'),
        builder: (BuildContext context) => const MarketplaceScreen(),
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        title: AppStrings.t(isArabic, 'messages'),
        builder: (BuildContext context) => const MessagesScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.t(isArabic, 'hello'),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              Text(
                  (profile != null && profile.fullName.isNotEmpty)
                      ? profile.fullName
                      : AppStrings.t(isArabic, 'role_owner'),
                  style: textTheme.headlineMedium),
              const SizedBox(height: AppDimens.lg),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.apartment_rounded,
                      label: AppStrings.t(isArabic, 'nav_units'),
                      value: unitsAsync.asData?.value.length.toString() ?? '—',
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.account_balance_wallet_rounded,
                      label: AppStrings.t(isArabic, 'nav_revenue'),
                      value: '${revenueAsync.asData?.value.toInt() ?? 0} ${AppStrings.t(isArabic, 'sar')}',
                    ),
                  ),
                ],
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: link.builder),
                      );
                    },
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
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}