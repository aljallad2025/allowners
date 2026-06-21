import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/hotel_model.dart';
import 'booking_success_screen.dart';

enum PaymentMethod { online, atHotel }

class BookingScreen extends ConsumerStatefulWidget {
  final HotelModel hotel;
  const BookingScreen({super.key, required this.hotel});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.online;
  int _guests = 2;
  int _nights = 2;
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardNameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final hotel = widget.hotel;

    final roomPrice = hotel.pricePerNight * _nights;
    final taxes = roomPrice * 0.15;
    final total = roomPrice + taxes;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'booking_summary'))),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimens.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: hotel.imageUrl,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.image_outlined, color: AppColors.textMuted),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(hotel.name, style: textTheme.titleSmall),
                                Text(hotel.city(isArabic),
                                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimens.lg),

                    Text(AppStrings.t(isArabic, 'your_stay'), style: textTheme.titleMedium),
                    const SizedBox(height: AppDimens.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.calendar_today_outlined,
                            label: AppStrings.t(isArabic, 'check_in'),
                            value: '24 يونيو',
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.calendar_today_outlined,
                            label: AppStrings.t(isArabic, 'check_out'),
                            value: '26 يونيو',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.md),
                    Row(
                      children: [
                        Expanded(
                          child: _StepperBox(
                            label: AppStrings.t(isArabic, 'guests'),
                            value: _guests,
                            onMinus: () => setState(() => _guests = _guests > 1 ? _guests - 1 : 1),
                            onPlus: () => setState(() => _guests++),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: _StepperBox(
                            label: AppStrings.t(isArabic, 'nights'),
                            value: _nights,
                            onMinus: () => setState(() => _nights = _nights > 1 ? _nights - 1 : 1),
                            onPlus: () => setState(() => _nights++),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.lg),

                    Text(AppStrings.t(isArabic, 'payment_method'), style: textTheme.titleMedium),
                    const SizedBox(height: AppDimens.sm),
                    _PaymentOption(
                      icon: Icons.credit_card_rounded,
                      label: AppStrings.t(isArabic, 'pay_online'),
                      selected: _paymentMethod == PaymentMethod.online,
                      onTap: () => setState(() => _paymentMethod = PaymentMethod.online),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    _PaymentOption(
                      icon: Icons.storefront_outlined,
                      label: AppStrings.t(isArabic, 'pay_at_hotel'),
                      selected: _paymentMethod == PaymentMethod.atHotel,
                      onTap: () => setState(() => _paymentMethod = PaymentMethod.atHotel),
                    ),

                    if (_paymentMethod == PaymentMethod.online) ...[
                      const SizedBox(height: AppDimens.md),
                      TextField(
                        controller: _cardNumberController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: AppStrings.t(isArabic, 'card_number'),
                          prefixIcon: const Icon(Icons.credit_card_outlined),
                        ),
                      ),
                      const SizedBox(height: AppDimens.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _expiryController,
                              decoration: InputDecoration(hintText: AppStrings.t(isArabic, 'expiry_date')),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sm),
                          Expanded(
                            child: TextField(
                              controller: _cvvController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(hintText: AppStrings.t(isArabic, 'cvv')),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.sm),
                      TextField(
                        controller: _cardNameController,
                        decoration: InputDecoration(hintText: AppStrings.t(isArabic, 'cardholder_name')),
                      ),
                    ],
                    const SizedBox(height: AppDimens.lg),

                    Text(AppStrings.t(isArabic, 'price_details'), style: textTheme.titleMedium),
                    const SizedBox(height: AppDimens.sm),
                    _PriceRow(label: AppStrings.t(isArabic, 'room_price'), value: roomPrice, isArabic: isArabic),
                    _PriceRow(label: AppStrings.t(isArabic, 'taxes_fees'), value: taxes, isArabic: isArabic),
                    const Divider(height: 24),
                    _PriceRow(
                      label: AppStrings.t(isArabic, 'total_price'),
                      value: total,
                      isArabic: isArabic,
                      isTotal: true,
                    ),
                    const SizedBox(height: AppDimens.xl),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.cardShadow),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: AppDimens.buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => BookingSuccessScreen(hotel: hotel)),
                      );
                    },
                    child: Text(AppStrings.t(isArabic, 'confirm_booking')),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _StepperBox extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const _StepperBox({required this.label, required this.value, required this.onMinus, required this.onPlus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.sm, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          IconButton(
            onPressed: onMinus,
            icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Text('$value', style: Theme.of(context).textTheme.titleSmall),
          IconButton(
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink.withOpacity(0.04) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: selected ? AppColors.ink : AppColors.cardBorder, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.ink : AppColors.textMuted),
            const SizedBox(width: AppDimens.sm),
            Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
            Icon(
              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: selected ? AppColors.ink : AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final bool isArabic;
  final bool isTotal;

  const _PriceRow({required this.label, required this.value, required this.isArabic, this.isTotal = false});

  @override
  Widget build(BuildContext context) {
    final style = isTotal
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('${value.toInt()} ${AppStrings.t(isArabic, "sar")}',
              style: isTotal ? style?.copyWith(color: AppColors.goldDark) : style),
        ],
      ),
    );
  }
}
