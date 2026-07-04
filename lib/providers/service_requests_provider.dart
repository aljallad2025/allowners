import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class ServiceRequestsRepository {
  Future<void> submitServiceRequest({
    required String hotelId,
    String? bookingId,
    required String serviceType,
    required String roomNumber,
    String? details,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('service_requests').insert({
      'guest_id': user.id,
      'hotel_id': hotelId,
      'booking_id': bookingId,
      'service_type': serviceType,
      'room_number': roomNumber,
      'details': details,
      'status': 'pending',
    });
  }

  Future<void> submitMealRequest({
    required String hotelId,
    String? bookingId,
    required String meal,
    String? notes,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('meal_requests').insert({
      'guest_id': user.id,
      'hotel_id': hotelId,
      'booking_id': bookingId,
      'meal': meal,
      'notes': notes,
      'status': 'pending',
    });
  }
}

final serviceRequestsRepositoryProvider = Provider((ref) => ServiceRequestsRepository());
