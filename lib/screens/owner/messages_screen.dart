import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/messages_provider.dart';
import 'chat_screen.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final conversationsAsync = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'messages')),
      ),
      body: SafeArea(
        child: conversationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'), style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (conversations) {
            if (conversations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 56, color: AppColors.textMuted),
                    const SizedBox(height: AppDimens.md),
                    Text(AppStrings.t(isArabic, 'no_conversations_yet'), style: const TextStyle(color: AppColors.textMuted)),
                    const SizedBox(height: 6),
                    Text(AppStrings.t(isArabic, 'no_conversations_hint'),
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppDimens.sm),
              itemBuilder: (context, index) {
                final c = conversations[index];
                final name = (c['peer_name'] as String).isEmpty ? AppStrings.t(isArabic, 'role_owner') : c['peer_name'] as String;
                return InkWell(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ChatScreen(peerId: c['peer_id'] as String, peerName: name)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: (c['unread'] as bool) ? AppColors.gold.withOpacity(0.06) : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.surfaceMuted,
                          child: Text(name.isNotEmpty ? name[0] : '?',
                              style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: AppDimens.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: textTheme.titleSmall?.copyWith(
                                      fontWeight: (c['unread'] as bool) ? FontWeight.w700 : FontWeight.w500)),
                              Text(c['last_message'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
