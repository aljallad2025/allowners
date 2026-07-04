class UnitModel {
  final String id;
  final String hotelId;
  final String ownerId;
  final String name;
  final bool occupied;
  final double monthlyRevenue;

  // اسم الفندق المرفق من join
  final String hotelName;

  UnitModel({
    required this.id,
    required this.hotelId,
    required this.ownerId,
    required this.name,
    required this.occupied,
    required this.monthlyRevenue,
    this.hotelName = '',
  });

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    final hotel = json['hotels'] as Map<String, dynamic>?;
    return UnitModel(
      id: json['id'] as String,
      hotelId: json['hotel_id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String? ?? '',
      occupied: (json['status'] as String?) == 'occupied',
      monthlyRevenue: (json['monthly_revenue'] as num?)?.toDouble() ?? 0,
      hotelName: hotel?['name'] as String? ?? '',
    );
  }
}
