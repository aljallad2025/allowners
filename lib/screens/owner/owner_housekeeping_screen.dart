import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../services/owner_service.dart';
import '../../services/api_client.dart';

class OwnerHousekeepingScreen extends ConsumerStatefulWidget {
  const OwnerHousekeepingScreen({super.key});

  @override
  ConsumerState<OwnerHousekeepingScreen> createState() => _OwnerHousekeepingScreenState();
}

class _OwnerHousekeepingScreenState extends ConsumerState<OwnerHousekeepingScreen> {
  final _service = OwnerService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getHousekeeping();
  }

  void _reload() => setState(() => _future = _service.getHousekeeping());

  Color _statusColor(String status) {
    switch (status) {
      case 'ready':
        return AppColors.success;
      case 'needs_maintenance':
        return AppColors.danger;
      default:
        return AppColors.goldDark;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'ready':
        return Icons.check_circle_outline_rounded;
      case 'needs_maintenance':
        return Icons.build_outlined;
      default:
        return Icons.cleaning_services_outlined;
    }
  }

  Future<void> _changeStatus(int unitId, String newStatus) async {
    try {
      await _service.updateHousekeepingStatus(unitId, newStatus);
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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
        title: Text(AppStrings.t(isArabic, 'housekeeping_status')),
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
              final units = (data['units'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
              final canEdit = data['can_edit'] == true;

              if (units.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: Center(child: Text(isArabic ? 'ما في وحدات بعد' : 'No units yet')),
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                itemCount: units.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                itemBuilder: (context, index) {
                  final u = units[index];
                  final status = u['hk_status']?.toString() ?? 'ready';
                  final name = isArabic ? (u['name_ar'] ?? '').toString() : (u['name_en'] ?? '').toString();

                  return Container(
                    padding: const EdgeInsets.all(AppDimens.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                          ),
                          child: Icon(_statusIcon(status), color: _statusColor(status)),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: textTheme.titleSmall),
                              Text(u['hotel_name']?.toString() ?? '',
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                        if (canEdit)
                          PopupMenuButton<String>(
                            onSelected: (v) => _changeStatus(u['id'] as int, v),
                            itemBuilder: (context) => [
                              PopupMenuItem(value: 'ready', child: Text(AppStrings.t(isArabic, 'ready'))),
                              PopupMenuItem(value: 'cleaning', child: Text(AppStrings.t(isArabic, 'cleaning'))),
                              PopupMenuItem(value: 'needs_maintenance', child: Text(AppStrings.t(isArabic, 'needs_maintenance'))),
                            ],
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(AppStrings.t(isArabic, status),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status))),
                                  const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                                ],
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                            ),
                            child: Text(AppStrings.t(isArabic, status),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status))),
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
