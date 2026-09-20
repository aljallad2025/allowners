import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_client.dart';
import '../../services/hotel_staff_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/locale_provider.dart';
import '../../utils/tr.dart';

/// طلبات الفندق (من المالك / الضيف): النظافة | الصيانة | الوجبات | السرير الإضافي
/// كل طلب: تأكيد + وصف (+ سعر) ثم «تم» + وصف، أو رفض مع سبب.
class HotelRequestsScreen extends ConsumerStatefulWidget {
  final String initialType;
  const HotelRequestsScreen({super.key, this.initialType = 'cleaning'});

  @override
  ConsumerState<HotelRequestsScreen> createState() => _HotelRequestsScreenState();
}

class _HotelRequestsScreenState extends ConsumerState<HotelRequestsScreen> {
  final _service = HotelStaffService();
  late String _type;
  bool _showAll = false;
  late Future<List<Map<String, dynamic>>> _future;

  static const _types = ['cleaning', 'maintenance', 'meal', 'extra_bed'];

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _future = _service.getRequests(_type, all: _showAll);
  }

  void _reload() => setState(() => _future = _service.getRequests(_type, all: _showAll));

  String _typeLabel(String t, bool ar) {
    switch (t) {
      case 'cleaning':
        return tr(ar, 'النظافة', 'Cleaning');
      case 'maintenance':
        return tr(ar, 'الصيانة', 'Maintenance');
      case 'meal':
        return tr(ar, 'الوجبات', 'Meals');
      default:
        return tr(ar, 'السرير الإضافي', 'Extra bed');
    }
  }

  String _statusLabel(String s, bool ar) {
    switch (s) {
      case 'confirmed':
        return tr(ar, 'مؤكد', 'Confirmed');
      case 'done':
        return tr(ar, 'تم', 'Done');
      case 'rejected':
        return tr(ar, 'مرفوض', 'Rejected');
      default:
        return tr(ar, 'جديد', 'New');
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':
        return AppColors.secondary;
      case 'done':
        return AppColors.success;
      case 'rejected':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  String _mealLabel(String? m, bool ar) {
    switch (m) {
      case 'breakfast':
        return tr(ar, 'فطور', 'Breakfast');
      case 'lunch':
        return tr(ar, 'غداء', 'Lunch');
      case 'dinner':
        return tr(ar, 'عشاء', 'Dinner');
      default:
        return '';
    }
  }

  /// حوار الإجراء: وصف/ملاحظة (+ سعر عند التأكيد) ثم إرسال للسيرفر
  Future<void> _act(Map<String, dynamic> r, String action, bool isArabic) async {
    final needsPrice = action == 'confirm';
    final noteRequired = action == 'reject';
    final noteCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: r['price'] is num ? (r['price'] as num).toStringAsFixed(0) : '');

    String title;
    switch (action) {
      case 'confirm':
        title = tr(isArabic, 'تأكيد الطلب', 'Confirm request');
        break;
      case 'done':
        title = _type == 'maintenance' ? tr(isArabic, 'تمت الصيانة', 'Maintenance completed') : tr(isArabic, 'تم التنفيذ', 'Mark as done');
        break;
      case 'preparing':
        title = tr(isArabic, 'قيد التحضير', 'Preparing');
        break;
      case 'delivered':
        title = tr(isArabic, 'تم التسليم', 'Delivered');
        break;
      default:
        title = tr(isArabic, 'رفض الطلب', 'Reject request');
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: noteCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: noteRequired ? tr(isArabic, 'سبب الرفض', 'Rejection reason') : tr(isArabic, 'الوصف', 'Description'),
                  alignLabelWithHint: true,
                ),
              ),
              if (needsPrice || action == 'done') ...[
                const SizedBox(height: AppDimens.md),
                TextField(
                  controller: priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: tr(isArabic, 'السعر (ريال) — اختياري', 'Price (SAR) — optional')),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr(isArabic, 'إلغاء', 'Cancel'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr(isArabic, 'إرسال', 'Send'))),
        ],
      ),
    );
    final note = noteCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text.trim());
    if (ok != true) return;
    if (noteRequired && note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(isArabic, 'الرجاء كتابة سبب الرفض', 'Please write the rejection reason'))));
      return;
    }

    try {
      await _service.requestAction(
        type: _type,
        id: (r['id'] as num).toInt(),
        action: action,
        note: note,
        price: (needsPrice || action == 'done') ? price : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(isArabic, 'تم إبلاغ صاحب الطلب والمالك', 'The requester and the owner were notified'))));
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  List<Widget> _actions(Map<String, dynamic> r, bool isArabic) {
    final status = (r['status'] ?? 'pending').toString();
    final isMeal = _type == 'meal';
    final doneLabel = _type == 'maintenance' ? tr(isArabic, 'تمت الصيانة', 'Completed') : tr(isArabic, 'تم', 'Done');

    if (status == 'pending') {
      return [
        Expanded(child: ElevatedButton(onPressed: () => _act(r, 'confirm', isArabic), child: Text(tr(isArabic, 'تأكيد الطلب', 'Confirm')))),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
            onPressed: () => _act(r, 'reject', isArabic),
            child: Text(tr(isArabic, 'رفض', 'Reject')),
          ),
        ),
      ];
    }
    if (status == 'confirmed') {
      if (isMeal) {
        return [
          Expanded(child: OutlinedButton(onPressed: () => _act(r, 'preparing', isArabic), child: Text(tr(isArabic, 'قيد التحضير', 'Preparing')))),
          const SizedBox(width: AppDimens.sm),
          Expanded(child: ElevatedButton(onPressed: () => _act(r, 'delivered', isArabic), child: Text(tr(isArabic, 'تم التسليم', 'Delivered')))),
        ];
      }
      return [Expanded(child: ElevatedButton(onPressed: () => _act(r, 'done', isArabic), child: Text(doneLabel)))];
    }
    return const [];
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
        title: Text(tr(isArabic, 'طلبات الفندق', 'Hotel requests')),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _showAll = !_showAll);
              _reload();
            },
            child: Text(_showAll ? tr(isArabic, 'المفتوحة فقط', 'Open only') : tr(isArabic, 'عرض الكل', 'Show all')),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding, vertical: 8),
                children: [
                  for (final t in _types)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: AppDimens.sm),
                      child: ChoiceChip(
                        label: Text(_typeLabel(t, isArabic)),
                        selected: _type == t,
                        selectedColor: AppColors.gold.withOpacity(0.25),
                        onSelected: (_) {
                          setState(() => _type = t);
                          _reload();
                        },
                      ),
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
                            child: Center(child: Text(tr(isArabic, 'لا توجد طلبات', 'No requests'))),
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
                        final r = items[index];
                        final status = (r['status'] ?? 'pending').toString();
                        final unit = isArabic ? (r['unit_name_ar'] ?? '') : (r['unit_name_en'] ?? r['unit_name_ar'] ?? '');
                        final actions = _actions(r, isArabic);
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
                                    child: Text(
                                      '${r['hotel_name'] ?? ''}${unit.toString().isNotEmpty ? ' — $unit' : ''}',
                                      style: textTheme.titleSmall,
                                    ),
                                  ),
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
                              Text(
                                '${tr(isArabic, 'من', 'From')}: ${r['requester_name'] ?? ''}${r['booking_ref'] != null ? '  •  ${r['booking_ref']}' : ''}',
                                style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                              ),
                              if (_type == 'meal' && r['meal_type'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(_mealLabel(r['meal_type']?.toString(), isArabic),
                                      style: textTheme.titleSmall?.copyWith(color: AppColors.goldDark)),
                                ),
                              if ((r['description'] ?? '').toString().isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(r['description'].toString(), style: textTheme.bodySmall),
                              ],
                              if (r['price'] is num) ...[
                                const SizedBox(height: 6),
                                Text('${tr(isArabic, 'السعر', 'Price')}: ${(r['price'] as num).toStringAsFixed(0)} ${tr(isArabic, 'ريال', 'SAR')}',
                                    style: textTheme.bodySmall?.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                              ],
                              if ((r['hotel_note'] ?? '').toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('${tr(isArabic, 'ملاحظتك', 'Your note')}: ${r['hotel_note']}',
                                    style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                              ],
                              if ((r['done_note'] ?? '').toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('${tr(isArabic, 'التنفيذ', 'Completion')}: ${r['done_note']}',
                                    style: textTheme.bodySmall?.copyWith(color: AppColors.success)),
                              ],
                              if (actions.isNotEmpty) ...[
                                const SizedBox(height: AppDimens.sm),
                                Row(children: actions),
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
