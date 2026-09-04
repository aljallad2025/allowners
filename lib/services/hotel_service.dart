import 'package:dio/dio.dart';
import '../models/hotel_model.dart';
import 'api_client.dart';

class HotelService {
  final Dio _dio = ApiClient.instance.dio;

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
    required String paymentMethod, // online | at_hotel
    String? cardNumber,
    String mealType = 'none', // none | breakfast | lunch | dinner | all
    bool extraBed = false,
    List<int>? addonIds,
    String? guestIdNumber,
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

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
