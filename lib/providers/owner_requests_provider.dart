import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'auth_provider.dart';

/// يرجع أرقام الفنادق (IDs) اللي يملكها المستخدم الحالي فقط
Future<List<String>> _ownedHotelIds(String userId) async {
  final data = await supabase.from('hotels').select('id').eq('owner_id', userId);
  return (data as List).map((row) => row['id'] as String).toList();
}

/// كل حجوزات فنادق المالك الحالي (وليس حجوزات المالك نفسه كنزيل)
final ownerBookingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final hotelIds = await _ownedHotelIds(user.id);
  if (hotelIds.isEmpty) return [];
  final data = await supabase
      .from('bookings')
      .select('*, hotels(name, city_ar, city_en)')
      .inFilter('hotel_id', hotelIds)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data as List);
});

/// طلبات الصيانة/التنظيف لفنادق المالك الحالي
final ownerServiceRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final hotelIds = await _ownedHotelIds(user.id);
  if (hotelIds.isEmpty) return [];
  final data = await supabase
      .from('service_requests')
      .select('*, hotels(name)')
      .inFilter('hotel_id', hotelIds)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data as List);
});

/// طلبات الأكل لفنادق المالك الحالي
final ownerMealRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final hotelIds = await _ownedHotelIds(user.id);
  if (hotelIds.isEmpty) return [];
  final data = await supabase
      .from('meal_requests')
      .select('*, hotels(name)')
      .inFilter('hotel_id', hotelIds)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data as List);
});

class OwnerRequestsRepository {
  final Ref ref;
  OwnerRequestsRepository(this.ref);

  Future<void> updateServiceRequestStatus(String id, String status) async {
    await supabase.from('service_requests').update({'status': status}).eq('id', id);
    ref.invalidate(ownerServiceRequestsProvider);
  }

  Future<void> updateMealRequestStatus(String id, String status) async {
    await supabase.from('meal_requests').update({'status': status}).eq('id', id);
    ref.invalidate(ownerMealRequestsProvider);
  }
}

final ownerRequestsRepositoryProvider = Provider((ref) => OwnerRequestsRepository(ref));
