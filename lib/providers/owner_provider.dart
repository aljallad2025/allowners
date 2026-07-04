import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/unit_model.dart';
import '../models/notification_model.dart';
import 'auth_provider.dart';

/// وحدات المالك الحالي مع اسم الفندق المرتبط بكل وحدة
final ownerUnitsProvider = FutureProvider<List<UnitModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await supabase
      .from('units')
      .select('*, hotels(name)')
      .eq('owner_id', user.id)
      .order('created_at', ascending: false);
  return (data as List).map((row) => UnitModel.fromJson(row)).toList();
});

/// إجمالي الإيراد الشهري الحالي (مجموع كل وحدات المالك)
final ownerMonthlyRevenueProvider = FutureProvider<double>((ref) async {
  final units = await ref.watch(ownerUnitsProvider.future);
  return units.fold<double>(0, (sum, u) => sum + u.monthlyRevenue);
});

/// سجل الإيرادات الشهرية (Revenue history) للمالك الحالي
final ownerRevenueHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await supabase
      .from('revenue_records')
      .select()
      .eq('owner_id', user.id)
      .order('month', ascending: false);
  return List<Map<String, dynamic>>.from(data as List);
});

/// إشعارات المالك الحالي
final ownerNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await supabase
      .from('notifications')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false);
  return (data as List).map((row) => NotificationModel.fromJson(row)).toList();
});
