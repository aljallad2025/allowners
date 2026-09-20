import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/support_config.dart';

/// «المساعدة والدعم» — وسائل التواصل تُقرأ من SupportConfig ولا يظهر منها إلا المعبّأ.
class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  Future<void> _open(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uri.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    final channels = <({IconData icon, String label, String value, Uri uri})>[
      if (SupportConfig.phone.isNotEmpty)
        (
          icon: Icons.call_outlined,
          label: AppStrings.t(isArabic, 'support_call'),
          value: SupportConfig.phone,
          uri: Uri(scheme: 'tel', path: SupportConfig.phone),
        ),
      if (SupportConfig.whatsapp.isNotEmpty)
        (
          icon: Icons.chat_outlined,
          label: AppStrings.t(isArabic, 'support_whatsapp'),
          value: '+${SupportConfig.whatsapp}',
          uri: Uri.parse('https://wa.me/${SupportConfig.whatsapp}'),
        ),
      if (SupportConfig.email.isNotEmpty)
        (
          icon: Icons.email_outlined,
          label: AppStrings.t(isArabic, 'support_email'),
          value: SupportConfig.email,
          uri: Uri(scheme: 'mailto', path: SupportConfig.email),
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'help_support')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              ),
              child: const Icon(Icons.support_agent_rounded, color: AppColors.goldDark, size: 32),
            ),
            const SizedBox(height: AppDimens.md),
            Text(AppStrings.t(isArabic, 'help_support'), style: textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              AppStrings.t(isArabic, 'support_intro'),
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: AppDimens.lg),
            if (channels.isEmpty)
              Text(
                AppStrings.t(isArabic, 'support_not_set'),
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              )
            else
              for (final c in channels) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  onTap: () => _open(context, c.uri),
                  child: Container(
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(c.icon, color: AppColors.goldDark),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.label, style: textTheme.titleSmall),
                              Text(
                                c.value,
                                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                                textDirection: TextDirection.ltr,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isArabic ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.sm),
              ],
          ],
        ),
      ),
    );
  }
}
