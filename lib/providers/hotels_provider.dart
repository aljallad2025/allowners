import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/hotel_model.dart';
import 'auth_provider.dart';
import 'favorites_provider.dart';

/// يجلب كل الفنادق الفعالة مع صورها ومع علامة "مفضلة" للمستخدم الحالي
final hotelsProvider = FutureProvider<List<HotelModel>>((ref) async {
  final hotelsData = await supabase
      .from('hotels')
      .select('*, hotel_images(image_url, sort_order)')
      .eq('is_active', true)
      .order('created_at', ascending: false);

  final favoriteIds = await ref.watch(favoriteHotelIdsProvider.future);

  return (hotelsData as List).map((row) {
    final images = (row['hotel_images'] as List? ?? [])
      ..sort((a, b) => (a['sort_order'] as int? ?? 0).compareTo(b['sort_order'] as int? ?? 0));
    final galleryUrls = images.map((i) => i['image_url'] as String).toList();
    return HotelModel.fromJson(
      row,
      galleryUrls: galleryUrls,
      isFavorite: favoriteIds.contains(row['id']),
    );
  }).toList();
});

/// فندق واحد بالتفاصيل (يُستخدم عند فتح صفحة تفاصيل فندق برقمه فقط)
final hotelByIdProvider = FutureProvider.family<HotelModel?, String>((ref, id) async {
  final row = await supabase
      .from('hotels')
      .select('*, hotel_images(image_url, sort_order)')
      .eq('id', id)
      .maybeSingle();
  if (row == null) return null;
  final images = (row['hotel_images'] as List? ?? [])
    ..sort((a, b) => (a['sort_order'] as int? ?? 0).compareTo(b['sort_order'] as int? ?? 0));
  final galleryUrls = images.map((i) => i['image_url'] as String).toList();
  final favoriteIds = await ref.watch(favoriteHotelIdsProvider.future);
  return HotelModel.fromJson(row, galleryUrls: galleryUrls, isFavorite: favoriteIds.contains(id));
});

/// فنادق يملكها المالك الحالي
final ownerHotelsProvider = FutureProvider<List<HotelModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await supabase
      .from('hotels')
      .select('*, hotel_images(image_url, sort_order)')
      .eq('owner_id', user.id)
      .order('created_at', ascending: false);
  return (data as List).map((row) {
    final images = (row['hotel_images'] as List? ?? [])
      ..sort((a, b) => (a['sort_order'] as int? ?? 0).compareTo(b['sort_order'] as int? ?? 0));
    final galleryUrls = images.map((i) => i['image_url'] as String).toList();
    return HotelModel.fromJson(row, galleryUrls: galleryUrls);
  }).toList();
});
