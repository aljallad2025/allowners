import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/session_provider.dart';
import '../../utils/permissions_provider.dart';
import '../home/main_navigation_screen.dart';
import 'owner_bookings_screen.dart';
import 'owner_maintenance_screen.dart';
import 'owner_revenue_screen.dart';
import 'owner_units_screen.dart';
import 'owner_staff_screen.dart';
import 'owner_commission_screen.dart';
import 'owner_housekeeping_screen.dart';

class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key});

  String _roleLabel(String role, bool isArabic) {
    const labels = {
      'owner': {'ar': 'مالك', 'en': 'Owner'},
      'booking_agent': {'ar': 'وكيل حجوزات', 'en': 'Booking Agent'},
      'hotel_manager': {'ar': 'إدارة فندق', 'en': 'Hotel Manager'},
    };
    return labels[role]?[isArabic ? 'ar' : 'en'] ?? role;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider).user;
    final perms = ref.watch(permissionsProvider);

    final workItems = <_MenuItem>[
      if (perms.can('bookings', 'view'))
        _MenuItem(
          icon: Icons.calendar_month_outlined,
          label: AppStrings.t(isArabic, 'owner_bookings'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerBookingsScreen())),
        ),
      if (perms.can('units', 'view'))
        _MenuItem(
          icon: Icons.apartment_rounded,
          label: AppStrings.t(isArabic, 'nav_units'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerUnitsScreen())),
        ),
      if (perms.can('revenue', 'view'))
        _MenuItem(
          icon: Icons.bar_chart_outlined,
          label: AppStrings.t(isArabic, 'financial_reports'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerRevenueScreen())),
        ),
      if (perms.can('maintenance', 'view'))
        _MenuItem(
          icon: Icons.build_outlined,
          label: AppStrings.t(isArabic, 'maintenance_requests'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerMaintenanceScreen())),
        ),
      if (perms.can('housekeeping', 'view'))
        _MenuItem(
          icon: Icons.cleaning_services_outlined,
          label: AppStrings.t(isArabic, 'housekeeping_status'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerHousekeepingScreen())),
        ),
      if (perms.role == 'owner')
        _MenuItem(
          icon: Icons.badge_outlined,
          label: AppStrings.t(isArabic, 'staff_management'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerStaffScreen())),
        ),
      if (perms.role == 'booking_agent')
        _MenuItem(
          icon: Icons.payments_outlined,
          label: AppStrings.t(isArabic, 'my_commission'),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerCommissionScreen())),
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: AppDimens.md),
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.surfaceMuted,
                child: const Icon(Icons.person_rounded, color: AppColors.textMuted, size: 46),
              ),
              const SizedBox(height: AppDimens.md),
              Text(user?.fullName ?? '', style: textTheme.headlineSmall),
              Text(_roleLabel(perms.role, isArabic),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.goldDark)),
              const SizedBox(height: AppDimens.sm),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(AppStrings.t(isArabic, 'edit_profile')),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8)),
              ),
              const SizedBox(height: AppDimens.xl),

              if (workItems.isNotEmpty) ...[
                _MenuSection(items: workItems),
                const SizedBox(height: AppDimens.md),
              ],

              _MenuSection(items: [
                _MenuItem(icon: Icons.help_outline_rounded, label: AppStrings.t(isArabic, 'help_support'), onTap: () {}),
                _MenuItem(
                  icon: Icons.language_rounded,
                  label: AppStrings.t(isArabic, 'language'),
                  trailing: Text(isArabic ? 'العربية' : 'English',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                ),
              ]),
              const SizedBox(height: AppDimens.md),

              _MenuSection(items: [
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: AppStrings.t(isArabic, 'logout'),
                  iconColor: AppColors.danger,
                  textColor: AppColors.danger,
                  onTap: () async {
                    await ref.read(sessionProvider.notifier).logout();
                    ref.read(permissionsProvider.notifier).clear();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                        (route) => false,
                      );
                    }
                  },
                ),
              ]),
              const SizedBox(height: AppDimens.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.textColor,
  });
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 14),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 22, color: item.iconColor ?? AppColors.textSecondary),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: item.textColor ?? AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (item.trailing != null) item.trailing!,
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              if (index != items.length - 1)
                const Divider(height: 1, indent: AppDimens.md, endIndent: AppDimens.md),
            ],
          );
        }),
      ),
    );
  }
}