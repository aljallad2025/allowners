import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/reviews_provider.dart';

class AllReviewsScreen extends ConsumerWidget {
  final String hotelId;
  const AllReviewsScreen({super.key, required this.hotelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final reviewsAsync = ref.watch(hotelReviewsProvider(hotelId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'guest_reviews'))),
      body: SafeArea(
        child: reviewsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'), style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (reviews) {
            if (reviews.isEmpty) {
              return Center(
                child: Text(AppStrings.t(isArabic, 'no_reviews_yet'), style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Divider(height: AppDimens.lg),
              itemBuilder: (context, index) {
                final r = reviews[index];
                final profile = r['profiles'] as Map<String, dynamic>?;
                final name = (profile?['full_name'] as String?)?.trim();
                final displayName = (name == null || name.isEmpty) ? AppStrings.t(isArabic, 'role_guest') : name;
                final rating = (r['rating'] as num).toInt();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.surfaceMuted,
                          child: Text(displayName.isNotEmpty ? displayName[0] : '?',
                              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(child: Text(displayName, style: textTheme.titleSmall)),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 16,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((r['comment'] as String?)?.isNotEmpty == true) ...[
                      const SizedBox(height: AppDimens.sm),
                      Text(r['comment'] as String, style: textTheme.bodyMedium),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
