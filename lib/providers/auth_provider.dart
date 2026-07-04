import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/profile_model.dart';

/// يبث تغيّرات حالة الجلسة (دخول/خروج) فور حدوثها
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

/// المستخدم الحالي (null لو ماكو جلسة)
final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateProvider);
  return supabase.auth.currentUser;
});

/// بروفايل المستخدم الحالي من جدول profiles
final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final data = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
  if (data == null) return null;
  return ProfileModel.fromJson(data);
});

class AuthRepository {
  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required UserRole role,
  }) async {
    await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
        'role': userRoleToString(role),
      },
    );
    // في حال كان تأكيد البريد مفعّل، signUp ما يرجع جلسة فوراً.
    // نحاول تسجيل دخول مباشر بعد التسجيل (يشتغل فقط لو Confirm email معطّل من إعدادات Supabase).
    if (supabase.auth.currentSession == null) {
      try {
        await supabase.auth.signInWithPassword(email: email, password: password);
      } catch (_) {
        // يتطلب تأكيد البريد أولاً - يُترك للمستخدم يسجل دخول لاحقاً
      }
    }
  }

  Future<void> resetPassword({required String email}) async {
    await supabase.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}

final authRepositoryProvider = Provider((ref) => AuthRepository());
