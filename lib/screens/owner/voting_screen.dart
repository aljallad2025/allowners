import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/voting_provider.dart';

String _timeAgo(DateTime dt, bool isArabic) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return isArabic ? 'منذ ${diff.inMinutes} د' : '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return isArabic ? 'منذ ${diff.inHours} س' : '${diff.inHours}h ago';
  return isArabic ? 'منذ ${diff.inDays} يوم' : '${diff.inDays}d ago';
}

class VotingScreen extends ConsumerWidget {
  const VotingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final decisionsAsync = ref.watch(decisionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'voting_decisions')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateDecisionSheet(context, ref, isArabic),
        icon: const Icon(Icons.add),
        label: Text(AppStrings.t(isArabic, 'new_decision')),
      ),
      body: SafeArea(
        child: decisionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
          error: (err, st) => Center(
            child: Text(AppStrings.t(isArabic, 'something_went_wrong'), style: const TextStyle(color: AppColors.textMuted)),
          ),
          data: (decisions) {
            if (decisions.isEmpty) {
              return Center(
                child: Text(AppStrings.t(isArabic, 'no_decisions_yet'), style: const TextStyle(color: AppColors.textMuted)),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.pagePadding, AppDimens.pagePadding, 90),
              itemCount: decisions.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
              itemBuilder: (context, index) => _DecisionCard(decision: decisions[index], isArabic: isArabic),
            );
          },
        ),
      ),
    );
  }

  void _openCreateDecisionSheet(BuildContext context, WidgetRef ref, bool isArabic) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
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
            Text(AppStrings.t(isArabic, 'new_decision'), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppDimens.md),
            TextField(controller: titleController, decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'decision_title'))),
            const SizedBox(height: AppDimens.md),
            TextField(controller: descController, maxLines: 3, decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'description_ar'))),
            const SizedBox(height: AppDimens.md),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                await ref.read(votingRepositoryProvider).createDecision(
                      titleController.text.trim(),
                      descController.text.trim().isEmpty ? null : descController.text.trim(),
                    );
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

class _DecisionCard extends ConsumerWidget {
  final Map<String, dynamic> decision;
  final bool isArabic;
  const _DecisionCard({required this.decision, required this.isArabic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final decisionId = decision['id'] as String;
    final profile = decision['profiles'] as Map<String, dynamic>?;
    final name = (profile?['full_name'] as String?)?.trim();
    final displayName = (name == null || name.isEmpty) ? AppStrings.t(isArabic, 'role_owner') : name;
    final createdAt = DateTime.parse(decision['created_at'] as String);
    final votesAsync = ref.watch(decisionVotesProvider(decisionId));

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
          Text(decision['title'] as String, style: textTheme.titleSmall),
          const SizedBox(height: 2),
          Text('${AppStrings.t(isArabic, "by")} $displayName · ${_timeAgo(createdAt, isArabic)}',
              style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
          if ((decision['description'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: AppDimens.sm),
            Text(decision['description'] as String, style: textTheme.bodyMedium),
          ],
          const Divider(height: AppDimens.lg),
          votesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (err, st) => const SizedBox.shrink(),
            data: (results) {
              final yes = results['yes'] as int;
              final no = results['no'] as int;
              final myVote = results['my_vote'] as String?;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${AppStrings.t(isArabic, "yes")}: $yes   ${AppStrings.t(isArabic, "no")}: $no',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppDimens.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: myVote == 'yes' ? AppColors.success.withOpacity(0.12) : null,
                          ),
                          onPressed: () => ref.read(votingRepositoryProvider).vote(decisionId, 'yes'),
                          child: Text(AppStrings.t(isArabic, 'yes')),
                        ),
                      ),
                      const SizedBox(width: AppDimens.sm),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: myVote == 'no' ? AppColors.danger.withOpacity(0.1) : null,
                          ),
                          onPressed: () => ref.read(votingRepositoryProvider).vote(decisionId, 'no'),
                          child: Text(AppStrings.t(isArabic, 'no')),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
