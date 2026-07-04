import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/owner_requests_provider.dart';

Color _statusColor(String status) {
  switch (status) {
    case 'in_progress':
      return AppColors.gold;
    case 'completed':
      return AppColors.success;
    default:
      return AppColors.textMuted;
  }
}

class OwnerMaintenanceScreen extends ConsumerStatefulWidget {
  const OwnerMaintenanceScreen({super.key});

  @override
  ConsumerState<OwnerMaintenanceScreen> createState() => _OwnerMaintenanceScreenState();
}

class _OwnerMaintenanceScreenState extends ConsumerState<OwnerMaintenanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(AppStrings.t(isArabic, 'maintenance_requests')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppStrings.t(isArabic, 'maintenance')),
            Tab(text: AppStrings.t(isArabic, 'order_meal')),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: const [
            _ServiceRequestsTab(),
            _MealRequestsTab(),
          ],
        ),
      ),
    );
  }
}

class _ServiceRequestsTab extends ConsumerWidget {
  const _ServiceRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final requestsAsync = ref.watch(ownerServiceRequestsProvider);

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (err, st) => Center(
        child: Text(AppStrings.t(isArabic, 'something_went_wrong'), style: const TextStyle(color: AppColors.textMuted)),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
              child: Text(AppStrings.t(isArabic, 'no_hotels_found'), style: const TextStyle(color: AppColors.textMuted)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
          itemBuilder: (context, index) {
            final r = requests[index];
            final hotel = r['hotels'] as Map<String, dynamic>?;
            final status = r['status'] as String? ?? 'pending';
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
                      Expanded(child: Text(r['service_type'] as String? ?? '', style: textTheme.titleSmall)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        ),
                        child: Text(AppStrings.t(isArabic, status),
                            style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${hotel?['name'] ?? ''} · ${AppStrings.t(isArabic, "room_number")}: ${r['room_number']}',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                  if ((r['details'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(r['details'] as String, style: textTheme.bodySmall),
                  ],
                  if (status != 'completed') ...[
                    const Divider(height: AppDimens.lg),
                    Row(
                      children: [
                        if (status == 'pending')
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => ref
                                  .read(ownerRequestsRepositoryProvider)
                                  .updateServiceRequestStatus(r['id'] as String, 'in_progress'),
                              child: Text(AppStrings.t(isArabic, 'mark_in_progress')),
                            ),
                          ),
                        if (status == 'pending') const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref
                                .read(ownerRequestsRepositoryProvider)
                                .updateServiceRequestStatus(r['id'] as String, 'completed'),
                            child: Text(AppStrings.t(isArabic, 'mark_completed')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _MealRequestsTab extends ConsumerWidget {
  const _MealRequestsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final requestsAsync = ref.watch(ownerMealRequestsProvider);

    return requestsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      error: (err, st) => Center(
        child: Text(AppStrings.t(isArabic, 'something_went_wrong'), style: const TextStyle(color: AppColors.textMuted)),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return Center(
              child: Text(AppStrings.t(isArabic, 'no_hotels_found'), style: const TextStyle(color: AppColors.textMuted)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          itemCount: requests.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
          itemBuilder: (context, index) {
            final r = requests[index];
            final hotel = r['hotels'] as Map<String, dynamic>?;
            final status = r['status'] as String? ?? 'pending';
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
                      Expanded(
                          child: Text('${AppStrings.t(isArabic, "meal_request_label")}: ${AppStrings.t(isArabic, r['meal'] as String? ?? '')}',
                              style: textTheme.titleSmall)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                        ),
                        child: Text(AppStrings.t(isArabic, status),
                            style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(hotel?['name'] as String? ?? '', style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                  if ((r['notes'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(r['notes'] as String, style: textTheme.bodySmall),
                  ],
                  if (status != 'completed') ...[
                    const Divider(height: AppDimens.lg),
                    Row(
                      children: [
                        if (status == 'pending')
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => ref
                                  .read(ownerRequestsRepositoryProvider)
                                  .updateMealRequestStatus(r['id'] as String, 'in_progress'),
                              child: Text(AppStrings.t(isArabic, 'mark_in_progress')),
                            ),
                          ),
                        if (status == 'pending') const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => ref
                                .read(ownerRequestsRepositoryProvider)
                                .updateMealRequestStatus(r['id'] as String, 'completed'),
                            child: Text(AppStrings.t(isArabic, 'mark_completed')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
