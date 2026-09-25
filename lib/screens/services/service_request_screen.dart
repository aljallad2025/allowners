import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class ServiceRequestScreen extends ConsumerStatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const ServiceRequestScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  ConsumerState<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends ConsumerState<ServiceRequestScreen> {
  final _roomController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _roomError = false;
  bool _submitting = false;

  @override
  void dispose() {
    _roomController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _submit(bool isArabic) {
    final roomEmpty = _roomController.text.trim().isEmpty;
    setState(() => _roomError = roomEmpty);
    if (roomEmpty) return;

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
        title: Text(widget.title),
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
                child: Icon(widget.icon, color: AppColors.goldDark, size: 30),
              ),
              const SizedBox(height: AppDimens.md),
              Text(widget.title, style: textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                widget.description,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimens.xl),

              Text(AppStrings.t(isArabic, 'room_number'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _roomController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: AppStrings.t(isArabic, 'room_number'),
                  errorText: _roomError ? AppStrings.t(isArabic, 'room_number_required') : null,
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              Text(AppStrings.t(isArabic, 'request_details'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _detailsController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: AppStrings.t(isArabic, 'describe_request'),
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