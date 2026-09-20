import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/tr.dart';

/// نتيجة حوار تعديل الحجز
class BookingEdit {
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String guestName;
  final String guestPhone;
  const BookingEdit({
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.guestName,
    required this.guestPhone,
  });
}

String formatBookingDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// حوار تعديل حجز (تواريخ + ضيوف + اسم/جوال الضيف اختيارياً) — يُستخدم عند الضيف/الوكيل/المالك
/// السعر يُعاد حسابه على السيرفر تلقائياً بعد الحفظ.
Future<BookingEdit?> showEditBookingDialog(
  BuildContext context,
  Map<String, dynamic> booking,
  bool isArabic, {
  bool editGuestInfo = false,
}) async {
  DateTime parse(String? v) => DateTime.tryParse(v ?? '') ?? DateTime.now();
  DateTime checkIn = parse(booking['check_in']?.toString());
  DateTime checkOut = parse(booking['check_out']?.toString());
  int guests = int.tryParse('${booking['guests']}') ?? 1;
  final nameCtrl = TextEditingController(text: booking['guest_name']?.toString() ?? '');
  final phoneCtrl = TextEditingController(text: booking['guest_phone']?.toString() ?? '');

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialog) {
        Future<void> pick(bool isIn) async {
          final first = isIn ? DateTime.now() : checkIn.add(const Duration(days: 1));
          final current = isIn ? checkIn : checkOut;
          final picked = await showDatePicker(
            context: ctx,
            initialDate: current.isBefore(first) ? first : current,
            firstDate: first,
            lastDate: DateTime.now().add(const Duration(days: 730)),
          );
          if (picked == null) return;
          setDialog(() {
            if (isIn) {
              checkIn = picked;
              if (!checkOut.isAfter(checkIn)) checkOut = checkIn.add(const Duration(days: 1));
            } else {
              checkOut = picked;
            }
          });
        }

        return AlertDialog(
          title: Text(tr(isArabic, 'تعديل الحجز', 'Edit booking')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.login_rounded),
                  title: Text(tr(isArabic, 'تاريخ الوصول', 'Check-in')),
                  trailing: Text(formatBookingDate(checkIn)),
                  onTap: () => pick(true),
                ),
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.logout_rounded),
                  title: Text(tr(isArabic, 'تاريخ المغادرة', 'Check-out')),
                  trailing: Text(formatBookingDate(checkOut)),
                  onTap: () => pick(false),
                ),
                Row(
                  children: [
                    Expanded(child: Text(tr(isArabic, 'عدد الضيوف', 'Guests'))),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () => setDialog(() => guests = guests > 1 ? guests - 1 : 1),
                    ),
                    Text('$guests'),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setDialog(() => guests++),
                    ),
                  ],
                ),
                if (editGuestInfo) ...[
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(labelText: tr(isArabic, 'اسم الضيف / العميل', 'Guest / customer name')),
                  ),
                  const SizedBox(height: AppDimens.sm),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: tr(isArabic, 'الجوال', 'Phone')),
                  ),
                ],
                const SizedBox(height: AppDimens.sm),
                Text(
                  tr(isArabic, 'سيُعاد حساب السعر تلقائياً حسب التواريخ الجديدة.',
                      'The price will be recalculated automatically for the new dates.'),
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(tr(isArabic, 'إلغاء', 'Cancel'))),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(tr(isArabic, 'حفظ التعديل', 'Save changes'))),
          ],
        );
      },
    ),
  );

  if (saved != true) return null;
  return BookingEdit(
    checkIn: checkIn,
    checkOut: checkOut,
    guests: guests,
    guestName: nameCtrl.text.trim(),
    guestPhone: phoneCtrl.text.trim(),
  );
}
