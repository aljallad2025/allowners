import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'auth_provider.dart';

class ProfileMutationsRepository {
  final Ref ref;
  ProfileMutationsRepository(this.ref);

  Future<String> uploadAvatar(File file, String userId) async {
    final ext = file.path.split('.').last;
    final path = '$userId/avatar.$ext';
    await supabase.storage.from('avatars').upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
        );
    final url = supabase.storage.from('avatars').getPublicUrl(path);
    // كسر الكاش عشان تظهر الصورة الجديدة فوراً بدل نسخة قديمة محفوظة بذاكرة الجهاز
    return '$url?t=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
    final updates = <String, dynamic>{'full_name': fullName};
    if (phone != null) updates['phone'] = phone.isEmpty ? null : phone;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    await supabase.from('profiles').update(updates).eq('id', user.id);
    ref.invalidate(currentProfileProvider);
  }
}

final profileMutationsProvider = Provider((ref) => ProfileMutationsRepository(ref));
