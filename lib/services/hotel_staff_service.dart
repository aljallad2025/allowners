import 'package:dio/dio.dart';
import 'api_client.dart';

/// استدعاءات حساب «إدارة الفندق» (hotel_manager): الحجوزات، الطلبات، الأسعار
class HotelStaffService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final res = await _dio.get('/hotel/dashboard.php');
      return (res.data as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ===== الحجوزات: تأكيد دخول / خروج العميل =====

  Future<List<Map<String, dynamic>>> getBookings({String scope = 'active'}) async {
    try {
      final res = await _dio.get('/hotel/bookings.php', queryParameters: {'scope': scope});
      return (res.data['bookings'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> bookingAction(int bookingId, String action) async {
    try {
      await _dio.post('/hotel/bookings.php', data: {'booking_id': bookingId, 'action': action}); // check_in | check_out
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ===== الطلبات: cleaning | maintenance | meal | extra_bed =====

  Future<List<Map<String, dynamic>>> getRequests(String type, {bool all = false}) async {
    try {
      final res = await _dio.get('/hotel/requests.php', queryParameters: {'type': type, 'status': all ? 'all' : 'open'});
      return (res.data['requests'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// action: confirm | done | reject | preparing | delivered
  Future<void> requestAction({
    required String type,
    required int id,
    required String action,
    String? note,
    double? price,
  }) async {
    try {
      await _dio.post('/hotel/requests.php', data: {
        'type': type,
        'id': id,
        'action': action,
        if (note != null && note.isNotEmpty) 'note': note,
        if (price != null) 'price': price,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ===== أسعار الخدمات =====

  Future<Map<String, dynamic>> getPrices() async {
    try {
      final res = await _dio.get('/hotel/prices.php');
      return {
        'prices': (res.data['prices'] as List).cast<Map<String, dynamic>>(),
        'units': (res.data['units'] as List).cast<Map<String, dynamic>>(),
        'hotels': (res.data['hotels'] as List).cast<Map<String, dynamic>>(),
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> savePrice({
    int? id,
    required int hotelId,
    int? unitId,
    required String serviceType,
    String? titleAr,
    String? titleEn,
    required double price,
    bool isActive = true,
  }) async {
    try {
      await _dio.post('/hotel/prices.php', data: {
        'action': 'save',
        if (id != null) 'id': id,
        'hotel_id': hotelId,
        if (unitId != null) 'unit_id': unitId,
        'service_type': serviceType,
        if (titleAr != null && titleAr.isNotEmpty) 'title_ar': titleAr,
        if (titleEn != null && titleEn.isNotEmpty) 'title_en': titleEn,
        'price': price,
        'is_active': isActive ? 1 : 0,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deletePrice(int id) async {
    try {
      await _dio.post('/hotel/prices.php', data: {'action': 'delete', 'id': id});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}
