import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'auth_provider.dart';

/// كل تقييمات فندق معيّن، مع اسم كاتب التقييم من جدول profiles
final hotelReviewsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, hotelId) async {
  final data = await supabase
      .from('reviews')
      .select('*, profiles(full_name)')
      .eq('hotel_id', hotelId)
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data as List);
});

/// حجز واحد يخص المستخدم الحالي بفندق معيّن، اكتمل ولسا ما انكتب له تقييم
/// (يُستخدم لتحديد هل نعرض زر "أضف تقييم" أو لا)
final reviewableBookingProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, hotelId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final bookings = await supabase
      .from('bookings')
      .select()
      .eq('guest_id', user.id)
      .eq('hotel_id', hotelId)
      .eq('status', 'completed')
      .order('created_at', ascending: false);

  for (final booking in (bookings as List)) {
    final existingReview = await supabase
        .from('reviews')
        .select('id')
        .eq('booking_id', booking['id'] as String)
        .maybeSingle();
    if (existingReview == null) return booking as Map<String, dynamic>;
  }
  return null;
});

class ReviewsRepository {
  final Ref ref;
  ReviewsRepository(this.ref);

  Future<void> submitReview({
    required String hotelId,
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('reviews').insert({
      'hotel_id': hotelId,
      'guest_id': user.id,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
    });
    ref.invalidate(hotelReviewsProvider(hotelId));
    ref.invalidate(reviewableBookingProvider(hotelId));
  }
}

final reviewsRepositoryProvider = Provider((ref) => ReviewsRepository(ref));
