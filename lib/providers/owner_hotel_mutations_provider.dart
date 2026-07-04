import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'auth_provider.dart';
import 'hotels_provider.dart';
import 'owner_provider.dart';

class OwnerHotelMutationsRepository {
  final Ref ref;
  OwnerHotelMutationsRepository(this.ref);

  /// يرفع صورة لمخزن hotel-images ويرجع الرابط العام
  Future<String> uploadHotelImage(File file, String hotelFolderId) async {
    final ext = file.path.split('.').last;
    final path = '$hotelFolderId/${DateTime.now().millisecondsSinceEpoch}.$ext';
    await supabase.storage.from('hotel-images').upload(path, file);
    return supabase.storage.from('hotel-images').getPublicUrl(path);
  }

  Future<String> createHotel({
    required String name,
    required String cityAr,
    required String cityEn,
    required String typeAr,
    required String typeEn,
    String? descriptionAr,
    String? descriptionEn,
    required int stars,
    required double pricePerNight,
    required bool freeCancellation,
    required bool breakfastIncluded,
    String? coverImageUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    final row = await supabase
        .from('hotels')
        .insert({
          'owner_id': user.id,
          'name': name,
          'city_ar': cityAr,
          'city_en': cityEn,
          'type_ar': typeAr,
          'type_en': typeEn,
          'description_ar': descriptionAr,
          'description_en': descriptionEn,
          'stars': stars,
          'price_per_night': pricePerNight,
          'free_cancellation': freeCancellation,
          'breakfast_included': breakfastIncluded,
          'cover_image_url': coverImageUrl,
        })
        .select('id')
        .single();

    ref.invalidate(ownerHotelsProvider);
    ref.invalidate(hotelsProvider);
    return row['id'] as String;
  }

  Future<void> updateHotelCoverImage(String hotelId, String imageUrl) async {
    await supabase.from('hotels').update({'cover_image_url': imageUrl}).eq('id', hotelId);
    ref.invalidate(ownerHotelsProvider);
    ref.invalidate(hotelsProvider);
  }

  Future<void> addHotelImage(String hotelId, String imageUrl, int sortOrder) async {
    await supabase.from('hotel_images').insert({
      'hotel_id': hotelId,
      'image_url': imageUrl,
      'sort_order': sortOrder,
    });
    ref.invalidate(ownerHotelsProvider);
    ref.invalidate(hotelsProvider);
  }

  Future<void> createUnit({
    required String hotelId,
    required String name,
    required bool occupied,
    required double monthlyRevenue,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('units').insert({
      'hotel_id': hotelId,
      'owner_id': user.id,
      'name': name,
      'status': occupied ? 'occupied' : 'vacant',
      'monthly_revenue': monthlyRevenue,
    });
    ref.invalidate(ownerUnitsProvider);
    ref.invalidate(ownerMonthlyRevenueProvider);
  }
}

final ownerHotelMutationsProvider = Provider((ref) => OwnerHotelMutationsRepository(ref));

extension OwnerHotelMutationsExtra on OwnerHotelMutationsRepository {
  Future<void> updateHotel({
    required String hotelId,
    required String name,
    required String cityAr,
    required String cityEn,
    required String typeAr,
    required String typeEn,
    String? descriptionAr,
    String? descriptionEn,
    required int stars,
    required double pricePerNight,
    required bool freeCancellation,
    required bool breakfastIncluded,
  }) async {
    await supabase.from('hotels').update({
      'name': name,
      'city_ar': cityAr,
      'city_en': cityEn,
      'type_ar': typeAr,
      'type_en': typeEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'stars': stars,
      'price_per_night': pricePerNight,
      'free_cancellation': freeCancellation,
      'breakfast_included': breakfastIncluded,
    }).eq('id', hotelId);
    ref.invalidate(ownerHotelsProvider);
    ref.invalidate(hotelsProvider);
  }

  Future<void> deleteHotel(String hotelId) async {
    await supabase.from('hotels').delete().eq('id', hotelId);
    ref.invalidate(ownerHotelsProvider);
    ref.invalidate(hotelsProvider);
    ref.invalidate(ownerUnitsProvider);
  }

  Future<void> updateUnit({
    required String unitId,
    required String name,
    required bool occupied,
    required double monthlyRevenue,
  }) async {
    await supabase.from('units').update({
      'name': name,
      'status': occupied ? 'occupied' : 'vacant',
      'monthly_revenue': monthlyRevenue,
    }).eq('id', unitId);
    ref.invalidate(ownerUnitsProvider);
    ref.invalidate(ownerMonthlyRevenueProvider);
  }

  Future<void> deleteUnit(String unitId) async {
    await supabase.from('units').delete().eq('id', unitId);
    ref.invalidate(ownerUnitsProvider);
    ref.invalidate(ownerMonthlyRevenueProvider);
  }
}
