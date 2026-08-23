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

  Future<List<Map<String, dynamic>>> getDocuments() async {
    try {
      final res = await _dio.get('/documents/list.php');
      return (res.data['documents'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getDecisions() async {
    try {
      final res = await _dio.get('/decisions/list.php');
      return (res.data['decisions'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> castVote({required int decisionId, required int optionId}) async {
    try {
      await _dio.post('/decisions/vote.php', data: {'decision_id': decisionId, 'option_id': optionId});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> createDecision({
    required int hotelId,
    required String title,
    String? description,
    required List<String> options,
  }) async {
    try {
      await _dio.post('/decisions/create.php', data: {
        'hotel_id': hotelId,
        'title': title,
        if (description != null) 'description': description,
        'options': options,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getCommunityPosts() async {
    try {
      final res = await _dio.get('/community/list.php');
      return (res.data['posts'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> createCommunityPost(String content) async {
    try {
      await _dio.post('/community/post.php', data: {'content': content});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> toggleCommunityLike(int postId) async {
    try {
      await _dio.post('/community/like.php', data: {'post_id': postId});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getPostComments(int postId) async {
    try {
      final res = await _dio.get('/community/comments.php', queryParameters: {'post_id': postId});
      return (res.data['comments'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> addComment(int postId, String content) async {
    try {
      await _dio.post('/community/comments.php', data: {'post_id': postId, 'content': content});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMarketplaceListings() async {
    try {
      final res = await _dio.get('/marketplace/list.php');
      return (res.data['listings'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> createListing({
    required String title,
    String? description,
    required String listingType,
    double? price,
    int? unitId,
  }) async {
    try {
      await _dio.post('/marketplace/create.php', data: {
        'title': title,
        if (description != null) 'description': description,
        'listing_type': listingType,
        if (price != null) 'price': price,
        if (unitId != null) 'unit_id': unitId,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> expressInterest(int listingId, {String? message}) async {
    try {
      await _dio.post('/marketplace/interest.php', data: {'listing_id': listingId, if (message != null) 'message': message});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    try {
      final res = await _dio.get('/messages/conversations.php');
      return (res.data['conversations'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getOwnerDirectory() async {
    try {
      final res = await _dio.get('/messages/directory.php');
      return (res.data['owners'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getThread(int conversationId) async {
    try {
      final res = await _dio.get('/messages/thread.php', queryParameters: {'conversation_id': conversationId});
      return (res.data['messages'] as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<int> sendMessage({int? conversationId, int? recipientId, required String body}) async {
    try {
      final res = await _dio.post('/messages/send.php', data: {
        if (conversationId != null) 'conversation_id': conversationId,
        if (recipientId != null) 'recipient_id': recipientId,
        'body': body,
      });
      return res.data['conversation_id'] as int;
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
}
