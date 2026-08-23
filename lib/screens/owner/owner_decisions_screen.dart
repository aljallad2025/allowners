import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../services/owner_service.dart';
import '../../services/api_client.dart';

class OwnerDecisionsScreen extends ConsumerStatefulWidget {
  const OwnerDecisionsScreen({super.key});

  @override
  ConsumerState<OwnerDecisionsScreen> createState() => _OwnerDecisionsScreenState();
}

class _OwnerDecisionsScreenState extends ConsumerState<OwnerDecisionsScreen> {
  final _service = OwnerService();
  late Future<List<Map<String, dynamic>>> _future;
  int? _votingOn;

  @override
  void initState() {
    super.initState();
    _future = _service.getDecisions();
  }

  void _reload() => setState(() => _future = _service.getDecisions());

  Future<void> _vote(bool isArabic, int decisionId, int optionId) async {
    setState(() => _votingOn = decisionId);
    try {
      await _service.castVote(decisionId: decisionId, optionId: optionId);
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.t(isArabic, 'vote_submitted'))));
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _votingOn = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'voting_decisions')),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppDimens.xl),
                  children: [
                    Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 32),
                    const SizedBox(height: AppDimens.sm),
                    Text(AppStrings.t(isArabic, 'error_loading'), textAlign: TextAlign.center),
                    const SizedBox(height: AppDimens.sm),
                    Center(child: OutlinedButton(onPressed: _reload, child: Text(AppStrings.t(isArabic, 'retry')))),
                  ],
                );
              }

              final decisions = snapshot.data ?? [];
              if (decisions.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: Center(child: Text(AppStrings.t(isArabic, 'no_decisions'))),
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                itemCount: decisions.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                itemBuilder: (context, index) {
                  final d = decisions[index];
                  final isOpen = d['status'] == 'open';
                  final myVote = d['my_vote'] as int?;
                  final options = (d['options'] as List).cast<Map<String, dynamic>>();
                  final total = (d['total_votes'] as num?)?.toInt() ?? 0;

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
                            Expanded(child: Text(d['title'].toString(), style: textTheme.titleSmall)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (isOpen ? AppColors.success : AppColors.textMuted).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                              ),
                              child: Text(
                                AppStrings.t(isArabic, isOpen ? 'decision_open' : 'decision_closed'),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isOpen ? AppColors.success : AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                        Text(d['hotel_name'].toString(), style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                        if ((d['description'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: AppDimens.sm),
                          Text(d['description'].toString(), style: textTheme.bodyMedium),
                        ],
                        const SizedBox(height: AppDimens.md),
                        ...options.map((o) {
                          final votes = (o['votes'] as num).toInt();
                          final pct = total > 0 ? (votes / total * 100).round() : 0;
                          final isMine = myVote == o['id'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppDimens.sm),
                            child: InkWell(
                              onTap: (!isOpen || _votingOn == d['id']) ? null : () => _vote(isArabic, d['id'] as int, o['id'] as int),
                              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isMine ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                        size: 18,
                                        color: isMine ? AppColors.goldDark : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(child: Text(o['label'].toString(), style: textTheme.bodyMedium)),
                                      Text('$votes ${AppStrings.t(isArabic, 'votes_count')} · $pct%',
                                          style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: total > 0 ? votes / total : 0,
                                      minHeight: 6,
                                      backgroundColor: AppColors.surfaceMuted,
                                      valueColor: AlwaysStoppedAnimation(isMine ? AppColors.gold : AppColors.cardBorder),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        if (myVote != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(AppStrings.t(isArabic, 'you_voted'),
                                style: textTheme.bodySmall?.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
