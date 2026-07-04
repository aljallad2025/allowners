import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/hotels_provider.dart';
import '../../providers/owner_hotel_mutations_provider.dart';

class AddUnitScreen extends ConsumerStatefulWidget {
  const AddUnitScreen({super.key});

  @override
  ConsumerState<AddUnitScreen> createState() => _AddUnitScreenState();
}

class _AddUnitScreenState extends ConsumerState<AddUnitScreen> {
  final _nameController = TextEditingController();
  final _revenueController = TextEditingController();
  String? _selectedHotelId;
  bool _occupied = false;
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _submit(bool isArabic) async {
    if (_selectedHotelId == null || _nameController.text.trim().isEmpty || _revenueController.text.trim().isEmpty) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'fill_all_fields'));
      return;
    }
    final revenue = double.tryParse(_revenueController.text.trim());
    if (revenue == null) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'invalid_price'));
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(ownerHotelMutationsProvider).createUnit(
            hotelId: _selectedHotelId!,
            name: _nameController.text.trim(),
            occupied: _occupied,
            monthlyRevenue: revenue,
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
    _revenueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final ownerHotelsAsync = ref.watch(ownerHotelsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'add_unit'))),
      body: SafeArea(
        child: ownerHotelsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'),
                style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (hotels) {
            if (hotels.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimens.xl),
                  child: Text(AppStrings.t(isArabic, 'add_hotel_first'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textMuted)),
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AppStrings.t(isArabic, 'select_hotel'), style: textTheme.titleSmall),
                  const SizedBox(height: AppDimens.sm),
                  DropdownButtonFormField<String>(
                    value: _selectedHotelId,
                    items: hotels
                        .map((h) => DropdownMenuItem(value: h.id, child: Text(h.name)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedHotelId = v),
                    decoration: const InputDecoration(),
                  ),
                  const SizedBox(height: AppDimens.md),

                  Text(AppStrings.t(isArabic, 'unit_name'), style: textTheme.titleSmall),
                  const SizedBox(height: AppDimens.sm),
                  TextField(controller: _nameController),
                  const SizedBox(height: AppDimens.md),

                  Text(AppStrings.t(isArabic, 'monthly_revenue'), style: textTheme.titleSmall),
                  const SizedBox(height: AppDimens.sm),
                  TextField(
                    controller: _revenueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textDirection: TextDirection.ltr,
                    decoration: InputDecoration(suffixText: AppStrings.t(isArabic, 'sar')),
                  ),
                  const SizedBox(height: AppDimens.md),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(AppStrings.t(isArabic, 'occupied')),
                    value: _occupied,
                    onChanged: (v) => setState(() => _occupied = v),
                  ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
                  ],
                  const SizedBox(height: AppDimens.lg),

                  SizedBox(
                    height: AppDimens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : () => _submit(isArabic),
                      child: _submitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                            )
                          : Text(AppStrings.t(isArabic, 'save')),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
