import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class AboutUsScreen extends ConsumerWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'about_us'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          children: [
            Center(child: Image.asset('assets/images/logo.png', width: 90)),
            const SizedBox(height: AppDimens.md),
            Center(
              child: Text('All Owners',
                  style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: AppDimens.xl),
            Text(AppStrings.t(isArabic, 'about_us_body'),
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6)),
          ],
        ),
      ),
    );
  }
}
