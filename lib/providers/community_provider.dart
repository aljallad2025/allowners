import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'auth_provider.dart';

final communityPostsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await supabase
      .from('community_posts')
      .select('*, profiles(full_name, avatar_url)')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data as List);
});

final postRepliesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, postId) async {
  final data = await supabase
      .from('community_replies')
      .select('*, profiles(full_name)')
      .eq('post_id', postId)
      .order('created_at', ascending: true);
  return List<Map<String, dynamic>>.from(data as List);
});

class CommunityRepository {
  final Ref ref;
  CommunityRepository(this.ref);

  Future<void> createPost(String content) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('community_posts').insert({'owner_id': user.id, 'content': content});
    ref.invalidate(communityPostsProvider);
  }

  Future<void> addReply(String postId, String content) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('community_replies').insert({
      'post_id': postId,
      'owner_id': user.id,
      'content': content,
    });
    ref.invalidate(postRepliesProvider(postId));
  }

  Future<void> deletePost(String postId) async {
    await supabase.from('community_posts').delete().eq('id', postId);
    ref.invalidate(communityPostsProvider);
  }
}

final communityRepositoryProvider = Provider((ref) => CommunityRepository(ref));
