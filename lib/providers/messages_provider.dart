import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'auth_provider.dart';

/// قائمة المحادثات (آخر رسالة مع كل مالك تحدثت معه)
final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];

  final data = await supabase
      .from('messages')
      .select('*, sender:profiles!messages_sender_id_fkey(full_name), receiver:profiles!messages_receiver_id_fkey(full_name)')
      .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
      .order('created_at', ascending: false);

  final rows = List<Map<String, dynamic>>.from(data as List);
  final Map<String, Map<String, dynamic>> latestByPeer = {};
  for (final row in rows) {
    final isSender = row['sender_id'] == user.id;
    final peerId = isSender ? row['receiver_id'] as String : row['sender_id'] as String;
    final peerProfile = isSender ? row['receiver'] : row['sender'];
    if (!latestByPeer.containsKey(peerId)) {
      latestByPeer[peerId] = {
        'peer_id': peerId,
        'peer_name': (peerProfile as Map<String, dynamic>?)?['full_name'] ?? '',
        'last_message': row['content'],
        'created_at': row['created_at'],
        'unread': row['receiver_id'] == user.id && row['is_read'] == false,
      };
    }
  }
  return latestByPeer.values.toList();
});

/// كل الرسائل بين المستخدم الحالي ومالك معيّن
final conversationMessagesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, peerId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final data = await supabase
      .from('messages')
      .select()
      .or('and(sender_id.eq.${user.id},receiver_id.eq.$peerId),and(sender_id.eq.$peerId,receiver_id.eq.${user.id})')
      .order('created_at', ascending: true);
  return List<Map<String, dynamic>>.from(data as List);
});

class MessagesRepository {
  final Ref ref;
  MessagesRepository(this.ref);

  Future<void> sendMessage(String receiverId, String content) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('messages').insert({
      'sender_id': user.id,
      'receiver_id': receiverId,
      'content': content,
    });
    ref.invalidate(conversationMessagesProvider(receiverId));
    ref.invalidate(conversationsProvider);
  }
}

final messagesRepositoryProvider = Provider((ref) => MessagesRepository(ref));
