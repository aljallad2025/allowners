import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
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

  final List<Widget> _screens = const [
    OwnerHomeScreen(),
    OwnerUnitsScreen(),
    OwnerRevenueScreen(),
    OwnerNotificationsScreen(),
    OwnerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: AppStrings.t(isArabic, 'nav_home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.apartment_outlined),
            activeIcon: const Icon(Icons.apartment_rounded),
            label: AppStrings.t(isArabic, 'nav_units'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            activeIcon: const Icon(Icons.account_balance_wallet_rounded),
            label: AppStrings.t(isArabic, 'nav_revenue'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.notifications_outlined),
            activeIcon: const Icon(Icons.notifications_rounded),
            label: AppStrings.t(isArabic, 'notifications'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: AppStrings.t(isArabic, 'nav_profile'),
          ),
        ],
      ),
    );
  }
}