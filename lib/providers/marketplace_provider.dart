import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'auth_provider.dart';

final marketplaceListingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await supabase
      .from('marketplace_listings')
      .select('*, profiles(full_name, phone, email), hotels(name)')
      .eq('status', 'active')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data as List);
});

final myListingsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await supabase
      .from('marketplace_listings')
      .select('*, hotels(name)')
      .eq('owner_id', user.id)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data as List);
});

class MarketplaceRepository {
  final Ref ref;
  MarketplaceRepository(this.ref);

  Future<void> createListing({
    String? unitId,
    String? hotelId,
    required String title,
    String? description,
    required String listingType,
    required double price,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('marketplace_listings').insert({
      'owner_id': user.id,
      'unit_id': unitId,
      'hotel_id': hotelId,
      'title': title,
      'description': description,
      'listing_type': listingType,
      'price': price,
      'status': 'active',
    });
    ref.invalidate(marketplaceListingsProvider);
    ref.invalidate(myListingsProvider);
  }

  Future<void> closeListing(String id) async {
    await supabase.from('marketplace_listings').update({'status': 'closed'}).eq('id', id);
    ref.invalidate(marketplaceListingsProvider);
    ref.invalidate(myListingsProvider);
  }
}

final marketplaceRepositoryProvider = Provider((ref) => MarketplaceRepository(ref));
