import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { owner, guest }

class UserRoleNotifier extends StateNotifier<UserRole> {
  UserRoleNotifier() : super(UserRole.guest);

  void setRole(UserRole role) => state = role;
}

final userRoleProvider = StateNotifierProvider<UserRoleNotifier, UserRole>(
  (ref) => UserRoleNotifier(),
);