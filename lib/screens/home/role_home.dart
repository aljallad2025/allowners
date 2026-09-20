import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../hotel/hotel_navigation_screen.dart';
import '../owner/owner_navigation_screen.dart';
import 'main_navigation_screen.dart';

/// الواجهة الرئيسية حسب دور المستخدم بعد الدخول:
///  - owner          → واجهة المالك
///  - hotel_manager  → واجهة إدارة الفندق (طلبات، حجوزات، أسعار)
///  - غير ذلك (ضيف / وكيل حجوزات ...) → واجهة الضيف (الوكيل يحجز باسم عميل ويرى عمولته من حسابي)
Widget homeForUser(AppUser user) {
  if (user.isHotelManager) return const HotelNavigationScreen();
  if (user.isOwner) return const OwnerNavigationScreen();
  return const MainNavigationScreen();
}
