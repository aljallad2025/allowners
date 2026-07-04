enum UserRole { guest, owner }

UserRole userRoleFromString(String? value) {
  return value == 'owner' ? UserRole.owner : UserRole.guest;
}

String userRoleToString(UserRole role) => role == UserRole.owner ? 'owner' : 'guest';

class ProfileModel {
  final String id;
  final String fullName;
  final String? phone;
  final String? email;
  final UserRole role;
  final String? avatarUrl;

  ProfileModel({
    required this.id,
    required this.fullName,
    this.phone,
    this.email,
    required this.role,
    this.avatarUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      role: userRoleFromString(json['role'] as String?),
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
