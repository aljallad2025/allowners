import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../shared/coming_soon_screen.dart';

class OwnerHomeScreen extends ConsumerWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    final quickLinks = [
      (icon: Icons.calendar_month_outlined, title: AppStrings.t(isArabic, 'owner_bookings')),
      (icon: Icons.bar_chart_outlined, title: AppStrings.t(isArabic, 'financial_reports')),
      (icon: Icons.folder_outlined, title: AppStrings.t(isArabic, 'contracts_docs')),
      (icon: Icons.build_outlined, title: AppStrings.t(isArabic, 'maintenance_requests')),
      (icon: Icons.how_to_vote_outlined, title: AppStrings.t(isArabic, 'voting_decisions')),
      (icon: Icons.groups_outlined, title: AppStrings.t(isArabic, 'owners_community')),
      (icon: Icons.storefront_outlined, title: AppStrings.t(isArabic, 'units_marketplace')),
      (icon: Icons.chat_bubble_outline_rounded, title: AppStrings.t(isArabic, 'messages')),
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
              Text('ثائر الجلاد', style: textTheme.headlineMedium),
              const SizedBox(height: AppDimens.lg),

              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.apartment_rounded,
                      label: AppStrings.t(isArabic, 'nav_units'),
                      value: '3',
                    ),
                  ),
                  const SizedBox(width: AppDimens.md),
                  Expanded(
                    child: _MetricCard(
                      icon: Icons.account_balance_wallet_rounded,
                      label: AppStrings.t(isArabic, 'nav_revenue'),
                      value: '12,450 ${AppStrings.t(isArabic, 'sar')}',
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
                        MaterialPageRoute(
                          builder: (_) => ComingSoonScreen(icon: link.icon, title: link.title),
                        ),
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