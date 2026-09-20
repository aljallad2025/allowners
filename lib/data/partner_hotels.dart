/// بيانات ثابتة للصفحة الرئيسية: المدن الرئيسية + قسم «فنادق بوحدات ملاك».
///
/// لتفعيل فندق جديد: غيّر `available: true` وحدّد `searchQuery` (نص يطابق اسم
/// الفندق في السيرفر حتى تظهر وحداته عند الضغط على البطاقة).
class HomeCity {
  final String key; // makkah | madinah | jeddah | riyadh
  final String emoji;
  final String nameKey; // مفتاح النص في AppStrings
  final String queryAr;
  final String queryEn;

  const HomeCity({
    required this.key,
    required this.emoji,
    required this.nameKey,
    required this.queryAr,
    required this.queryEn,
  });

  String query(bool isArabic) => isArabic ? queryAr : queryEn;
}

class PartnerHotel {
  final String cityKey;
  final String nameAr;
  final String nameEn;
  final bool available;
  final String searchQuery;

  const PartnerHotel({
    required this.cityKey,
    required this.nameAr,
    required this.nameEn,
    this.available = false,
    this.searchQuery = '',
  });

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
}

const List<HomeCity> kHomeCities = [
  HomeCity(key: 'makkah', emoji: '🕋', nameKey: 'city_makkah', queryAr: 'مكة', queryEn: 'Makkah'),
  HomeCity(key: 'jeddah', emoji: '🌊', nameKey: 'city_jeddah', queryAr: 'جدة', queryEn: 'Jeddah'),
  HomeCity(key: 'madinah', emoji: '🕌', nameKey: 'city_madinah', queryAr: 'المدينة', queryEn: 'Madinah'),
  HomeCity(key: 'riyadh', emoji: '🏙️', nameKey: 'city_riyadh', queryAr: 'الرياض', queryEn: 'Riyadh'),
];

const List<PartnerHotel> kPartnerHotels = [
  // ===== مكة =====
  PartnerHotel(
    cityKey: 'makkah',
    nameAr: 'فندق فيرمونت مكة إعمار رزيدنسر',
    nameEn: 'Fairmont Makkah Hotel Emaar Residences',
    available: true,
    searchQuery: 'فيرمونت',
  ),
  PartnerHotel(cityKey: 'makkah', nameAr: 'رافلز', nameEn: 'Raffles'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'جبل عمر أدريس', nameEn: 'Jabal Omar Address'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'أجنحة هيلتون', nameEn: 'Hilton Suites'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'كونراد', nameEn: 'Conrad'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'حياة ريجنسي', nameEn: 'Hyatt Regency'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'نوفتيل ذاخر', nameEn: 'Novotel Thakher'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'بولمان زمزم', nameEn: 'Zamzam Pullman'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'موفنبيك', nameEn: 'Movenpick'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'المروة ريحان من روتانا', nameEn: 'Al Marwa Rayhaan By Rotana'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'الصفوة أوركيد', nameEn: 'Al Safwah Orchid'),
  PartnerHotel(cityKey: 'makkah', nameAr: 'دبل تري هيلتون', nameEn: 'Double Hilton Tree'),

  // ===== المدينة =====
  PartnerHotel(cityKey: 'madinah', nameAr: 'فيرمونت ريزيدنسز', nameEn: 'Fairmont Residences'),

  // ===== جدة =====
  PartnerHotel(cityKey: 'jeddah', nameAr: 'فور سيزونز برايفت ريزيدنسز', nameEn: 'Four Seasons Private Residences'),
  PartnerHotel(cityKey: 'jeddah', nameAr: 'برج الجوهرة داماك', nameEn: 'Damac Al Jawharah Tower'),

  // ===== الرياض =====
  PartnerHotel(cityKey: 'riyadh', nameAr: 'ذا لانغهام ريزيدنسز', nameEn: 'The Langham Residences'),
];
