import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class MealRequestScreen extends ConsumerStatefulWidget {
  const MealRequestScreen({super.key});

  @override
  ConsumerState<MealRequestScreen> createState() => _MealRequestScreenState();
}

class _MealRequestScreenState extends ConsumerState<MealRequestScreen> {
  final _notesController = TextEditingController();
  String? _selectedMeal;
  bool _mealError = false;
  bool _submitting = false;

  static const _meals = [
    (key: 'breakfast', icon: Icons.coffee_outlined),
    (key: 'lunch', icon: Icons.wb_sunny_outlined),
    (key: 'dinner', icon: Icons.nightlight_outlined),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit(bool isArabic) {
    final mealEmpty = _selectedMeal == null;
    setState(() => _mealError = mealEmpty);
    if (mealEmpty) return;

    setState(() => _submitting = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => _submitting = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusLg)),
          title: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 32),
              ),
              const SizedBox(height: AppDimens.md),
              Text(
                AppStrings.t(isArabic, 'request_submitted_title'),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            AppStrings.t(isArabic, 'request_submitted_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(AppStrings.t(isArabic, 'ok')),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'order_meal')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
                child: const Icon(Icons.restaurant_outlined, color: AppColors.goldDark, size: 30),
              ),
              const SizedBox(height: AppDimens.md),
              Text(AppStrings.t(isArabic, 'order_meal'), style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                AppStrings.t(isArabic, 'order_meal_desc'),
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimens.xl),

              Text(AppStrings.t(isArabic, 'meal_type'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              Row(
                children: [
                  for (int i = 0; i < _meals.length; i++) ...[
                    if (i != 0) const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: _MealOption(
                        icon: _meals[i].icon,
                        label: AppStrings.t(isArabic, _meals[i].key),
                        isSelected: _selectedMeal == _meals[i].key,
                        onTap: () => setState(() {
                          _selectedMeal = _meals[i].key;
                          _mealError = false;
                        }),
                      ),
                    ),
                  ],
                ],
              ),
              if (_mealError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    AppStrings.t(isArabic, 'meal_type_required'),
                    style: const TextStyle(color: AppColors.danger, fontSize: 12),
                  ),
                ),
              const SizedBox(height: AppDimens.lg),

              Text(AppStrings.t(isArabic, 'notes'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: AppStrings.t(isArabic, 'notes_hint'),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: _submitting ? null : () => _submit(isArabic),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(AppStrings.t(isArabic, 'submit_request')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MealOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.goldDark : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.goldDark : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.goldDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}