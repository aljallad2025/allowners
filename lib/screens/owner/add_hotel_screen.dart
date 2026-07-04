import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/owner_hotel_mutations_provider.dart';

class AddHotelScreen extends ConsumerStatefulWidget {
  const AddHotelScreen({super.key});

  @override
  ConsumerState<AddHotelScreen> createState() => _AddHotelScreenState();
}

class _AddHotelScreenState extends ConsumerState<AddHotelScreen> {
  static const _propertyTypes = [
    (key: 'hotels', typeAr: 'فندق', typeEn: 'Hotel'),
    (key: 'apartments', typeAr: 'شقة فندقية', typeEn: 'Apartment'),
    (key: 'resorts', typeAr: 'منتجع', typeEn: 'Resort'),
    (key: 'chalets', typeAr: 'شاليه', typeEn: 'Chalet'),
  ];

  final _nameController = TextEditingController();
  final _cityArController = TextEditingController();
  final _cityEnController = TextEditingController();
  final _priceController = TextEditingController();
  final _descArController = TextEditingController();
  final _descEnController = TextEditingController();
  int _stars = 3;
  String _typeKey = 'hotels';
  bool _freeCancellation = true;
  bool _breakfastIncluded = false;
  File? _coverImage;
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _coverImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    if (_nameController.text.trim().isEmpty ||
        _cityArController.text.trim().isEmpty ||
        _cityEnController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'fill_all_fields'));
      return;
    }
    final price = double.tryParse(_priceController.text.trim());
    if (price == null) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'invalid_price'));
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(ownerHotelMutationsProvider);
      String? coverUrl;
      final selectedType = _propertyTypes.firstWhere((t) => t.key == _typeKey);
      final hotelId = await repo.createHotel(
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

      if (_coverImage != null) {
        coverUrl = await repo.uploadHotelImage(_coverImage!, hotelId);
        await repo.addHotelImage(hotelId, coverUrl, 0);
        await repo.updateHotelCoverImage(hotelId, coverUrl);
      }

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
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'add_hotel'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
                onTap: _pickImage,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                child: Container(
                  height: 160,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: _coverImage != null
                      ? Image.file(_coverImage!, fit: BoxFit.cover)
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_outlined,
                                size: 36, color: AppColors.textMuted),
                            const SizedBox(height: 6),
                            Text(AppStrings.t(isArabic, 'add_cover_photo'),
                                style: const TextStyle(color: AppColors.textMuted)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppDimens.lg),

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
