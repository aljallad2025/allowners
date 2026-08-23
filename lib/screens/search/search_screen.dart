import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/session_provider.dart';
import '../../models/hotel_model.dart';
import '../../services/hotel_service.dart';
import '../hotel/hotel_details_screen.dart';
import 'filters_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  /// نص بحث ابتدائي (مثلاً اسم مدينة) يُطبّق فور فتح الشاشة
  final String? initialQuery;

  /// مفتاح تصنيف ابتدائي (hotels / apartments / resorts / chalets)
  /// يُستخدم لفلترة الفنادق حسب نوعها عند الوصول من الأصناف بالشاشة الرئيسية
  final String? initialCategoryKey;

  const SearchScreen({super.key, this.initialQuery, this.initialCategoryKey});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final HotelService _hotelService = HotelService();
  final TextEditingController _searchController = TextEditingController();

  // كلمات مفتاحية بالعربي/الإنجليزي لمطابقة نوع الفندق مع كل تصنيف
  static const Map<String, List<String>> _categoryKeywords = {
    'hotels': ['فندق', 'hotel'],
    'apartments': ['شقة', 'apartment'],
    'resorts': ['منتجع', 'resort'],
    'chalets': ['شاليه', 'chalet'],
  };

  List<HotelModel> _allHotels = [];
  List<HotelModel> _filteredHotels = [];
  bool _isLoading = true;
  String? _error;
  String? _activeCategoryKey;

  @override
  void initState() {
    super.initState();
    _activeCategoryKey = widget.initialCategoryKey;
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      _searchController.text = widget.initialQuery!.trim();
    }
    _loadHotels();
    _searchController.addListener(_applyFilter);
  }

  void _clearCategoryFilter() {
    setState(() {
      _activeCategoryKey = null;
    });
    _applyFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHotels() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final hotels = await _hotelService.listHotels();

      // نضيف علامة "مفضّل" لو المستخدم مسجّل دخول
      List<HotelModel> marked = hotels;
      if (ref.read(sessionProvider).isLoggedIn) {
        try {
          final favorites = await _hotelService.myFavorites();
          final favIds = favorites.map((h) => h.id).toSet();
          marked = hotels.map((h) => h.copyWith(isFavorite: favIds.contains(h.id))).toList();
        } catch (_) {
          // تجاهل فشل جلب المفضلة، الأهم عرض النتائج
        }
      }

      if (!mounted) return;
      setState(() {
        _allHotels = marked;
        _isLoading = false;
      });
      _applyFilter();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    final categoryKeywords = _activeCategoryKey != null
        ? (_categoryKeywords[_activeCategoryKey] ?? const [])
        : const <String>[];

    setState(() {
      _filteredHotels = _allHotels.where((h) {
        final matchesQuery = query.isEmpty ||
            h.name.toLowerCase().contains(query) ||
            h.cityAr.toLowerCase().contains(query) ||
            h.cityEn.toLowerCase().contains(query);

        final matchesCategory = categoryKeywords.isEmpty ||
            categoryKeywords.any((kw) =>
                h.typeAr.toLowerCase().contains(kw.toLowerCase()) ||
                h.typeEn.toLowerCase().contains(kw.toLowerCase()));

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  Future<void> _toggleFavorite(HotelModel hotel) async {
    if (!ref.read(sessionProvider).isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          ref.read(localeProvider).languageCode == 'ar'
              ? 'الرجاء تسجيل الدخول أولاً'
              : 'Please log in first',
        )),
      );
      return;
    }
    try {
      final favorited = await _hotelService.toggleFavorite(hotel.id);
      setState(() {
        _allHotels = _allHotels.map((h) => h.id == hotel.id ? h.copyWith(isFavorite: favorited) : h).toList();
        _filteredHotels =
            _filteredHotels.map((h) => h.id == hotel.id ? h.copyWith(isFavorite: favorited) : h).toList();
      });
    } catch (_) {}
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final hotels = _filteredHotels;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: AppStrings.t(isArabic, 'search_destination'),
                          filled: false,
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  InkWell(
                    onTap: _openFilters,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.ink,
                        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                      ),
                      child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            if (_activeCategoryKey != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                child: Align(
                  alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                  child: Chip(
                    label: Text(AppStrings.t(isArabic, _activeCategoryKey!)),
                    backgroundColor: AppColors.ink.withOpacity(0.06),
                    deleteIcon: const Icon(Icons.close_rounded, size: 16),
                    onDeleted: _clearCategoryFilter,
                  ),
                ),
              ),
            const SizedBox(height: AppDimens.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
              child: Row(
                children: [
                  Text('${hotels.length} ${AppStrings.t(isArabic, "results_found")}',
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  const Spacer(),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(AppStrings.t(isArabic, 'sort_by'), style: textTheme.bodyMedium),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.sm),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.gold),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, style: textTheme.bodyMedium, textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              TextButton(onPressed: _loadHotels, child: Text(isArabic ? 'إعادة المحاولة' : 'Retry')),
                            ],
                          ),
                        )
                      : hotels.isEmpty
                          ? Center(
                              child: Text(
                                AppStrings.t(isArabic, 'no_results'),
                                style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
                              itemCount: hotels.length,
                              itemBuilder: (context, index) {
                                final hotel = hotels[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: AppDimens.md),
                                  child: _SearchResultCard(
                                    hotel: hotel,
                                    isArabic: isArabic,
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => HotelDetailsScreen(hotel: hotel)),
                                      );
                                    },
                                    onFavoriteTap: () => _toggleFavorite(hotel),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final HotelModel hotel;
  final bool isArabic;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;

  const _SearchResultCard({
    required this.hotel,
    required this.isArabic,
    required this.onTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.sm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 100,
              height: 100,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: CachedNetworkImage(
                imageUrl: hotel.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  ),
                ),
                errorWidget: (context, url, error) =>
                    Icon(Icons.image_outlined, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(width: AppDimens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(hotel.name,
                            style: textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      InkWell(
                        onTap: onFavoriteTap,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            hotel.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 18,
                            color: hotel.isFavorite ? AppColors.danger : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: List.generate(
                      hotel.stars,
                      (i) => const Icon(Icons.star_rounded, size: 12, color: AppColors.goldDark),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 2),
                      Text(hotel.city(isArabic),
                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                  const Spacer(),
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
                            const Icon(Icons.star_rounded, size: 12, color: AppColors.secondary),
                            Text(' ${hotel.rating} ',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.secondary)),
                            Text('(${hotel.reviewsCount})',
                                style: const TextStyle(fontSize: 10, color: AppColors.secondary)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text('${hotel.pricePerNight.toInt()} ${AppStrings.t(isArabic, "sar")}',
                          style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
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
