class NotificationModel {
  final String id;
  final String userId;
  final String iconKey;
  final String titleAr;
  final String titleEn;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.iconKey,
    required this.titleAr,
    required this.titleEn,
    required this.isRead,
    required this.createdAt,
  });

  String title(bool isArabic) => isArabic ? titleAr : titleEn;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      iconKey: json['icon_key'] as String? ?? 'info',
      titleAr: json['title_ar'] as String? ?? '',
      titleEn: json['title_en'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
