import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';

String _timeAgo(DateTime dt, bool isArabic) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return isArabic ? 'منذ ${diff.inMinutes} د' : '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return isArabic ? 'منذ ${diff.inHours} س' : '${diff.inHours}h ago';
  return isArabic ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
}

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final postsAsync = ref.watch(communityPostsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'owners_community')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openComposeSheet(context, ref, isArabic),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: postsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'), style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (posts) {
            if (posts.isEmpty) {
              return Center(
                child: Text(AppStrings.t(isArabic, 'no_posts_yet'), style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.pagePadding, AppDimens.pagePadding, 90),
              itemCount: posts.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
              itemBuilder: (context, index) => _PostCard(post: posts[index], isArabic: isArabic),
            );
          },
        ),
      ),
    );
  }

  void _openComposeSheet(BuildContext context, WidgetRef ref, bool isArabic) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppDimens.pagePadding,
          right: AppDimens.pagePadding,
          top: AppDimens.pagePadding,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppDimens.pagePadding,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(AppStrings.t(isArabic, 'new_post'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimens.md),
            TextField(controller: controller, maxLines: 4, autofocus: true),
            const SizedBox(height: AppDimens.md),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;
                await ref.read(communityRepositoryProvider).createPost(controller.text.trim());
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(AppStrings.t(isArabic, 'publish')),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;
  final bool isArabic;
  const _PostCard({required this.post, required this.isArabic});

  @override
  ConsumerState<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<_PostCard> {
  bool _showReplies = false;
  final _replyController = TextEditingController();

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isArabic = widget.isArabic;
    final post = widget.post;
    final profile = post['profiles'] as Map<String, dynamic>?;
    final name = (profile?['full_name'] as String?)?.trim();
    final displayName = (name == null || name.isEmpty) ? AppStrings.t(isArabic, 'role_owner') : name;
    final createdAt = DateTime.parse(post['created_at'] as String);

    return Container(
      padding: const EdgeInsets.all(AppDimens.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.surfaceMuted,
                child: Text(displayName.isNotEmpty ? displayName[0] : '?',
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: AppDimens.sm),
              Expanded(child: Text(displayName, style: textTheme.titleSmall)),
              Text(_timeAgo(createdAt, isArabic), style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: AppDimens.sm),
          Text(post['content'] as String, style: textTheme.bodyMedium),
          const SizedBox(height: AppDimens.sm),
          InkWell(
            onTap: () => setState(() => _showReplies = !_showReplies),
            child: Text(AppStrings.t(isArabic, 'view_replies'),
                style: textTheme.bodySmall?.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.w600)),
          ),
          if (_showReplies) ...[
            const Divider(height: AppDimens.lg),
            Consumer(
              builder: (context, ref, _) {
                final repliesAsync = ref.watch(postRepliesProvider(post['id'] as String));
                return repliesAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (err, st) => const SizedBox.shrink(),
                  data: (replies) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...replies.map((r) {
                        final rProfile = r['profiles'] as Map<String, dynamic>?;
                        final rName = (rProfile?['full_name'] as String?)?.trim();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.sm),
                          child: RichText(
                            text: TextSpan(
                              style: textTheme.bodySmall,
                              children: [
                                TextSpan(
                                  text: '${(rName == null || rName.isEmpty) ? AppStrings.t(isArabic, "role_owner") : rName}: ',
                                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                ),
                                TextSpan(text: r['content'] as String),
                              ],
                            ),
                          ),
                        );
                      }),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              decoration: InputDecoration(hintText: AppStrings.t(isArabic, 'write_reply')),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send_rounded, color: AppColors.goldDark),
                            onPressed: () async {
                              if (_replyController.text.trim().isEmpty) return;
                              await ref
                                  .read(communityRepositoryProvider)
                                  .addReply(post['id'] as String, _replyController.text.trim());
                              _replyController.clear();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
