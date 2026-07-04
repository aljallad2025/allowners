import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/booking_model.dart';
import 'auth_provider.dart';

/// كل حجوزات النزيل الحالي مع بيانات الفندق المرفقة
final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await supabase
      .from('bookings')
      .select('*, hotels(name, city_ar, city_en, cover_image_url)')
      .eq('guest_id', user.id)
      .order('created_at', ascending: false);
  return (data as List).map((row) => BookingModel.fromJson(row)).toList();
});

/// آخر حجز قادم (upcoming) للنزيل الحالي - يُستخدم لربط طلبات الخدمة/الأكل بالفندق الصحيح
final activeBookingProvider = FutureProvider<BookingModel?>((ref) async {
  final bookings = await ref.watch(myBookingsProvider.future);
  final upcoming = bookings.where((b) => b.status == BookingStatus.upcoming).toList();
  if (upcoming.isEmpty) return null;
  return upcoming.first;
});

class BookingsRepository {
  final Ref ref;
  BookingsRepository(this.ref);

  Future<void> createBooking({
    required String hotelId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required int nights,
    required double roomPrice,
    required double taxes,
    required double totalPrice,
    required String paymentMethod,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('bookings').insert({
      'guest_id': user.id,
      'hotel_id': hotelId,
      'check_in': checkIn.toIso8601String().split('T').first,
      'check_out': checkOut.toIso8601String().split('T').first,
      'guests_count': guests,
      'nights': nights,
      'room_price': roomPrice,
      'taxes': taxes,
      'total_price': totalPrice,
      'payment_method': paymentMethod,
      'status': 'upcoming',
    });
    // ملاحظة: إشعارات الحجز الجديد (للضيف والمالك) تُنشأ تلقائياً بواسطة
    // trigger على قاعدة البيانات (انظر migration_notifications.sql) - وليس من هنا،
    // لأن سياسات RLS تمنع العميل من إدراج إشعار لمستخدم آخر (المالك)، وهذا مقصود أمنياً.
    ref.invalidate(myBookingsProvider);
  }
}

final bookingsRepositoryProvider = Provider((ref) => BookingsRepository(ref));
