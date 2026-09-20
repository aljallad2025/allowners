import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/partner_hotels.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/session_provider.dart';
import '../../services/hotel_service.dart';
import '../search/search_screen.dart';
import '../unit/unit_details_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final HotelService _hotelService = HotelService();
  List<Map<String, dynamic>> _units = [];
  bool _isLoading = true;
  String? _error;
  String _sort = 'newest';
  String _hotelsCity = 'makkah';

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final units = await _hotelService.browseUnits(sort: _sort, limit: 12);
      if (!mounted) return;
      setState(() {
        _units = units;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _openSearch({String? query}) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SearchScreen(initialQuery: query)),
    );
  }

  void _onHotelTap(PartnerHotel hotel, bool isArabic) {
    if (hotel.available) {
      _openSearch(query: hotel.searchQuery);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${hotel.name(isArabic)} — ${AppStrings.t(isArabic, 'hotel_soon_msg')}'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final userName = ref.watch(sessionProvider).user?.fullName.split(' ').first;
    final units = _units;

    // 'label' = اسم التصنيف المعروض، 'query' = كلمة البحث المرسلة للسيرفر (بقيت كما كانت قبل التعديل)
    final categories = [
      {'icon': Icons.king_bed_outlined, 'label': 'cat_hotel_units', 'query': 'hotels', 'color': AppColors.ink},
      {'icon': Icons.apartment_rounded, 'label': 'cat_furnished', 'query': 'apartments', 'color': AppColors.secondary},
      {'icon': Icons.beach_access_rounded, 'label': 'resorts', 'query': 'resorts', 'color': AppColors.goldDark},
      {'icon': Icons.cabin_outlined, 'label': 'chalets', 'query': 'chalets', 'color': AppColors.success},
      {'icon': Icons.home_work_outlined, 'label': 'cat_properties', 'query': 'cat_properties', 'color': AppColors.inkLight},
    ];

    final hotelsInCity = kPartnerHotels.where((h) => h.cityKey == _hotelsCity).toList();

    final greeting = userName != null
        ? '${AppStrings.t(isArabic, 'greet_hello')}${isArabic ? '،' : ','} $userName 👋'
        : '${AppStrings.t(isArabic, 'greet_welcome')} 👋';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ===== Header: ترحيب + شعار AO (مكبّر ~18%) =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePadding, AppDimens.md, AppDimens.pagePadding, 0),
                child: Row(
                  children: [
                    Image.asset('assets/images/logo.png', width: 52),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(greeting, style: textTheme.titleMedium),
                          Text(
                            AppStrings.t(isArabic, 'where_to'),
                            style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surfaceMuted,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Search bar (العنصر الرئيسي في الصفحة) =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppDimens.pagePadding, AppDimens.md, AppDimens.pagePadding, AppDimens.md),
                child: InkWell(
                  onTap: () => _openSearch(),
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.gold.withOpacity(0.7), width: 1.4),
                      boxShadow: AppColors.elevatedShadow,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.goldDark, size: 26),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Text(
                            AppStrings.t(isArabic, 'search_destination'),
                            style: textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            gradient: AppColors.goldGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ===== الوجهات الرئيسية =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                child: Text(AppStrings.t(isArabic, 'main_destinations'), style: textTheme.titleMedium),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.sm)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                child: Row(
                  children: [
                    for (int i = 0; i < kHomeCities.length; i++) ...[
                      if (i != 0) const SizedBox(width: AppDimens.sm),
                      Expanded(
                        child: _CityTile(
                          emoji: kHomeCities[i].emoji,
                          label: AppStrings.t(isArabic, kHomeCities[i].nameKey),
                          onTap: () => _openSearch(query: kHomeCities[i].query(isArabic)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.lg)),

            // ===== اكتشف حسب النوع =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                child: Text(AppStrings.t(isArabic, 'discover_by_type'), style: textTheme.titleMedium),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.sm)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 104,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Padding(
                      padding: const EdgeInsetsDirectional.only(end: AppDimens.sm),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                        onTap: () => _openSearch(
                          query: AppStrings.t(isArabic, cat['query'] as String),
                        ),
                        child: SizedBox(
                          width: 82,
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: (cat['color'] as Color).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                                ),
                                child: Icon(cat['icon'] as IconData, color: cat['color'] as Color),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.t(isArabic, cat['label'] as String),
                                style: textTheme.labelSmall,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.sm)),

            // ===== فنادق بوحدات ملاك (قسم بارز) =====
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
                decoration: BoxDecoration(
                  gradient: AppColors.heroDarkGradient,
                  borderRadius: BorderRadius.circular(AppDimens.radiusXl),
                  boxShadow: AppColors.elevatedShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_rounded, color: AppColors.gold, size: 22),
                              const SizedBox(width: AppDimens.sm),
                              Expanded(
                                child: Text(
                                  AppStrings.t(isArabic, 'owner_hotels'),
                                  style: textTheme.headlineSmall?.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppStrings.t(isArabic, 'owner_hotels_desc'),
                            style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                        children: [
                          for (final city in kHomeCities)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: AppDimens.sm),
                              child: _DarkChip(
                                label: AppStrings.t(isArabic, city.nameKey),
                                selected: _hotelsCity == city.key,
                                onTap: () => setState(() => _hotelsCity = city.key),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.md),
                    SizedBox(
                      height: 138,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                        itemCount: hotelsInCity.length,
                        itemBuilder: (context, index) {
                          final hotel = hotelsInCity[index];
                          return Padding(
                            padding: const EdgeInsetsDirectional.only(end: AppDimens.sm),
                            child: _PartnerHotelCard(
                              name: hotel.name(isArabic),
                              cityLabel: AppStrings.t(isArabic, 'city_${hotel.cityKey}'),
                              available: hotel.available,
                              availableLabel: AppStrings.t(isArabic, 'hotel_available'),
                              soonLabel: AppStrings.t(isArabic, 'hotel_soon'),
                              onTap: () => _onHotelTap(hotel, isArabic),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.lg)),

            // ===== أحدث الوحدات =====
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(AppStrings.t(isArabic, 'newest_units'), style: textTheme.headlineSmall),
                    TextButton(
                      onPressed: () => _openSearch(),
                      child: Text(AppStrings.t(isArabic, 'see_all')),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                child: Row(
                  children: [
                    _SortChip(
                      label: AppStrings.t(isArabic, 'sort_newest'),
                      selected: _sort == 'newest',
                      onTap: () {
                        setState(() => _sort = 'newest');
                        _loadUnits();
                      },
                    ),
                    const SizedBox(width: AppDimens.sm),
                    _SortChip(
                      label: AppStrings.t(isArabic, 'sort_price_asc'),
                      selected: _sort == 'price_asc',
                      onTap: () {
                        setState(() => _sort = 'price_asc');
                        _loadUnits();
                      },
                    ),
                    const SizedBox(width: AppDimens.sm),
                    _SortChip(
                      label: AppStrings.t(isArabic, 'sort_capacity'),
                      selected: _sort == 'capacity',
                      onTap: () {
                        setState(() => _sort = 'capacity');
                        _loadUnits();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.sm)),
            // بطاقات الوحدات مباشرة تحت الفلاتر — بدون مساحة بيضاء زائدة
            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: _isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.gold),
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_error!, style: textTheme.bodySmall, textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _loadUnits,
                                  child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                                ),
                              ],
                            ),
                          )
                        : units.isEmpty
                            ? Center(
                                child: Text(
                                  AppStrings.t(isArabic, 'no_units'),
                                  style: textTheme.bodySmall,
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                                itemCount: units.length,
                                itemBuilder: (context, index) {
                                  final unit = units[index];
                                  return Padding(
                                    padding: const EdgeInsetsDirectional.only(end: AppDimens.md),
                                    child: _UnitCard(
                                      unit: unit,
                                      isArabic: isArabic,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => UnitDetailsScreen(unitId: unit['id'] as int),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppDimens.lg)),
          ],
        ),
      ),
    );
  }
}

class _CityTile extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;
  const _CityTile({required this.emoji, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DarkChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold : Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.ink : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _PartnerHotelCard extends StatelessWidget {
  final String name;
  final String cityLabel;
  final bool available;
  final String availableLabel;
  final String soonLabel;
  final VoidCallback onTap;

  const _PartnerHotelCard({
    required this.name,
    required this.cityLabel,
    required this.available,
    required this.availableLabel,
    required this.soonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final badgeColor = available ? AppColors.success : AppColors.goldDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.apartment_rounded, size: 18, color: AppColors.goldDark),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Text(
                    available ? availableLabel : soonLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                name,
                style: textTheme.titleSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                const SizedBox(width: 2),
                Text(cityLabel, style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.gold.withOpacity(0.15) : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          border: Border.all(color: selected ? AppColors.gold : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.goldDark : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _UnitCard extends StatelessWidget {
  final Map<String, dynamic> unit;
  final bool isArabic;
  final VoidCallback onTap;

  const _UnitCard({required this.unit, required this.isArabic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = isArabic ? (unit['name_ar']?.toString() ?? '') : (unit['name_en']?.toString() ?? '');
    final hotelName = unit['hotel_name']?.toString() ?? '';
    final price = (unit['price_per_night'] as num?)?.toInt() ?? 0;
    final capacity = unit['capacity'] ?? 1;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
              child: CachedNetworkImage(
                imageUrl: unit['cover_image']?.toString() ?? '',
                height: 130,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 130,
                  color: AppColors.surfaceMuted,
                  child: const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 130,
                  color: AppColors.surfaceMuted,
                  child: Icon(Icons.image_outlined, color: AppColors.textMuted, size: 36),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimens.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(hotelName,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.people_outline_rounded, size: 12, color: AppColors.secondary),
                            Text(' $capacity',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$price ${AppStrings.t(isArabic, "sar")}',
                        style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark),
                      ),
                      Text(AppStrings.t(isArabic, 'per_night'),
                          style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
