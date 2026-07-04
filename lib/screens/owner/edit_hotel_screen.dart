import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/hotel_model.dart';
import '../../providers/owner_hotel_mutations_provider.dart';

class EditHotelScreen extends ConsumerStatefulWidget {
  final HotelModel hotel;
  const EditHotelScreen({super.key, required this.hotel});

  @override
  ConsumerState<EditHotelScreen> createState() => _EditHotelScreenState();
}

class _EditHotelScreenState extends ConsumerState<EditHotelScreen> {
  static const _propertyTypes = [
    (key: 'hotels', typeAr: 'فندق', typeEn: 'Hotel'),
    (key: 'apartments', typeAr: 'شقة فندقية', typeEn: 'Apartment'),
    (key: 'resorts', typeAr: 'منتجع', typeEn: 'Resort'),
    (key: 'chalets', typeAr: 'شاليه', typeEn: 'Chalet'),
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _cityArController;
  late final TextEditingController _cityEnController;
  late final TextEditingController _priceController;
  late final TextEditingController _descArController;
  late final TextEditingController _descEnController;
  late int _stars;
  late String _typeKey;
  late bool _freeCancellation;
  late bool _breakfastIncluded;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final h = widget.hotel;
    _nameController = TextEditingController(text: h.name);
    _cityArController = TextEditingController(text: h.cityAr);
    _cityEnController = TextEditingController(text: h.cityEn);
    _priceController = TextEditingController(text: h.pricePerNight.toStringAsFixed(0));
    _descArController = TextEditingController(text: h.descriptionAr ?? '');
    _descEnController = TextEditingController(text: h.descriptionEn ?? '');
    _stars = h.stars;
    _typeKey = _propertyTypes
        .firstWhere((t) => t.typeAr == h.typeAr, orElse: () => _propertyTypes.first)
        .key;
    _freeCancellation = h.freeCancellation;
    _breakfastIncluded = h.breakfastIncluded;
  }

  Future<void> _submit() async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    final price = double.tryParse(_priceController.text.trim());
    if (_nameController.text.trim().isEmpty || price == null) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'fill_all_fields'));
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final selectedType = _propertyTypes.firstWhere((t) => t.key == _typeKey);
      await ref.read(ownerHotelMutationsProvider).updateHotel(
            hotelId: widget.hotel.id,
            name: _nameController.text.trim(),
            cityAr: _cityArController.text.trim(),
            cityEn: _cityEnController.text.trim(),
            typeAr: selectedType.typeAr,
            typeEn: selectedType.typeEn,
            descriptionAr: _descArController.text.trim().isEmpty ? null : _descArController.text.trim(),
            descriptionEn: _descEnController.text.trim().isEmpty ? null : _descEnController.text.trim(),
            stars: _stars,
            pricePerNight: price,
            freeCancellation: _freeCancellation,
            breakfastIncluded: _breakfastIncluded,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'something_went_wrong'));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityArController.dispose();
    _cityEnController.dispose();
    _priceController.dispose();
    _descArController.dispose();
    _descEnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'edit'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.t(isArabic, 'hotel_name'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(controller: _nameController),
              const SizedBox(height: AppDimens.md),

              Text(AppStrings.t(isArabic, 'property_type'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              Wrap(
                spacing: AppDimens.sm,
                runSpacing: AppDimens.sm,
                children: _propertyTypes.map((t) {
                  final selected = _typeKey == t.key;
                  return InkWell(
                    onTap: () => setState(() => _typeKey = t.key),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.ink : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                      ),
                      child: Text(
                        AppStrings.t(isArabic, t.key),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimens.md),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.t(isArabic, 'city_ar'), style: textTheme.titleSmall),
                        const SizedBox(height: AppDimens.sm),
                        TextField(controller: _cityArController),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.t(isArabic, 'city_en'), style: textTheme.titleSmall),
                        const SizedBox(height: AppDimens.sm),
                        TextField(controller: _cityEnController, textDirection: TextDirection.ltr),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),

              Text(AppStrings.t(isArabic, 'price_per_night'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(suffixText: AppStrings.t(isArabic, 'sar')),
              ),
              const SizedBox(height: AppDimens.md),

              Text(AppStrings.t(isArabic, 'star_rating'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              Row(
                children: List.generate(5, (i) {
                  final starValue = i + 1;
                  return IconButton(
                    onPressed: () => setState(() => _stars = starValue),
                    icon: Icon(
                      starValue <= _stars ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.goldDark,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppDimens.md),

              Text(AppStrings.t(isArabic, 'description_ar'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(controller: _descArController, maxLines: 3),
              const SizedBox(height: AppDimens.md),

              Text(AppStrings.t(isArabic, 'description_en'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(controller: _descEnController, maxLines: 3, textDirection: TextDirection.ltr),
              const SizedBox(height: AppDimens.md),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppStrings.t(isArabic, 'free_cancellation')),
                value: _freeCancellation,
                onChanged: (v) => setState(() => _freeCancellation = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppStrings.t(isArabic, 'breakfast_included')),
                value: _breakfastIncluded,
                onChanged: (v) => setState(() => _breakfastIncluded = v),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: AppDimens.lg),

              SizedBox(
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(AppStrings.t(isArabic, 'save')),
                ),
              ),
              const SizedBox(height: AppDimens.lg),
            ],
          ),
        ),
      ),
    );
  }
}
