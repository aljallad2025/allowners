class AppUser {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String role; // guest | owner | admin
  final String? avatarUrl;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'guest',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'role': role,
        'avatar_url': avatarUrl,
      };

  bool get isOwner => role == 'owner';
  bool get isBookingAgent => role == 'booking_agent';
  bool get isHotelManager => role == 'hotel_manager';
  bool get isAdmin => role == 'admin';

  /// أي حساب يستخدم بوابة المالك (مالك نفسه أو موظف تابع له)
  bool get usesOwnerPortal => isOwner || isBookingAgent || isHotelManager;
}
