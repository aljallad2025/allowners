import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../services/owner_service.dart';
import '../../services/api_client.dart';

class OwnerAgentNewBookingScreen extends ConsumerStatefulWidget {
  const OwnerAgentNewBookingScreen({super.key});

  @override
  ConsumerState<OwnerAgentNewBookingScreen> createState() => _OwnerAgentNewBookingScreenState();
}

class _OwnerAgentNewBookingScreenState extends ConsumerState<OwnerAgentNewBookingScreen> {
  final _service = OwnerService();
  final _guestNameCtrl = TextEditingController();
  final _guestPhoneCtrl = TextEditingController();

  List<Map<String, dynamic>> _hotels = [];
  List<Map<String, dynamic>> _units = [];
  int? _selectedHotelId;
  int? _selectedUnitId;
  DateTime _checkIn = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOut = DateTime.now().add(const Duration(days: 2));
  int _guests = 1;
  bool _isLoadingHotels = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadHotels();
  }

  @override
  void dispose() {
    _guestNameCtrl.dispose();
    _guestPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadHotels() async {
    try {
      final hotels = await _service.getHotels();
      if (!mounted) return;
      setState(() {
        _hotels = hotels;
        _selectedHotelId = hotels.isNotEmpty ? hotels.first['id'] as int : null;
        _isLoadingHotels = false;
      });
      if (_selectedHotelId != null) _loadUnits(_selectedHotelId!);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingHotels = false);
    }
  }

  Future<void> _loadUnits(int hotelId) async {
    try {
      final allUnits = await _service.getUnits();
      if (!mounted) return;
      setState(() {
        _units = allUnits.where((u) => u['hotel_id'] == hotelId || u['hotel_id']?.toString() == hotelId.toString()).toList();
        _selectedUnitId = _units.isNotEmpty ? _units.first['id'] as int : null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _units = [];
        _selectedUnitId = null;
      });
    }
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initial = isCheckIn ? _checkIn : _checkOut;
    final firstDate = isCheckIn ? DateTime.now() : _checkIn.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (!_checkOut.isAfter(_checkIn)) _checkOut = _checkIn.add(const Duration(days: 1));
      } else {
        _checkOut = picked;
      }
    });
  }

  Future<void> _submit(bool isArabic) async {
    if (_selectedHotelId == null || _selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'الرجاء اختيار الفندق والوحدة' : 'Please select hotel and unit')),
      );
      return;
    }
    if (_guestNameCtrl.text.trim().isEmpty || _guestPhoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isArabic ? 'الرجاء تعبئة اسم ورقم هاتف الضيف' : 'Please fill guest name and phone')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await _service.agentCreateBooking(
        hotelId: _selectedHotelId!,
        unitId: _selectedUnitId!,
        guestName: _guestNameCtrl.text.trim(),
        guestPhone: _guestPhoneCtrl.text.trim(),
        checkIn: _checkIn,
        checkOut: _checkOut,
        guests: _guests,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${isArabic ? "تم إنشاء الحجز" : "Booking created"}: ${result['booking_ref']}')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _fmtDate(DateTime d, bool isArabic) {
    const monthsAr = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    const monthsEn = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return isArabic ? '${d.day} ${monthsAr[d.month - 1]}' : '${monthsEn[d.month - 1]} ${d.day}';
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
        title: Text(AppStrings.t(isArabic, 'new_booking')),
      ),
      body: SafeArea(
        child: _isLoadingHotels
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.t(isArabic, 'select_hotel'), style: textTheme.titleSmall),
                    const SizedBox(height: AppDimens.sm),
                    DropdownButtonFormField<int>(
                      value: _selectedHotelId,
                      items: _hotels
                          .map((h) => DropdownMenuItem<int>(value: h['id'] as int, child: Text(h['name'].toString())))
                          .toList(),
                      onChanged: (v) {
                        setState(() => _selectedHotelId = v);
                        if (v != null) _loadUnits(v);
                      },
                    ),
                    const SizedBox(height: AppDimens.md),

                    Text(AppStrings.t(isArabic, 'select_unit'), style: textTheme.titleSmall),
                    const SizedBox(height: AppDimens.sm),
                    DropdownButtonFormField<int>(
                      value: _selectedUnitId,
                      items: _units
                          .map((u) => DropdownMenuItem<int>(
                                value: u['id'] as int,
                                child: Text(isArabic ? (u['name_ar'] ?? '').toString() : (u['name_en'] ?? '').toString()),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedUnitId = v),
                    ),
                    const SizedBox(height: AppDimens.lg),

                    Text(AppStrings.t(isArabic, 'guest_name'), style: textTheme.titleSmall),
                    const SizedBox(height: AppDimens.sm),
                    TextField(controller: _guestNameCtrl),
                    const SizedBox(height: AppDimens.md),

                    Text(AppStrings.t(isArabic, 'guest_phone'), style: textTheme.titleSmall),
                    const SizedBox(height: AppDimens.sm),
                    TextField(controller: _guestPhoneCtrl, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr),
                    const SizedBox(height: AppDimens.lg),

                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(isCheckIn: true),
                            child: Container(
                              padding: const EdgeInsets.all(AppDimens.sm),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppStrings.t(isArabic, 'check_in'), style: textTheme.labelSmall),
                                  Text(_fmtDate(_checkIn, isArabic), style: textTheme.titleSmall),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(isCheckIn: false),
                            child: Container(
                              padding: const EdgeInsets.all(AppDimens.sm),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(AppStrings.t(isArabic, 'check_out'), style: textTheme.labelSmall),
                                  Text(_fmtDate(_checkOut, isArabic), style: textTheme.titleSmall),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),

                    Row(
                      children: [
                        Expanded(child: Text(AppStrings.t(isArabic, 'guests'), style: textTheme.bodyMedium)),
                        IconButton(
                          onPressed: () => setState(() => _guests = _guests > 1 ? _guests - 1 : 1),
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                        ),
                        Text('$_guests', style: textTheme.titleMedium),
                        IconButton(
                          onPressed: () => setState(() => _guests++),
                          icon: const Icon(Icons.add_circle_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.xl),

                    SizedBox(
                      width: double.infinity,
                      height: AppDimens.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : () => _submit(isArabic),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                              )
                            : Text(AppStrings.t(isArabic, 'confirm_booking')),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
