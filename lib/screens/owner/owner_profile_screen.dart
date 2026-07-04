import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../shared/coming_soon_screen.dart';
import '../shared/help_support_screen.dart';
import '../shared/about_us_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/edit_profile_screen.dart';
import 'owner_revenue_screen.dart';
import 'owner_maintenance_screen.dart';
import 'voting_screen.dart';
import 'community_screen.dart';
import 'marketplace_screen.dart';
import 'messages_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OwnerProfileScreen extends ConsumerWidget {
  const OwnerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final profile = ref.watch(currentProfileProvider).asData?.value;
    final displayName =
        (profile != null && profile.fullName.isNotEmpty) ? profile.fullName : AppStrings.t(isArabic, 'role_owner');

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
                backgroundImage:
                    (profile?.avatarUrl != null) ? CachedNetworkImageProvider(profile!.avatarUrl!) : null,
                child: (profile?.avatarUrl == null)
                    ? const Icon(Icons.person_rounded, color: AppColors.textMuted, size: 46)
                    : null,
              ),
              const SizedBox(height: AppDimens.md),
              Text(displayName, style: textTheme.headlineSmall),
              Text(AppStrings.t(isArabic, 'role_owner'),
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.goldDark)),
              const SizedBox(height: AppDimens.sm),
              OutlinedButton.icon(
                onPressed: () async {
                  final updated = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => EditProfileScreen(profile: profile)),
                  );
                  if (updated == true) ref.invalidate(currentProfileProvider);
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text(AppStrings.t(isArabic, 'edit_profile')),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8)),
              ),
              const SizedBox(height: AppDimens.xl),

              _MenuSection(items: [
                _MenuItem(
                  icon: Icons.bar_chart_outlined,
                  label: AppStrings.t(isArabic, 'financial_reports'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OwnerRevenueScreen()),
                  ),
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
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OwnerMaintenanceScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.how_to_vote_outlined,
                  label: AppStrings.t(isArabic, 'voting_decisions'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VotingScreen()),
                  ),
                ),
              ]),
              const SizedBox(height: AppDimens.md),

              _MenuSection(items: [
                _MenuItem(
                  icon: Icons.groups_outlined,
                  label: AppStrings.t(isArabic, 'owners_community'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CommunityScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.storefront_outlined,
                  label: AppStrings.t(isArabic, 'units_marketplace'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MarketplaceScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: AppStrings.t(isArabic, 'messages'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MessagesScreen()),
                  ),
                ),
              ]),
              const SizedBox(height: AppDimens.md),

              _MenuSection(items: [
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: AppStrings.t(isArabic, 'help_support'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                  ),
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  label: AppStrings.t(isArabic, 'about_us'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                  ),
                ),
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
                  onTap: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (!context.mounted) return;
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