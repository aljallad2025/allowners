import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../models/notification_model.dart';
import 'auth_provider.dart';

/// إشعارات المستخدم الحالي (تعمل لأي دور: ضيف أو مالك) من جدول notifications الموحّد
final myNotificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await supabase
      .from('notifications')
      .select()
      .eq('user_id', user.id)
      .order('created_at', ascending: false);
  return (data as List).map((row) => NotificationModel.fromJson(row)).toList();
});

class NotificationsRepository {
  final Ref ref;
  NotificationsRepository(this.ref);

  Future<void> markAsRead(String id) async {
    await supabase.from('notifications').update({'is_read': true}).eq('id', id);
    ref.invalidate(myNotificationsProvider);
  }
}

final notificationsRepositoryProvider = Provider((ref) => NotificationsRepository(ref));
