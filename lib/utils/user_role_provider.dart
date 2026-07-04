import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';

export '../models/profile_model.dart' show UserRole;

/// يُستخدم فقط لتتبّع اختيار المستخدم (ضيف/مالك) أثناء تعبئة نموذج
/// تسجيل الدخول أو إنشاء الحساب قبل إرساله لـ Supabase.
class UserRoleNotifier extends StateNotifier<UserRole> {
  UserRoleNotifier() : super(UserRole.guest);

  void setRole(UserRole role) => state = role;
}

final userRoleProvider = StateNotifierProvider<UserRoleNotifier, UserRole>(
  (ref) => UserRoleNotifier(),
);
