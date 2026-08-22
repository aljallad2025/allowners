import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../services/owner_service.dart';
import 'owner_agent_new_booking_screen.dart';

class OwnerCommissionScreen extends ConsumerStatefulWidget {
  const OwnerCommissionScreen({super.key});

  @override
  ConsumerState<OwnerCommissionScreen> createState() => _OwnerCommissionScreenState();
}

class _OwnerCommissionScreenState extends ConsumerState<OwnerCommissionScreen> {
  final _service = OwnerService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getCommission();
  }

  void _reload() => setState(() => _future = _service.getCommission());

  String _statusLabel(String status, bool isArabic) {
    const labels = {
      'pending': {'ar': 'قيد الانتظار', 'en': 'Pending'},
      'unpaid': {'ar': 'غير مدفوعة', 'en': 'Unpaid'},
      'paid': {'ar': 'مدفوعة', 'en': 'Paid'},
    };
    return labels[status]?[isArabic ? 'ar' : 'en'] ?? status;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return AppColors.success;
      case 'unpaid':
        return AppColors.danger;
      default:
        return AppColors.goldDark;
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
        title: Text(AppStrings.t(isArabic, 'my_commission')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const OwnerAgentNewBookingScreen()))
              .then((_) => _reload());
        },
        icon: const Icon(Icons.add, color: AppColors.textOnGold),
        label: Text(AppStrings.t(isArabic, 'new_booking'), style: const TextStyle(color: AppColors.textOnGold)),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: FutureBuilder<Map<String, dynamic>>(
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

              final data = snapshot.data ?? {};
              final paid = (data['paid_total'] is num) ? (data['paid_total'] as num).toStringAsFixed(0) : '0';
              final unpaid = (data['unpaid_total'] is num) ? (data['unpaid_total'] as num).toStringAsFixed(0) : '0';
              final commissions = (data['commissions'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppDimens.md),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppStrings.t(isArabic, 'paid_commission'),
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('$paid ${AppStrings.t(isArabic, "sar")}',
                                  style: textTheme.titleLarge?.copyWith(color: AppColors.success)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppDimens.md),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppDimens.md),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(AppStrings.t(isArabic, 'pending_commission'),
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('$unpaid ${AppStrings.t(isArabic, "sar")}',
                                  style: textTheme.titleLarge?.copyWith(color: AppColors.goldDark)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.xl),
                  Text(AppStrings.t(isArabic, 'my_bookings'), style: textTheme.titleMedium),
                  const SizedBox(height: AppDimens.md),
                  if (commissions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppDimens.xl),
                      child: Center(child: Text(AppStrings.t(isArabic, 'no_bookings_yet'))),
                    )
                  else
                    ...commissions.map((c) {
                      final status = c['status']?.toString() ?? 'pending';
                      final amount = (c['amount'] is num) ? (c['amount'] as num).toStringAsFixed(0) : '0';
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppDimens.sm),
                        padding: const EdgeInsets.all(AppDimens.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c['hotel_name']?.toString() ?? '', style: textTheme.bodyMedium),
                                  Text(c['booking_ref']?.toString() ?? '',
                                      style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('$amount ${AppStrings.t(isArabic, "sar")}',
                                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: AppColors.goldDark)),
                                Text(_statusLabel(status, isArabic),
                                    style: TextStyle(fontSize: 11, color: _statusColor(status), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
