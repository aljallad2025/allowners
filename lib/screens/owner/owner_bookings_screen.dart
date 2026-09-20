import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/tr.dart';
import '../bookings/edit_booking_dialog.dart';
import '../../services/owner_service.dart';
import '../../services/api_client.dart';

class OwnerBookingsScreen extends ConsumerStatefulWidget {
  const OwnerBookingsScreen({super.key});

  @override
  ConsumerState<OwnerBookingsScreen> createState() => _OwnerBookingsScreenState();
}

class _OwnerBookingsScreenState extends ConsumerState<OwnerBookingsScreen> {
  final _service = OwnerService();
  late Future<Map<String, dynamic>> _future;
  int? _cancellingId;

  @override
  void initState() {
    super.initState();
    _future = _service.getBookings();
  }

  void _reload() => setState(() => _future = _service.getBookings());

  Future<void> _cancelBooking(bool isArabic, int bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.t(isArabic, 'confirm_cancel_booking')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(isArabic, 'cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppStrings.t(isArabic, 'confirm'), style: const TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _cancellingId = bookingId);
    try {
      await _service.cancelBooking(bookingId);
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  /// تأكيد الحجز — يُرسل تلقائياً إيميل + إشعار للفندق والعميل (المالك والفندق والعميل مرتبطون)
  Future<void> _confirmBooking(bool isArabic, int bookingId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr(isArabic, 'تأكيد الحجز', 'Confirm booking')),
        content: Text(tr(isArabic, 'سيتم تأكيد الحجز وإرسال إيميل تلقائي للفندق والعميل.',
            'The booking will be confirmed and an email will be sent automatically to the hotel and the guest.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(isArabic, 'cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr(isArabic, 'تأكيد', 'Confirm'))),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _cancellingId = bookingId);
    try {
      await _service.confirmBooking(bookingId);
      if (mounted) _snack(tr(isArabic, 'تم تأكيد الحجز وإبلاغ الفندق والعميل', 'Booking confirmed — hotel and guest notified'));
      _reload();
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    } finally {
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  Future<void> _editBooking(bool isArabic, Map<String, dynamic> b) async {
    final edit = await showEditBookingDialog(context, b, isArabic, editGuestInfo: true);
    if (edit == null) return;
    try {
      await _service.updateBooking(
        bookingId: (b['id'] as num).toInt(),
        checkIn: edit.checkIn,
        checkOut: edit.checkOut,
        guests: edit.guests,
        guestName: edit.guestName,
        guestPhone: edit.guestPhone,
      );
      if (mounted) _snack(tr(isArabic, 'تم تعديل الحجز', 'Booking updated'));
      _reload();
    } on ApiException catch (e) {
      if (mounted) _snack(e.message);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'checked_in':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.warning;
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
        title: Text(AppStrings.t(isArabic, 'owner_bookings')),
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

              final bookings = (snapshot.data?['bookings'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
              if (bookings.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: Center(child: Text(AppStrings.t(isArabic, 'no_bookings'))),
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                itemCount: bookings.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                itemBuilder: (context, index) {
                  final b = bookings[index];
                  final status = (b['status'] ?? 'pending').toString();
                  final guestName = (b['guest_name'] ?? AppStrings.t(isArabic, 'guest')).toString();
                  final unitName = isArabic ? (b['unit_name_ar'] ?? b['unit_name'] ?? '') : (b['unit_name_en'] ?? b['unit_name_ar'] ?? b['unit_name'] ?? '');
                  final total = (b['total'] is num) ? (b['total'] as num).toStringAsFixed(0) : '0';

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
                            Expanded(child: Text(guestName, style: textTheme.titleSmall)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                              ),
                              child: Text(
                                AppStrings.t(isArabic, 'status_$status'),
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${b['hotel_name'] ?? ''} — $unitName', style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                        if (b['payment_method'] == 'owner_transfer')
                          Text(tr(isArabic, 'الدفع: تحويل مباشر لحسابك', 'Payment: direct transfer to your account'),
                              style: textTheme.bodySmall?.copyWith(color: AppColors.goldDark)),
                        if ((b['guest_phone'] ?? '').toString().isNotEmpty)
                          Text('📞 ${b['guest_phone']}', style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                        if ((b['guest_id_number'] ?? '').toString().isNotEmpty)
                          Text('ID: ${b['guest_id_number']}', style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                        const Divider(height: AppDimens.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${AppStrings.t(isArabic, 'check_in')}: ${b['check_in']}', style: textTheme.bodySmall),
                            Text('${AppStrings.t(isArabic, 'check_out')}: ${b['check_out']}', style: textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(AppStrings.t(isArabic, 'total_amount'), style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                            Text('$total ${AppStrings.t(isArabic, 'sar')}', style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
                          ],
                        ),
                        if (b['can_confirm'] == true || b['can_edit'] == true || b['can_cancel'] == true) ...[
                          const SizedBox(height: AppDimens.sm),
                          if (b['can_confirm'] == true)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _cancellingId == b['id'] ? null : () => _confirmBooking(isArabic, (b['id'] as num).toInt()),
                                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                                label: Text(tr(isArabic, 'تأكيد الحجز', 'Confirm booking')),
                              ),
                            ),
                          if (b['can_confirm'] == true) const SizedBox(height: AppDimens.sm),
                          Row(
                            children: [
                              if (b['can_edit'] == true)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _cancellingId == b['id'] ? null : () => _editBooking(isArabic, b),
                                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                                    label: Text(tr(isArabic, 'تعديل الحجز', 'Edit booking')),
                                  ),
                                ),
                              if (b['can_edit'] == true && b['can_cancel'] == true) const SizedBox(width: AppDimens.sm),
                              if (b['can_cancel'] == true)
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                                    onPressed: _cancellingId == b['id'] ? null : () => _cancelBooking(isArabic, (b['id'] as num).toInt()),
                                    child: Text(AppStrings.t(isArabic, 'cancel_booking')),
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
          ),
        ),
      ),
    );
  }
}
