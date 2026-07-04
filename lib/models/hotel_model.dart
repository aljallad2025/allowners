class HotelModel {
  final String id;
  final String ownerId;
  final String name;
  final String cityAr;
  final String cityEn;
  final String typeAr;
  final String typeEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double rating;
  final int reviewsCount;
  final double pricePerNight;
  final int stars;
  final String imageUrl;
  final List<String> galleryUrls;
  final bool freeCancellation;
  final bool breakfastIncluded;
  final bool isFavorite;

  HotelModel({
    required this.id,
    this.ownerId = '',
    required this.name,
    required this.cityAr,
    required this.cityEn,
    required this.typeAr,
    required this.typeEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.rating,
    required this.reviewsCount,
    required this.pricePerNight,
    required this.stars,
    required this.imageUrl,
    this.galleryUrls = const [],
    this.freeCancellation = true,
    this.breakfastIncluded = false,
    this.isFavorite = false,
  });

  String city(bool isArabic) => isArabic ? cityAr : cityEn;
  String type(bool isArabic) => isArabic ? typeAr : typeEn;
  String? description(bool isArabic) => isArabic ? descriptionAr : descriptionEn;

  /// يبني الموديل من صف جدول hotels في Supabase.
  /// [galleryUrls] تُمرَّر من جدول hotel_images (استعلام منفصل).
  /// [isFavorite] تُحسب من جدول favorites الخاص بالمستخدم الحالي.
  factory HotelModel.fromJson(
    Map<String, dynamic> json, {
    List<String> galleryUrls = const [],
    bool isFavorite = false,
  }) {
    return HotelModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      cityAr: json['city_ar'] as String? ?? '',
      cityEn: json['city_en'] as String? ?? '',
      typeAr: json['type_ar'] as String? ?? 'فندق',
      typeEn: json['type_en'] as String? ?? 'Hotel',
      descriptionAr: json['description_ar'] as String?,
      descriptionEn: json['description_en'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      pricePerNight: (json['price_per_night'] as num?)?.toDouble() ?? 0,
      stars: (json['stars'] as num?)?.toInt() ?? 3,
      imageUrl: (json['cover_image_url'] as String?) ??
          (galleryUrls.isNotEmpty ? galleryUrls.first : ''),
      galleryUrls: galleryUrls,
      freeCancellation: json['free_cancellation'] as bool? ?? true,
      breakfastIncluded: json['breakfast_included'] as bool? ?? false,
      isFavorite: isFavorite,
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'owner_id': ownerId,
      'name': name,
      'city_ar': cityAr,
      'city_en': cityEn,
      'type_ar': typeAr,
      'type_en': typeEn,
      'description_ar': descriptionAr,
      'description_en': descriptionEn,
      'stars': stars,
      'price_per_night': pricePerNight,
      'free_cancellation': freeCancellation,
      'breakfast_included': breakfastIncluded,
      'cover_image_url': imageUrl,
    };
  }

  HotelModel copyWith({bool? isFavorite}) {
    return HotelModel(
      id: id,
      ownerId: ownerId,
      name: name,
      cityAr: cityAr,
      cityEn: cityEn,
      typeAr: typeAr,
      typeEn: typeEn,
      descriptionAr: descriptionAr,
      descriptionEn: descriptionEn,
      rating: rating,
      reviewsCount: reviewsCount,
      pricePerNight: pricePerNight,
      stars: stars,
      imageUrl: imageUrl,
      galleryUrls: galleryUrls,
      freeCancellation: freeCancellation,
      breakfastIncluded: breakfastIncluded,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
