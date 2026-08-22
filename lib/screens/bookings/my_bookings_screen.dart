import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/session_provider.dart';
import '../../services/hotel_service.dart';
import '../auth/login_screen.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HotelService _hotelService = HotelService();

  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!ref.read(sessionProvider).isLoggedIn) {
      setState(() {
        _isLoading = false;
        _bookings = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final bookings = await _hotelService.myBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _upcoming => _bookings
      .where((b) => ['pending', 'confirmed', 'checked_in'].contains(b['status']))
      .toList();
  List<Map<String, dynamic>> get _past =>
      _bookings.where((b) => b['status'] == 'completed').toList();
  List<Map<String, dynamic>> get _cancelled =>
      _bookings.where((b) => b['status'] == 'cancelled').toList();

  String _statusLabel(String status, bool isArabic) {
    const labels = {
      'pending': {'ar': 'قيد الانتظار', 'en': 'Pending'},
      'confirmed': {'ar': 'مؤكد', 'en': 'Confirmed'},
      'checked_in': {'ar': 'تسجيل وصول', 'en': 'Checked-in'},
      'completed': {'ar': 'مكتمل', 'en': 'Completed'},
      'cancelled': {'ar': 'ملغي', 'en': 'Cancelled'},
    };
    return labels[status]?[isArabic ? 'ar' : 'en'] ?? status;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.goldDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final isLoggedIn = ref.watch(sessionProvider).isLoggedIn;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.t(isArabic, 'my_bookings')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppStrings.t(isArabic, 'upcoming')),
            Tab(text: AppStrings.t(isArabic, 'past')),
            Tab(text: AppStrings.t(isArabic, 'cancelled')),
          ],
        ),
      ),
      body: SafeArea(
        child: !isLoggedIn
            ? _EmptyState(
                icon: Icons.lock_outline_rounded,
                message: isArabic ? 'سجّل الدخول لعرض حجوزاتك' : 'Log in to view your bookings',
                actionLabel: AppStrings.t(isArabic, 'login'),
                onAction: () => Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const LoginScreen()))
                    .then((_) => _loadBookings()),
              )
            : _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.gold))
                : _error != null
                    ? _EmptyState(
                        icon: Icons.error_outline_rounded,
                        message: _error!,
                        actionLabel: isArabic ? 'إعادة المحاولة' : 'Retry',
                        onAction: _loadBookings,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildList(_upcoming, isArabic),
                            _buildList(_past, isArabic),
                            _buildList(_cancelled, isArabic),
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, bool isArabic) {
    if (items.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: AppDimens.md),
                  Text(AppStrings.t(isArabic, 'no_bookings_yet'), style: const TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final b = items[index];
        final status = b['status']?.toString() ?? 'pending';
        return Padding(
          padding: const EdgeInsets.only(bottom: AppDimens.md),
          child: Container(
            padding: const EdgeInsets.all(AppDimens.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimens.radiusLg),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: b['cover_image']?.toString() ?? '',
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
                      Text(b['hotel_name']?.toString() ?? '', style: Theme.of(context).textTheme.titleSmall),
                      Text(isArabic ? (b['city_ar']?.toString() ?? '') : (b['city_en']?.toString() ?? ''),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted)),
                      Text('${b['check_in']} → ${b['check_out']}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusFull),
                  ),
                  child: Text(_statusLabel(status, isArabic),
                      style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({required this.icon, required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted),
          const SizedBox(height: AppDimens.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textMuted)),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppDimens.md),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
