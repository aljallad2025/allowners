import 'package:dio/dio.dart';
import 'api_client.dart';

/// كل استدعاءات الـ API الخاصة بلوحة المالك (الوحدات، الحجوزات، الإيرادات، الصيانة)
class OwnerService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final res = await _dio.get('/user/owner-dashboard.php');
      return (res.data['stats'] as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getHotels() async {
    try {
      final res = await _dio.get('/user/owner-dashboard.php');
      return (res.data['hotels'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getUnits() async {
    try {
      final res = await _dio.get('/user/owner-units.php');
      return (res.data['units'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getBookings() async {
    try {
      final res = await _dio.get('/user/owner-bookings.php');
      return {
        'bookings': (res.data['bookings'] as List).cast<Map<String, dynamic>>(),
        'revenue': (res.data['revenue'] as num).toDouble(),
      };
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getRevenue() async {
    try {
      final res = await _dio.get('/user/owner-revenue.php');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMaintenanceRequests() async {
    try {
      final res = await _dio.get('/user/owner-maintenance.php');
      return (res.data['requests'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> createMaintenanceRequest({
    required int hotelId,
    int? unitId,
    required String title,
    String? description,
  }) async {
    try {
      await _dio.post('/user/owner-maintenance.php', data: {
        'hotel_id': hotelId,
        if (unitId != null) 'unit_id': unitId,
        'title': title,
        if (description != null) 'description': description,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final res = await _dio.get('/user/notifications.php');
      return (res.data['notifications'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _dio.post('/user/notifications.php', data: {'mark_all_read': true});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ---------- الصلاحيات ----------

  Future<Map<String, dynamic>> getMyPermissions() async {
    try {
      final res = await _dio.get('/user/my-permissions.php');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ---------- إدارة الموظفين (المالك فقط) ----------

  Future<Map<String, dynamic>> getStaff() async {
    try {
      final res = await _dio.get('/owner/staff.php');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> inviteStaff({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role, // booking_agent | hotel_manager
    required Map<String, List<String>> permissions,
    double commissionRate = 0,
  }) async {
    try {
      await _dio.post('/owner/staff.php', data: {
        'action': 'invite',
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'permissions': permissions,
        'commission_rate': commissionRate,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> toggleStaffStatus(int id) async {
    try {
      await _dio.post('/owner/staff.php', data: {'action': 'toggle_status', 'id': id});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> deleteStaff(int id) async {
    try {
      await _dio.post('/owner/staff.php', data: {'action': 'delete', 'id': id});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> updateStaffPermissions(int id, Map<String, List<String>> permissions) async {
    try {
      await _dio.post('/owner/staff.php', data: {'action': 'update_permissions', 'id': id, 'permissions': permissions});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ---------- عمولات وكيل الحجوزات ----------

  Future<Map<String, dynamic>> getCommission() async {
    try {
      final res = await _dio.get('/owner/commission.php');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> agentCreateBooking({
    required int hotelId,
    required int unitId,
    required String guestName,
    required String guestPhone,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
  }) async {
    try {
      final res = await _dio.post('/owner/agent-new-booking.php', data: {
        'hotel_id': hotelId,
        'unit_id': unitId,
        'guest_name': guestName,
        'guest_phone': guestPhone,
        'check_in': _fmtDate(checkIn),
        'check_out': _fmtDate(checkOut),
        'guests': guests,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  // ---------- التدبير المنزلي (Housekeeping) ----------

  Future<Map<String, dynamic>> getHousekeeping() async {
    try {
      final res = await _dio.get('/owner/housekeeping.php');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> updateHousekeepingStatus(int unitId, String status) async {
    try {
      await _dio.post('/owner/housekeeping.php', data: {'unit_id': unitId, 'status': status});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
