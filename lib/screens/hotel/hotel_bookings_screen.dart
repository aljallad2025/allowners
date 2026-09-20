import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_client.dart';
import '../../services/hotel_staff_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/locale_provider.dart';
import '../../utils/tr.dart';

/// حجوزات الفندق: تأكيد دخول العميل ثم تأكيد خروجه (يصل إشعار + إيميل للمالك والعميل)
class HotelBookingsScreen extends ConsumerStatefulWidget {
  const HotelBookingsScreen({super.key});

  @override
  ConsumerState<HotelBookingsScreen> createState() => _HotelBookingsScreenState();
}

class _HotelBookingsScreenState extends ConsumerState<HotelBookingsScreen> {
  final _service = HotelStaffService();
  String _scope = 'active';
  late Future<List<Map<String, dynamic>>> _future;
  int? _busyId;

  @override
  void initState() {
    super.initState();
    _future = _service.getBookings(scope: _scope);
  }

  void _reload() => setState(() => _future = _service.getBookings(scope: _scope));

  String _statusLabel(String s, bool ar) {
    switch (s) {
      case 'checked_in':
        return tr(ar, 'مقيم', 'Checked in');
      case 'completed':
        return tr(ar, 'انتهى', 'Completed');
      case 'cancelled':
        return tr(ar, 'ملغي', 'Cancelled');
      default:
        return tr(ar, 'مؤكد', 'Confirmed');
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'checked_in':
        return AppColors.secondary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.goldDark;
    }
  }

  Future<void> _action(Map<String, dynamic> b, String action, bool isArabic) async {
    final isIn = action == 'check_in';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isIn ? tr(isArabic, 'تأكيد دخول العميل', 'Confirm guest check-in') : tr(isArabic, 'تأكيد خروج العميل', 'Confirm guest check-out')),
        content: Text('${b['guest_name'] ?? ''}  •  ${b['booking_ref'] ?? ''}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr(isArabic, 'إلغاء', 'Cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr(isArabic, 'تأكيد', 'Confirm'))),
        ],
      ),
    );
    if (ok != true) return;
    final id = (b['id'] as num).toInt();
    setState(() => _busyId = id);
    try {
      await _service.bookingAction(id, action);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
          isIn ? tr(isArabic, 'تم تأكيد دخول العميل', 'Guest check-in confirmed') : tr(isArabic, 'تم تأكيد خروج العميل', 'Guest check-out confirmed'))));
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _busyId = null);
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
        title: Text(tr(isArabic, 'حجوزات الفندق', 'Hotel bookings')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding, vertical: 8),
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(tr(isArabic, 'الحالية', 'Active')),
                    selected: _scope == 'active',
                    selectedColor: AppColors.gold.withOpacity(0.25),
                    onSelected: (_) {
                      setState(() => _scope = 'active');
                      _reload();
                    },
                  ),
                  const SizedBox(width: AppDimens.sm),
                  ChoiceChip(
                    label: Text(tr(isArabic, 'السجل', 'History')),
                    selected: _scope == 'history',
                    selectedColor: AppColors.gold.withOpacity(0.25),
                    onSelected: (_) {
                      setState(() => _scope = 'history');
                      _reload();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                    }
                    if (snapshot.hasError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppDimens.xl),
                        children: [
                          Text(snapshot.error.toString(), textAlign: TextAlign.center),
                          Center(child: TextButton(onPressed: _reload, child: Text(tr(isArabic, 'إعادة المحاولة', 'Retry')))),
                        ],
                      );
                    }
                    final items = snapshot.data ?? const [];
                    if (items.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppDimens.xl),
                            child: Center(child: Text(tr(isArabic, 'لا توجد حجوزات', 'No bookings'))),
                          ),
                        ],
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppDimens.pagePadding),
                      itemCount: items.length,
                      separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                      itemBuilder: (context, index) {
                        final b = items[index];
                        final status = (b['status'] ?? 'confirmed').toString();
                        final unit = isArabic ? (b['unit_name_ar'] ?? '') : (b['unit_name_en'] ?? b['unit_name_ar'] ?? '');
                        final busy = _busyId == (b['id'] as num).toInt();
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
                                  Expanded(child: Text('${b['guest_name'] ?? ''}', style: textTheme.titleSmall)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(status).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                    ),
                                    child: Text(_statusLabel(status, isArabic),
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status))),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${b['hotel_name'] ?? ''}${unit.toString().isNotEmpty ? ' — $unit' : ''}',
                                  style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                              Text('${b['booking_ref'] ?? ''}', style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                              if ((b['guest_phone'] ?? '').toString().isNotEmpty)
                                Text('📞 ${b['guest_phone']}', style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                              if ((b['guest_id_number'] ?? '').toString().isNotEmpty)
                                Text('ID: ${b['guest_id_number']}', style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                              const Divider(height: AppDimens.lg),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${tr(isArabic, 'الوصول', 'Check-in')}: ${b['check_in']}', style: textTheme.bodySmall),
                                  Text('${tr(isArabic, 'المغادرة', 'Check-out')}: ${b['check_out']}', style: textTheme.bodySmall),
                                ],
                              ),
                              if (b['can_check_in'] == true || b['can_check_out'] == true) ...[
                                const SizedBox(height: AppDimens.sm),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: busy ? null : () => _action(b, b['can_check_in'] == true ? 'check_in' : 'check_out', isArabic),
                                    icon: Icon(b['can_check_in'] == true ? Icons.login_rounded : Icons.logout_rounded, size: 18),
                                    label: Text(b['can_check_in'] == true
                                        ? tr(isArabic, 'تأكيد دخول العميل', 'Confirm check-in')
                                        : tr(isArabic, 'تأكيد خروج العميل', 'Confirm check-out')),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
