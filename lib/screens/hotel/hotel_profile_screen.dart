import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/locale_provider.dart';
import '../../utils/session_provider.dart';
import '../../utils/tr.dart';
import '../../widgets/avatar_picker.dart';
import '../home/main_navigation_screen.dart';
import '../owner/owner_notifications_screen.dart';
import '../profile/help_support_screen.dart';

/// حساب إدارة الفندق: الصورة الشخصية + إشعارات + دعم + لغة + تسجيل الخروج
class HotelProfileScreen extends ConsumerWidget {
  const HotelProfileScreen({super.key});

  Widget _tile(IconData icon, String label, VoidCallback onTap, {Widget? trailing, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color ?? AppColors.textPrimary)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: AppDimens.md),
              const AvatarPicker(radius: 44),
              const SizedBox(height: AppDimens.md),
              Text(user?.fullName ?? '', style: textTheme.headlineSmall),
              Text(tr(isArabic, 'إدارة الفندق', 'Hotel management'), style: textTheme.bodyMedium?.copyWith(color: AppColors.goldDark)),
              Text(user?.email ?? '', style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted), textDirection: TextDirection.ltr),
              const SizedBox(height: AppDimens.xl),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _tile(Icons.notifications_outlined, tr(isArabic, 'الإشعارات', 'Notifications'),
                        () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerNotificationsScreen()))),
                    const Divider(height: 1),
                    _tile(Icons.help_outline_rounded, tr(isArabic, 'المساعدة والدعم', 'Help & support'),
                        () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
                    const Divider(height: 1),
                    _tile(
                      Icons.language_rounded,
                      tr(isArabic, 'اللغة', 'Language'),
                      () => ref.read(localeProvider.notifier).toggleLocale(),
                      trailing: Text(isArabic ? 'العربية' : 'English', style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ),
                    const Divider(height: 1),
                    _tile(
                      Icons.logout_rounded,
                      tr(isArabic, 'تسجيل الخروج', 'Log out'),
                      () async {
                        await ref.read(sessionProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                            (route) => false,
                          );
                        }
                      },
                      color: AppColors.danger,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
