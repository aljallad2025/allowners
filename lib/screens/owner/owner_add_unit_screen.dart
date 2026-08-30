import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../services/owner_service.dart';
import '../../services/api_client.dart';

class OwnerAddUnitScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> hotels;

  const OwnerAddUnitScreen({super.key, required this.hotels});

  @override
  ConsumerState<OwnerAddUnitScreen> createState() => _OwnerAddUnitScreenState();
}

class _OwnerAddUnitScreenState extends ConsumerState<OwnerAddUnitScreen> {
  final _service = OwnerService();
  final _formKey = GlobalKey<FormState>();

  final _nameArCtrl = TextEditingController();
  final _nameEnCtrl = TextEditingController();
  final _unitNumberCtrl = TextEditingController();
  final _descArCtrl = TextEditingController();
  final _descEnCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '2');
  final _priceNightCtrl = TextEditingController();
  final _priceWeekCtrl = TextEditingController();
  final _priceMonthCtrl = TextEditingController();

  int? _selectedHotelId;
  File? _coverImage;
  bool _saving = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    if (widget.hotels.isNotEmpty) {
      _selectedHotelId = widget.hotels.first['id'] as int;
    }
  }

  @override
  void dispose() {
    _nameArCtrl.dispose();
    _nameEnCtrl.dispose();
    _unitNumberCtrl.dispose();
    _descArCtrl.dispose();
    _descEnCtrl.dispose();
    _capacityCtrl.dispose();
    _priceNightCtrl.dispose();
    _priceWeekCtrl.dispose();
    _priceMonthCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _coverImage = File(picked.path));
  }

  Future<void> _submit(bool isArabic) async {
    if (_selectedHotelId == null) {
      setState(() => _errorText = AppStrings.t(isArabic, 'no_hotel_linked'));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _errorText = null;
    });

    try {
      await _service.createUnit(
        hotelId: _selectedHotelId!,
        nameAr: _nameArCtrl.text.trim(),
        nameEn: _nameEnCtrl.text.trim(),
        descriptionAr: _descArCtrl.text.trim(),
        descriptionEn: _descEnCtrl.text.trim(),
        unitNumber: _unitNumberCtrl.text.trim(),
        capacity: int.tryParse(_capacityCtrl.text.trim()) ?? 1,
        pricePerNight: double.tryParse(_priceNightCtrl.text.trim()) ?? 0,
        pricePerWeek: _priceWeekCtrl.text.trim().isEmpty ? null : double.tryParse(_priceWeekCtrl.text.trim()),
        pricePerMonth: _priceMonthCtrl.text.trim().isEmpty ? null : double.tryParse(_priceMonthCtrl.text.trim()),
        coverImagePath: _coverImage?.path,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label) => InputDecoration(labelText: label);

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'add_unit')),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppDimens.pagePadding),
            children: [
              if (widget.hotels.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppDimens.md),
                  margin: const EdgeInsets.only(bottom: AppDimens.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  ),
                  child: Text(
                    AppStrings.t(isArabic, 'no_hotel_linked'),
                    style: const TextStyle(color: AppColors.warning),
                  ),
                )
              else
                DropdownButtonFormField<int>(
                  initialValue: _selectedHotelId,
                  decoration: _dec(AppStrings.t(isArabic, 'hotel')),
                  items: widget.hotels
                      .map((h) => DropdownMenuItem<int>(value: h['id'] as int, child: Text(h['name']?.toString() ?? '')))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedHotelId = v),
                ),
              const SizedBox(height: AppDimens.md),

              GestureDetector(
                onTap: _pickCoverImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    image: _coverImage != null ? DecorationImage(image: FileImage(_coverImage!), fit: BoxFit.cover) : null,
                  ),
                  child: _coverImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_a_photo_outlined, color: AppColors.textMuted, size: 28),
                            const SizedBox(height: 6),
                            Text(AppStrings.t(isArabic, 'cover_image'), style: const TextStyle(color: AppColors.textMuted)),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppDimens.md),

              TextFormField(
                controller: _nameArCtrl,
                decoration: _dec(AppStrings.t(isArabic, 'unit_name_ar')),
                validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.t(isArabic, 'required_field') : null,
              ),
              const SizedBox(height: AppDimens.md),
              TextFormField(
                controller: _nameEnCtrl,
                decoration: _dec(AppStrings.t(isArabic, 'unit_name_en')),
                validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.t(isArabic, 'required_field') : null,
              ),
              const SizedBox(height: AppDimens.md),
              TextFormField(controller: _unitNumberCtrl, decoration: _dec(AppStrings.t(isArabic, 'unit_number'))),
              const SizedBox(height: AppDimens.md),
              TextFormField(
                controller: _descArCtrl,
                maxLines: 3,
                decoration: _dec(AppStrings.t(isArabic, 'description_ar')),
              ),
              const SizedBox(height: AppDimens.md),
              TextFormField(
                controller: _descEnCtrl,
                maxLines: 3,
                decoration: _dec(AppStrings.t(isArabic, 'description_en')),
              ),
              const SizedBox(height: AppDimens.md),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _capacityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _dec(AppStrings.t(isArabic, 'capacity')),
                      validator: (v) => (v == null || v.trim().isEmpty) ? AppStrings.t(isArabic, 'required_field') : null,
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _priceNightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dec(AppStrings.t(isArabic, 'price_per_night')),
                      validator: (v) => (v == null || double.tryParse(v.trim()) == null || double.parse(v.trim()) <= 0)
                          ? AppStrings.t(isArabic, 'required_field')
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.md),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceWeekCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dec(AppStrings.t(isArabic, 'price_per_week_optional')),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _priceMonthCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dec(AppStrings.t(isArabic, 'price_per_month_optional')),
                    ),
                  ),
                ],
              ),

              if (_errorText != null) ...[
                const SizedBox(height: AppDimens.md),
                Text(_errorText!, style: const TextStyle(color: AppColors.danger)),
              ],

              const SizedBox(height: AppDimens.lg),
              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: _saving ? null : () => _submit(isArabic),
                  child: _saving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(AppStrings.t(isArabic, 'save')),
                ),
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                AppStrings.t(isArabic, 'add_unit_more_options_web'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
