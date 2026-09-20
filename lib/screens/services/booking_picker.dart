import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/hotel_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/locale_provider.dart';
import '../../utils/tr.dart';

/// اختيار الحجز (المؤكد فقط) الذي سيُرسل عليه طلب الوجبات/الخدمات للفندق
class ConfirmedBookingPicker extends ConsumerStatefulWidget {
  final ValueChanged<int?> onChanged;
  const ConfirmedBookingPicker({super.key, required this.onChanged});

  @override
  ConsumerState<ConfirmedBookingPicker> createState() => _ConfirmedBookingPickerState();
}

class _ConfirmedBookingPickerState extends ConsumerState<ConfirmedBookingPicker> {
  List<Map<String, dynamic>> _bookings = [];
  int? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final all = await HotelService().myBookings();
      final ok = all.where((b) => b['can_request_services'] == true).toList();
      if (!mounted) return;
      setState(() {
        _bookings = ok;
        _selected = ok.isNotEmpty ? (ok.first['id'] as num).toInt() : null;
        _loading = false;
      });
      widget.onChanged(_selected);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
      widget.onChanged(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.md),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.gold)),
      );
    }
    if (_error != null || _bookings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.10),
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
        child: Text(
          _error ??
              tr(isArabic, 'يتاح إرسال الطلبات بعد تأكيد الحجز. لا يوجد لديك حجز مؤكد حالياً.',
                  'Requests are available after your booking is confirmed. You have no confirmed booking right now.'),
          style: const TextStyle(color: AppColors.goldDark, height: 1.5),
        ),
      );
    }

    return DropdownButtonFormField<int>(
      value: _selected,
      isExpanded: true,
      decoration: InputDecoration(labelText: tr(isArabic, 'الحجز', 'Booking')),
      items: [
        for (final b in _bookings)
          DropdownMenuItem<int>(
            value: (b['id'] as num).toInt(),
            child: Text(
              '${b['hotel_name'] ?? ''}${(isArabic ? b['unit_name_ar'] : b['unit_name_en']) != null ? ' — ${isArabic ? b['unit_name_ar'] : b['unit_name_en']}' : ''}  •  ${b['check_in']}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      onChanged: (v) {
        setState(() => _selected = v);
        widget.onChanged(v);
      },
    );
  }
}
