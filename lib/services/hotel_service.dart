import 'package:dio/dio.dart';
import '../models/hotel_model.dart';
import 'api_client.dart';

class HotelService {
  final Dio _dio = ApiClient.instance.dio;

  Future<List<Map<String, dynamic>>> browseUnits({
    String? search,
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
    String sort = 'newest',
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get('/units/browse.php', queryParameters: {
        if (search != null && search.isNotEmpty) 'q': search,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (minCapacity != null) 'min_capacity': minCapacity,
        'sort': sort,
        'limit': limit,
      });
      return (res.data['units'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<HotelModel>> listHotels({
    String? city,
    double? minPrice,
    double? maxPrice,
    int? stars,
    bool featuredOnly = false,
  }) async {
    try {
      final res = await _dio.get('/hotels/list.php', queryParameters: {
        if (city != null && city.isNotEmpty) 'city': city,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (stars != null) 'stars': stars,
        if (featuredOnly) 'featured': 1,
      });
      final list = (res.data['hotels'] as List).cast<Map<String, dynamic>>();
      return list.map((h) => HotelModel.fromJson(h)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<HotelModel> getHotelDetail(String id) async {
    try {
      final res = await _dio.get('/hotels/detail.php', queryParameters: {'id': id});
      final data = res.data as Map<String, dynamic>;
      final gallery = (data['gallery'] as List?)?.cast<String>() ?? const <String>[];
      return HotelModel.fromJson(data['hotel'] as Map<String, dynamic>, gallery: gallery);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getHotelAmenities(String id) async {
    try {
      final res = await _dio.get('/hotels/detail.php', queryParameters: {'id': id});
      return (res.data['amenities'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<bool> toggleFavorite(String hotelId) async {
    try {
      final res = await _dio.post('/favorites/toggle.php', data: {'hotel_id': int.parse(hotelId)});
      return res.data['favorited'] == true;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<HotelModel>> myFavorites() async {
    try {
      final res = await _dio.get('/favorites/my.php');
      final list = (res.data['hotels'] as List).cast<Map<String, dynamic>>();
      return list.map((h) => HotelModel.fromJson(h, isFavorite: true)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUnits(String hotelId) async {
    try {
      final res = await _dio.get('/units/list.php', queryParameters: {'hotel_id': int.parse(hotelId)});
      return (res.data['units'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getUnitDetail(int unitId) async {
    try {
      final res = await _dio.get('/units/detail.php', queryParameters: {'id': unitId});
      return (res.data['unit'] as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUnitAddons(int unitId) async {
    try {
      final res = await _dio.get('/units/addons.php', queryParameters: {'unit_id': unitId});
      return (res.data['addons'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required String hotelId,
    int? unitId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String paymentMethod, // online | at_hotel | owner_transfer
    String? cardNumber,
    String mealType = 'none', // none | breakfast | lunch | dinner | all
    bool extraBed = false,
    List<int>? addonIds,
    String? guestIdNumber,
    String? customerName, // وكيل الحجوزات: اسم العميل
    String? customerPhone, // وكيل الحجوزات: جوال العميل
  }) async {
    try {
      final res = await _dio.post('/bookings/create.php', data: {
        'hotel_id': int.parse(hotelId),
        if (unitId != null) 'unit_id': unitId,
        'check_in': _fmt(checkIn),
        'check_out': _fmt(checkOut),
        'guests': guests,
        'payment_method': paymentMethod,
        'meal_type': mealType,
        'extra_bed': extraBed,
        if (addonIds != null && addonIds.isNotEmpty) 'addon_ids': addonIds,
        if (cardNumber != null) 'card_number': cardNumber,
        'guest_id_number': guestIdNumber ?? '',
        if (customerName != null) 'customer_name': customerName,
        if (customerPhone != null) 'customer_phone': customerPhone,
      });
      return (res.data['booking'] as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> myBookings() async {
    try {
      final res = await _dio.get('/bookings/my.php');
      return (res.data['bookings'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// إلغاء حجز (ضيف / وكيل) — للحجز المعلّق أو المؤكد قبل يوم الوصول
  Future<void> cancelBooking(int bookingId) async {
    try {
      await _dio.post('/bookings/manage.php', data: {'booking_id': bookingId, 'action': 'cancel'});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// تعديل حجز (تواريخ / ضيوف / بيانات العميل) مع إعادة حساب السعر من السيرفر
  Future<Map<String, dynamic>> updateBooking({
    required int bookingId,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    String? guestName,
    String? guestPhone,
  }) async {
    try {
      final res = await _dio.post('/bookings/manage.php', data: {
        'booking_id': bookingId,
        'action': 'update',
        if (checkIn != null) 'check_in': _fmt(checkIn),
        if (checkOut != null) 'check_out': _fmt(checkOut),
        if (guests != null) 'guests': guests,
        if (guestName != null) 'guest_name': guestName,
        if (guestPhone != null) 'guest_phone': guestPhone,
      });
      return (res.data['booking'] as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// طلب وجبات (اختيار متعدد) — يصل للفندق، بعد تأكيد الحجز فقط
  Future<void> requestMeals({
    required int bookingId,
    required String roomNumber,
    required List<String> mealTypes, // breakfast | lunch | dinner
    String? notes,
  }) async {
    try {
      await _dio.post('/services/meal-request.php', data: {
        'booking_id': bookingId,
        'room_number': roomNumber,
        'meal_types': mealTypes,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// طلب خدمة (نظافة، مناشف ...) — يصل للفندق
  Future<void> requestService({
    required int bookingId,
    required String roomNumber,
    required String serviceType,
    String? description,
  }) async {
    try {
      await _dio.post('/services/request.php', data: {
        'booking_id': bookingId,
        'room_number': roomNumber,
        'service_type': serviceType,
        if (description != null && description.isNotEmpty) 'description': description,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
