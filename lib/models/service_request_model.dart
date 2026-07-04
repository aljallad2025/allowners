class ServiceRequestModel {
  final String id;
  final String guestId;
  final String hotelId;
  final String? bookingId;
  final String serviceType;
  final String roomNumber;
  final String? details;
  final String status;
  final DateTime createdAt;

  ServiceRequestModel({
    required this.id,
    required this.guestId,
    required this.hotelId,
    this.bookingId,
    required this.serviceType,
    required this.roomNumber,
    this.details,
    required this.status,
    required this.createdAt,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id'] as String,
      guestId: json['guest_id'] as String,
      hotelId: json['hotel_id'] as String,
      bookingId: json['booking_id'] as String?,
      serviceType: json['service_type'] as String? ?? '',
      roomNumber: json['room_number'] as String? ?? '',
      details: json['details'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class MealRequestModel {
  final String id;
  final String guestId;
  final String hotelId;
  final String? bookingId;
  final String meal;
  final String? notes;
  final String status;
  final DateTime createdAt;

  MealRequestModel({
    required this.id,
    required this.guestId,
    required this.hotelId,
    this.bookingId,
    required this.meal,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory MealRequestModel.fromJson(Map<String, dynamic> json) {
    return MealRequestModel(
      id: json['id'] as String,
      guestId: json['guest_id'] as String,
      hotelId: json['hotel_id'] as String,
      bookingId: json['booking_id'] as String?,
      meal: json['meal'] as String? ?? '',
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
