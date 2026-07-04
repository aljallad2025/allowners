enum BookingStatus { upcoming, completed, cancelled }

BookingStatus bookingStatusFromString(String? value) {
  switch (value) {
    case 'completed':
      return BookingStatus.completed;
    case 'cancelled':
      return BookingStatus.cancelled;
    default:
      return BookingStatus.upcoming;
  }
}

class BookingModel {
  final String id;
  final String guestId;
  final String hotelId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestsCount;
  final int nights;
  final double roomPrice;
  final double taxes;
  final double totalPrice;
  final String paymentMethod;
  final BookingStatus status;
  final DateTime createdAt;

  // بيانات الفندق المرفقة (من join) لعرضها بسهولة بشاشة حجوزاتي
  final String hotelName;
  final String hotelCityAr;
  final String hotelCityEn;
  final String hotelImageUrl;

  BookingModel({
    required this.id,
    required this.guestId,
    required this.hotelId,
    required this.checkIn,
    required this.checkOut,
    required this.guestsCount,
    required this.nights,
    required this.roomPrice,
    required this.taxes,
    required this.totalPrice,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.hotelName = '',
    this.hotelCityAr = '',
    this.hotelCityEn = '',
    this.hotelImageUrl = '',
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final hotel = json['hotels'] as Map<String, dynamic>?;
    return BookingModel(
      id: json['id'] as String,
      guestId: json['guest_id'] as String,
      hotelId: json['hotel_id'] as String,
      checkIn: DateTime.parse(json['check_in'] as String),
      checkOut: DateTime.parse(json['check_out'] as String),
      guestsCount: (json['guests_count'] as num?)?.toInt() ?? 1,
      nights: (json['nights'] as num?)?.toInt() ?? 1,
      roomPrice: (json['room_price'] as num).toDouble(),
      taxes: (json['taxes'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String? ?? 'online',
      status: bookingStatusFromString(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      hotelName: hotel?['name'] as String? ?? '',
      hotelCityAr: hotel?['city_ar'] as String? ?? '',
      hotelCityEn: hotel?['city_en'] as String? ?? '',
      hotelImageUrl: hotel?['cover_image_url'] as String? ?? '',
    );
  }
}
