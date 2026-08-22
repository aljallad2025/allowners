import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/permissions_provider.dart';
import 'owner_home_screen.dart';
import 'owner_units_screen.dart';
import 'owner_revenue_screen.dart';
import 'owner_notifications_screen.dart';
import 'owner_profile_screen.dart';

class OwnerNavigationScreen extends ConsumerStatefulWidget {
  const OwnerNavigationScreen({super.key});

  @override
  ConsumerState<OwnerNavigationScreen> createState() => _OwnerNavigationScreenState();
}

class _OwnerNavigationScreenState extends ConsumerState<OwnerNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // نحمّل الصلاحيات أول ما تفتح بوابة المالك (يغطي حالة استرجاع الجلسة بعد إعادة فتح التطبيق)
    Future.microtask(() => ref.read(permissionsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final perms = ref.watch(permissionsProvider);

    if (perms.isLoading && perms.permissions.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.gold)),
      );
    }

    final tabs = <({Widget screen, IconData icon, IconData activeIcon, String label})>[
      (
        screen: const OwnerHomeScreen(),
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: AppStrings.t(isArabic, 'nav_home'),
      ),
      if (perms.can('units', 'view'))
        (
          screen: const OwnerUnitsScreen(),
          icon: Icons.apartment_outlined,
          activeIcon: Icons.apartment_rounded,
          label: AppStrings.t(isArabic, 'nav_units'),
        ),
      if (perms.can('revenue', 'view'))
        (
          screen: const OwnerRevenueScreen(),
          icon: Icons.account_balance_wallet_outlined,
          activeIcon: Icons.account_balance_wallet_rounded,
          label: AppStrings.t(isArabic, 'nav_revenue'),
        ),
      (
        screen: const OwnerNotificationsScreen(),
        icon: Icons.notifications_outlined,
        activeIcon: Icons.notifications_rounded,
        label: AppStrings.t(isArabic, 'notifications'),
      ),
      (
        screen: const OwnerProfileScreen(),
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: AppStrings.t(isArabic, 'nav_profile'),
      ),
    ];

    final safeIndex = _currentIndex < tabs.length ? _currentIndex : 0;

    return Scaffold(
      body: IndexedStack(index: safeIndex, children: tabs.map((t) => t.screen).toList()),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: safeIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  activeIcon: Icon(t.activeIcon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
