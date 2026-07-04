import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    final items = [
      (
        icon: Icons.email_outlined,
        title: AppStrings.t(isArabic, 'contact_email'),
        subtitle: 'support@allowners.app',
        onTap: () => launchUrl(Uri.parse('mailto:support@allowners.app')),
      ),
      (
        icon: Icons.phone_outlined,
        title: AppStrings.t(isArabic, 'contact_phone'),
        subtitle: '+966 500 000 000',
        onTap: () => launchUrl(Uri.parse('tel:+966500000000')),
      ),
      (
        icon: Icons.chat_bubble_outline_rounded,
        title: AppStrings.t(isArabic, 'contact_whatsapp'),
        subtitle: 'WhatsApp',
        onTap: () => launchUrl(Uri.parse('https://wa.me/966500000000')),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'help_support'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          children: [
            Text(AppStrings.t(isArabic, 'help_support_intro'),
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: AppDimens.lg),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.md),
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimens.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(item.icon, color: AppColors.goldDark),
                          const SizedBox(width: AppDimens.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.title, style: textTheme.titleSmall),
                                Text(item.subtitle,
                                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                    textDirection: TextDirection.ltr),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
