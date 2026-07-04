import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/hotel_model.dart';
import 'auth_provider.dart';
import 'hotels_provider.dart';

/// أرقام الفنادق المفضلة للمستخدم الحالي (Set لسهولة الفحص السريع)
final favoriteHotelIdsProvider = FutureProvider<Set<String>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  final data = await supabase.from('favorites').select('hotel_id').eq('guest_id', user.id);
  return (data as List).map((e) => e['hotel_id'] as String).toSet();
});

/// قائمة الفنادق المفضلة كاملة (لعرضها بشاشة المفضلة)
final favoriteHotelsProvider = FutureProvider<List<HotelModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await supabase
      .from('favorites')
      .select('hotels(*, hotel_images(image_url, sort_order))')
      .eq('guest_id', user.id)
      .order('created_at', ascending: false);

  return (data as List).where((row) => row['hotels'] != null).map((row) {
    final hotel = row['hotels'] as Map<String, dynamic>;
    final images = (hotel['hotel_images'] as List? ?? [])
      ..sort((a, b) => (a['sort_order'] as int? ?? 0).compareTo(b['sort_order'] as int? ?? 0));
    final galleryUrls = images.map((i) => i['image_url'] as String).toList();
    return HotelModel.fromJson(hotel, galleryUrls: galleryUrls, isFavorite: true);
  }).toList();
});

class FavoritesRepository {
  final Ref ref;
  FavoritesRepository(this.ref);

  Future<void> toggle(String hotelId, bool currentlyFavorite) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    if (currentlyFavorite) {
      await supabase.from('favorites').delete().eq('guest_id', user.id).eq('hotel_id', hotelId);
    } else {
      await supabase.from('favorites').insert({'guest_id': user.id, 'hotel_id': hotelId});
    }
    ref.invalidate(favoriteHotelIdsProvider);
    ref.invalidate(favoriteHotelsProvider);
    ref.invalidate(hotelsProvider);
  }
}

final favoritesRepositoryProvider = Provider((ref) => FavoritesRepository(ref));
