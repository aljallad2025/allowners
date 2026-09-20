import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/hotel_staff_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/locale_provider.dart';
import '../../utils/session_provider.dart';
import '../../utils/tr.dart';
import '../owner/owner_notifications_screen.dart';
import 'hotel_requests_screen.dart';

/// الرئيسية لحساب إدارة الفندق: ملخص الطلبات الجديدة + وصول اليوم + المقيمون
class HotelHomeScreen extends ConsumerStatefulWidget {
  final VoidCallback? onOpenBookings;
  const HotelHomeScreen({super.key, this.onOpenBookings});

  @override
  ConsumerState<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends ConsumerState<HotelHomeScreen> {
  final _service = HotelStaffService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getDashboard();
  }

  void _reload() => setState(() => _future = _service.getDashboard());

  void _openRequests(String type) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => HotelRequestsScreen(initialType: type)))
        .then((_) => _reload());
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;
    final user = ref.watch(sessionProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppDimens.pagePadding),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(isArabic, 'مرحبًا', 'Hello'), style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                        Text(user?.fullName ?? '', style: textTheme.headlineMedium),
                        Text(tr(isArabic, 'إدارة الفندق', 'Hotel management'), style: textTheme.bodySmall?.copyWith(color: AppColors.goldDark)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OwnerNotificationsScreen())),
                    icon: const Icon(Icons.notifications_outlined),
                    style: IconButton.styleFrom(backgroundColor: AppColors.surfaceMuted, shape: const CircleBorder()),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.lg),
              FutureBuilder<Map<String, dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppDimens.xl),
                      child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                    );
                  }
                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        Text(snapshot.error.toString(), textAlign: TextAlign.center),
                        TextButton(onPressed: _reload, child: Text(tr(isArabic, 'إعادة المحاولة', 'Retry'))),
                      ],
                    );
                  }
                  final d = snapshot.data ?? {};
                  final pending = (d['pending'] as Map?)?.cast<String, dynamic>() ?? {};
                  int n(dynamic v) => (v is num) ? v.toInt() : 0;

                  Widget metric(IconData icon, String label, int value, VoidCallback onTap, {bool highlight = false}) {
                    return Expanded(
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                        child: Container(
                          padding: const EdgeInsets.all(AppDimens.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                            border: Border.all(color: highlight && value > 0 ? AppColors.gold : AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(icon, color: AppColors.goldDark),
                              const SizedBox(height: AppDimens.sm),
                              Text('$value', style: textTheme.headlineSmall),
                              Text(label, style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final hotels = ((d['hotels'] as List?) ?? const []).cast<Map<String, dynamic>>();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hotels.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppDimens.md),
                          child: Text(hotels.map((h) => '${h['name']}').join('  •  '), style: textTheme.titleSmall),
                        ),
                      Text(tr(isArabic, 'طلبات جديدة', 'New requests'), style: textTheme.titleMedium),
                      const SizedBox(height: AppDimens.sm),
                      Row(
                        children: [
                          metric(Icons.cleaning_services_outlined, tr(isArabic, 'النظافة', 'Cleaning'), n(pending['cleaning']), () => _openRequests('cleaning'), highlight: true),
                          const SizedBox(width: AppDimens.md),
                          metric(Icons.build_outlined, tr(isArabic, 'الصيانة', 'Maintenance'), n(pending['maintenance']), () => _openRequests('maintenance'), highlight: true),
                        ],
                      ),
                      const SizedBox(height: AppDimens.md),
                      Row(
                        children: [
                          metric(Icons.restaurant_outlined, tr(isArabic, 'الوجبات', 'Meals'), n(pending['meal']), () => _openRequests('meal'), highlight: true),
                          const SizedBox(width: AppDimens.md),
                          metric(Icons.bed_outlined, tr(isArabic, 'السرير الإضافي', 'Extra bed'), n(pending['extra_bed']), () => _openRequests('extra_bed'), highlight: true),
                        ],
                      ),
                      const SizedBox(height: AppDimens.xl),
                      Text(tr(isArabic, 'الحجوزات', 'Bookings'), style: textTheme.titleMedium),
                      const SizedBox(height: AppDimens.sm),
                      Row(
                        children: [
                          metric(Icons.login_rounded, tr(isArabic, 'وصول اليوم', 'Arrivals today'), n(d['arrivals_today']), () => widget.onOpenBookings?.call()),
                          const SizedBox(width: AppDimens.md),
                          metric(Icons.hotel_rounded, tr(isArabic, 'مقيمون', 'In house'), n(d['in_house']), () => widget.onOpenBookings?.call()),
                          const SizedBox(width: AppDimens.md),
                          metric(Icons.logout_rounded, tr(isArabic, 'مغادرة', 'Departures'), n(d['departures_today']), () => widget.onOpenBookings?.call()),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
