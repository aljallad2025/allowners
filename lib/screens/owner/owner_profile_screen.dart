import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../auth/login_screen.dart';
import '../shared/coming_soon_screen.dart';

class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: AppDimens.md),
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.surfaceMuted,
                child: const Icon(Icons.person_rounded, color: AppColors.textMuted, size: 46),
              ),
              const SizedBox(height: AppDimens.md),
              Text('ثائر الجلاد', style: textTheme.headlineSmall),
              Text(AppStrings.t(isArabic, 'role_owner'),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.goldDark)),
              const SizedBox(height: AppDimens.sm),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(AppStrings.t(isArabic, 'edit_profile')),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8)),
              ),
              const SizedBox(height: AppDimens.xl),

              _MenuSection(items: [
                _MenuItem(
                  icon: Icons.bar_chart_outlined,
                  label: AppStrings.t(isArabic, 'financial_reports'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ComingSoonScreen(
                        icon: Icons.bar_chart_outlined, title: AppStrings.t(isArabic, 'financial_reports')),
                  )),
                ),
                _MenuItem(
                  icon: Icons.folder_outlined,
                  label: AppStrings.t(isArabic, 'contracts_docs'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ComingSoonScreen(
                        icon: Icons.folder_outlined, title: AppStrings.t(isArabic, 'contracts_docs')),
                  )),
                ),
                _MenuItem(
                  icon: Icons.build_outlined,
                  label: AppStrings.t(isArabic, 'maintenance_requests'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ComingSoonScreen(
                        icon: Icons.build_outlined, title: AppStrings.t(isArabic, 'maintenance_requests')),
                  )),
                ),
                _MenuItem(
                  icon: Icons.how_to_vote_outlined,
                  label: AppStrings.t(isArabic, 'voting_decisions'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ComingSoonScreen(
                        icon: Icons.how_to_vote_outlined, title: AppStrings.t(isArabic, 'voting_decisions')),
                  )),
                ),
              ]),
              const SizedBox(height: AppDimens.md),

              _MenuSection(items: [
                _MenuItem(
                  icon: Icons.groups_outlined,
                  label: AppStrings.t(isArabic, 'owners_community'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ComingSoonScreen(
                        icon: Icons.groups_outlined, title: AppStrings.t(isArabic, 'owners_community')),
                  )),
                ),
                _MenuItem(
                  icon: Icons.storefront_outlined,
                  label: AppStrings.t(isArabic, 'units_marketplace'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ComingSoonScreen(
                        icon: Icons.storefront_outlined, title: AppStrings.t(isArabic, 'units_marketplace')),
                  )),
                ),
                _MenuItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: AppStrings.t(isArabic, 'messages'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ComingSoonScreen(
                        icon: Icons.chat_bubble_outline_rounded, title: AppStrings.t(isArabic, 'messages')),
                  )),
                ),
              ]),
              const SizedBox(height: AppDimens.md),

              _MenuSection(items: [
                _MenuItem(icon: Icons.help_outline_rounded, label: AppStrings.t(isArabic, 'help_support'), onTap: () {}),
                _MenuItem(
                  icon: Icons.language_rounded,
                  label: AppStrings.t(isArabic, 'language'),
                  trailing: Text(isArabic ? 'العربية' : 'English',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                ),
              ]),
              const SizedBox(height: AppDimens.md),

              _MenuSection(items: [
                _MenuItem(
                  icon: Icons.logout_rounded,
                  label: AppStrings.t(isArabic, 'logout'),
                  iconColor: AppColors.danger,
                  textColor: AppColors.danger,
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
              ]),
              const SizedBox(height: AppDimens.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.iconColor,
    this.textColor,
  });
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimens.md, vertical: 14),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 22, color: item.iconColor ?? AppColors.textSecondary),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: item.textColor ?? AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (item.trailing != null) item.trailing!,
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              if (index != items.length - 1)
                const Divider(height: 1, indent: AppDimens.md, endIndent: AppDimens.md),
            ],
          );
        }),
      ),
    );
  }
}