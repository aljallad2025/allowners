import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_client.dart';
import '../../services/owner_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/locale_provider.dart';
import '../../utils/tr.dart';

/// طلبات المالك للفندق: النظافة أو السرير الإضافي (type = cleaning | extra_bed)
/// المالك يرسل الطلب → يصل الفندق (إيميل + إشعار) → الفندق يؤكد/ينفّذ مع وصف → يظهر هنا.
class OwnerHotelRequestsScreen extends ConsumerStatefulWidget {
  final String type; // cleaning | extra_bed
  const OwnerHotelRequestsScreen({super.key, required this.type});

  @override
  ConsumerState<OwnerHotelRequestsScreen> createState() => _OwnerHotelRequestsScreenState();
}

class _OwnerHotelRequestsScreenState extends ConsumerState<OwnerHotelRequestsScreen> {
  final _service = OwnerService();
  late Future<List<Map<String, dynamic>>> _future;

  bool get _isCleaning => widget.type == 'cleaning';

  @override
  void initState() {
    super.initState();
    _future = _service.getHotelRequests(widget.type);
  }

  void _reload() => setState(() => _future = _service.getHotelRequests(widget.type));

  String _statusLabel(String s, bool ar) {
    switch (s) {
      case 'confirmed':
        return tr(ar, 'مؤكد من الفندق', 'Confirmed by hotel');
      case 'done':
        return tr(ar, 'تم', 'Done');
      case 'rejected':
        return tr(ar, 'مرفوض', 'Rejected');
      case 'cancelled':
        return tr(ar, 'ملغي', 'Cancelled');
      default:
        return tr(ar, 'بانتظار الفندق', 'Waiting for hotel');
    }
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'confirmed':
      case 'done':
        return AppColors.success;
      case 'rejected':
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Future<void> _newRequest(bool isArabic) async {
    List<Map<String, dynamic>> units = [];
    try {
      final data = await _service.getUnitsFull();
      units = ((data['units'] ?? const []) as List).cast<Map<String, dynamic>>();
    } catch (_) {}
    if (!mounted) return;
    if (units.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr(isArabic, 'لا توجد وحدات مسجلة باسمك', 'You have no registered units'))),
      );
      return;
    }

    Map<String, dynamic> selected = units.first;
    final noteCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Text(_isCleaning ? tr(isArabic, 'طلب نظافة', 'Cleaning request') : tr(isArabic, 'طلب سرير إضافي', 'Extra bed request')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: (selected['id'] as num).toInt(),
                  isExpanded: true,
                  decoration: InputDecoration(labelText: tr(isArabic, 'الوحدة', 'Unit')),
                  items: [
                    for (final u in units)
                      DropdownMenuItem<int>(
                        value: (u['id'] as num).toInt(),
                        child: Text(
                          '${(isArabic ? u['name_ar'] : u['name_en']) ?? u['name_ar'] ?? ''}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) => setDialog(() => selected = units.firstWhere((u) => (u['id'] as num).toInt() == v)),
                ),
                const SizedBox(height: AppDimens.md),
                TextField(
                  controller: noteCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: tr(isArabic, 'وصف الطلب', 'Request details'),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr(isArabic, 'إلغاء', 'Cancel'))),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr(isArabic, 'إرسال للفندق', 'Send to hotel'))),
          ],
        ),
      ),
    );
    final note = noteCtrl.text.trim();
    if (ok != true) return;

    try {
      await _service.createHotelRequest(
        type: widget.type,
        hotelId: (selected['hotel_id'] as num).toInt(),
        unitId: (selected['id'] as num).toInt(),
        description: note,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(isArabic, 'تم إرسال الطلب للفندق', 'Request sent to the hotel'))));
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _cancel(int id, bool isArabic) async {
    try {
      await _service.cancelHotelRequest(id);
      _reload();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final title = _isCleaning ? tr(isArabic, 'طلب النظافة', 'Cleaning requests') : tr(isArabic, 'طلب سرير إضافي', 'Extra bed requests');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.surface, elevation: 0, title: Text(title)),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        onPressed: () => _newRequest(isArabic),
        icon: const Icon(Icons.add_rounded),
        label: Text(tr(isArabic, 'طلب جديد', 'New request')),
      ),
      body: SafeArea(
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
                      child: Center(child: Text(tr(isArabic, 'لا توجد طلبات حالياً', 'No requests yet'))),
                    ),
                  ],
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(AppDimens.pagePadding, AppDimens.pagePadding, AppDimens.pagePadding, 96),
                itemCount: items.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                itemBuilder: (context, index) {
                  final r = items[index];
                  final status = (r['status'] ?? 'pending').toString();
                  final unit = isArabic ? (r['unit_name_ar'] ?? '') : (r['unit_name_en'] ?? r['unit_name_ar'] ?? '');
                  final price = r['price'];
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
                            Expanded(child: Text('${r['hotel_name'] ?? ''} — $unit', style: textTheme.titleSmall)),
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
                        if ((r['description'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(r['description'].toString(), style: textTheme.bodySmall),
                        ],
                        if (price is num) ...[
                          const SizedBox(height: 6),
                          Text('${tr(isArabic, 'السعر', 'Price')}: ${price.toStringAsFixed(0)} ${tr(isArabic, 'ريال', 'SAR')}',
                              style: textTheme.bodySmall?.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                        ],
                        if ((r['hotel_note'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('${tr(isArabic, 'ملاحظة الفندق', 'Hotel note')}: ${r['hotel_note']}',
                              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                        ],
                        if ((r['done_note'] ?? '').toString().isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text('${tr(isArabic, 'التنفيذ', 'Completion')}: ${r['done_note']}',
                              style: textTheme.bodySmall?.copyWith(color: AppColors.success)),
                        ],
                        if (r['can_cancel'] == true)
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton(
                              onPressed: () => _cancel((r['id'] as num).toInt(), isArabic),
                              child: Text(tr(isArabic, 'إلغاء الطلب', 'Cancel request'), style: const TextStyle(color: AppColors.danger)),
                            ),
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
