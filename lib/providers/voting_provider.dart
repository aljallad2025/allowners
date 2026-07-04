import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import 'auth_provider.dart';

final decisionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final data = await supabase
      .from('decisions')
      .select('*, profiles(full_name)')
      .order('created_at', ascending: false);
  return List<Map<String, dynamic>>.from(data as List);
});

/// نتائج التصويت (عدد نعم/لا) لقرار معيّن + تصويت المستخدم الحالي إن وجد
final decisionVotesProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, decisionId) async {
  final user = ref.watch(currentUserProvider);
  final data = await supabase.from('decision_votes').select().eq('decision_id', decisionId);
  final votes = List<Map<String, dynamic>>.from(data as List);
  final yes = votes.where((v) => v['vote'] == 'yes').length;
  final no = votes.where((v) => v['vote'] == 'no').length;
  String? myVote;
  if (user != null) {
    final mine = votes.where((v) => v['owner_id'] == user.id).toList();
    myVote = mine.isNotEmpty ? mine.first['vote'] as String : null;
  }
  return {'yes': yes, 'no': no, 'my_vote': myVote};
});

class VotingRepository {
  final Ref ref;
  VotingRepository(this.ref);

  Future<void> createDecision(String title, String? description) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('decisions').insert({
      'created_by': user.id,
      'title': title,
      'description': description,
    });
    ref.invalidate(decisionsProvider);
  }

  Future<void> vote(String decisionId, String vote) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    await supabase.from('decision_votes').upsert({
      'decision_id': decisionId,
      'owner_id': user.id,
      'vote': vote,
    }, onConflict: 'decision_id,owner_id');
    ref.invalidate(decisionVotesProvider(decisionId));
  }
}

final votingRepositoryProvider = Provider((ref) => VotingRepository(ref));
