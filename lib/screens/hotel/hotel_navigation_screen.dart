import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/locale_provider.dart';
import '../../utils/tr.dart';
import 'hotel_bookings_screen.dart';
import 'hotel_home_screen.dart';
import 'hotel_prices_screen.dart';
import 'hotel_profile_screen.dart';
import 'hotel_requests_screen.dart';

/// واجهة حساب «إدارة الفندق»: الرئيسية | الطلبات | الحجوزات | الأسعار | حسابي
class HotelNavigationScreen extends ConsumerStatefulWidget {
  const HotelNavigationScreen({super.key});

  @override
  ConsumerState<HotelNavigationScreen> createState() => _HotelNavigationScreenState();
}

class _HotelNavigationScreenState extends ConsumerState<HotelNavigationScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    final pages = <Widget>[
      HotelHomeScreen(onOpenBookings: () => setState(() => _index = 2)),
      const HotelRequestsScreen(),
      const HotelBookingsScreen(),
      const HotelPricesScreen(),
      const HotelProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home_rounded),
            label: tr(isArabic, 'الرئيسية', 'Home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            activeIcon: const Icon(Icons.assignment_rounded),
            label: tr(isArabic, 'الطلبات', 'Requests'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: const Icon(Icons.calendar_month_rounded),
            label: tr(isArabic, 'الحجوزات', 'Bookings'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.sell_outlined),
            activeIcon: const Icon(Icons.sell_rounded),
            label: tr(isArabic, 'الأسعار', 'Prices'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline_rounded),
            activeIcon: const Icon(Icons.person_rounded),
            label: tr(isArabic, 'حسابي', 'Account'),
          ),
        ],
      ),
    );
  }
}
