import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/unit_model.dart';
import '../../providers/owner_hotel_mutations_provider.dart';

class EditUnitScreen extends ConsumerStatefulWidget {
  final UnitModel unit;
  const EditUnitScreen({super.key, required this.unit});

  @override
  ConsumerState<EditUnitScreen> createState() => _EditUnitScreenState();
}

class _EditUnitScreenState extends ConsumerState<EditUnitScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _revenueController;
  late bool _occupied;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.unit.name);
    _revenueController = TextEditingController(text: widget.unit.monthlyRevenue.toStringAsFixed(0));
    _occupied = widget.unit.occupied;
  }

  Future<void> _submit() async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    final revenue = double.tryParse(_revenueController.text.trim());
    if (_nameController.text.trim().isEmpty || revenue == null) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'fill_all_fields'));
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(ownerHotelMutationsProvider).updateUnit(
            unitId: widget.unit.id,
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

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'edit'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
            ],
          ),
        ),
      ),
    );
  }
}
