import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/ao_resources.dart';
import '../../services/owner_service.dart';
import '../../services/api_client.dart';

class OwnerStaffScreen extends ConsumerStatefulWidget {
  const OwnerStaffScreen({super.key});

  @override
  ConsumerState<OwnerStaffScreen> createState() => _OwnerStaffScreenState();
}

class _OwnerStaffScreenState extends ConsumerState<OwnerStaffScreen> {
  final _service = OwnerService();
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final res = await _service.getStaff();
    return (res['staff'] as List).cast<Map<String, dynamic>>();
  }

  void _reload() => setState(() => _future = _load());

  String _roleLabel(String role, bool isArabic) {
    const labels = {
      'booking_agent': {'ar': 'وكيل حجوزات', 'en': 'Booking Agent'},
      'hotel_manager': {'ar': 'إدارة فندق', 'en': 'Hotel Manager'},
    };
    return labels[role]?[isArabic ? 'ar' : 'en'] ?? role;
  }

  Future<void> _openInviteSheet(bool isArabic) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final commissionCtrl = TextEditingController(text: '0');
    String selectedRole = 'booking_agent';
    final Map<String, Set<String>> selectedPermissions = {};
    bool submitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusLg)),
              ),
              padding: EdgeInsets.only(
                left: AppDimens.pagePadding,
                right: AppDimens.pagePadding,
                top: AppDimens.pagePadding,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + AppDimens.pagePadding,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.t(isArabic, 'invite_staff'), style: Theme.of(ctx).textTheme.titleMedium),
                    const SizedBox(height: AppDimens.md),

                    TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'full_name'))),
                    const SizedBox(height: AppDimens.sm),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'email')),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textDirection: TextDirection.ltr,
                      decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'phone_number')),
                    ),
                    const SizedBox(height: AppDimens.sm),
                    TextField(
                      controller: passwordCtrl,
                      obscureText: true,
                      decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'password')),
                    ),
                    const SizedBox(height: AppDimens.md),

                    Text(AppStrings.t(isArabic, 'role'), style: Theme.of(ctx).textTheme.titleSmall),
                    const SizedBox(height: AppDimens.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Text(_roleLabel('booking_agent', isArabic)),
                            selected: selectedRole == 'booking_agent',
                            onSelected: (_) => setSheetState(() => selectedRole = 'booking_agent'),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sm),
                        Expanded(
                          child: ChoiceChip(
                            label: Text(_roleLabel('hotel_manager', isArabic)),
                            selected: selectedRole == 'hotel_manager',
                            onSelected: (_) => setSheetState(() => selectedRole = 'hotel_manager'),
                          ),
                        ),
                      ],
                    ),

                    if (selectedRole == 'booking_agent') ...[
                      const SizedBox(height: AppDimens.md),
                      TextField(
                        controller: commissionCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: AppStrings.t(isArabic, 'commission_rate_percent')),
                      ),
                    ],

                    const SizedBox(height: AppDimens.md),
                    Text(AppStrings.t(isArabic, 'permissions'), style: Theme.of(ctx).textTheme.titleSmall),
                    const SizedBox(height: AppDimens.sm),

                    ...aoResources.entries.where((e) => e.key != 'users').map((entry) {
                      final resource = entry.key;
                      final actions = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppDimens.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(aoResourceLabel(resource, isArabic),
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            Wrap(
                              spacing: 6,
                              children: actions.map((action) {
                                final selected = selectedPermissions[resource]?.contains(action) ?? false;
                                return FilterChip(
                                  label: Text(aoActionLabel(action, isArabic), style: const TextStyle(fontSize: 11)),
                                  selected: selected,
                                  visualDensity: VisualDensity.compact,
                                  onSelected: (v) {
                                    setSheetState(() {
                                      selectedPermissions.putIfAbsent(resource, () => {});
                                      if (v) {
                                        selectedPermissions[resource]!.add(action);
                                      } else {
                                        selectedPermissions[resource]!.remove(action);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: AppDimens.lg),
                    SizedBox(
                      width: double.infinity,
                      height: AppDimens.buttonHeight,
                      child: ElevatedButton(
                        onPressed: submitting
                            ? null
                            : () async {
                                if (nameCtrl.text.trim().isEmpty ||
                                    emailCtrl.text.trim().isEmpty ||
                                    passwordCtrl.text.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(isArabic ? 'الرجاء تعبئة كل الحقول' : 'Please fill all fields')),
                                  );
                                  return;
                                }
                                setSheetState(() => submitting = true);
                                try {
                                  final permissionsMap = selectedPermissions.map(
                                    (k, v) => MapEntry(k, v.toList()),
                                  );
                                  await _service.inviteStaff(
                                    fullName: nameCtrl.text.trim(),
                                    email: emailCtrl.text.trim(),
                                    phone: phoneCtrl.text.trim(),
                                    password: passwordCtrl.text,
                                    role: selectedRole,
                                    permissions: permissionsMap,
                                    commissionRate: double.tryParse(commissionCtrl.text) ?? 0,
                                  );
                                  if (ctx.mounted) Navigator.of(ctx).pop();
                                  _reload();
                                } on ApiException catch (e) {
                                  setSheetState(() => submitting = false);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                                  }
                                }
                              },
                        child: submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                              )
                            : Text(AppStrings.t(isArabic, 'invite_staff')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
        title: Text(AppStrings.t(isArabic, 'staff_management')),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.gold,
        onPressed: () => _openInviteSheet(isArabic),
        child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.textOnGold),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _reload(),
          child: FutureBuilder<List<Map<String, dynamic>>>(
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

              final staff = snapshot.data ?? [];
              if (staff.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppDimens.xl),
                      child: Center(child: Text(AppStrings.t(isArabic, 'no_staff_yet'))),
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                itemCount: staff.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppDimens.md),
                itemBuilder: (context, index) {
                  final s = staff[index];
                  final active = s['status'] == 'active';
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
                            Expanded(child: Text(s['full_name']?.toString() ?? '', style: textTheme.titleSmall)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (active ? AppColors.success : AppColors.textMuted).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                              ),
                              child: Text(
                                AppStrings.t(isArabic, active ? 'active' : 'suspended'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: active ? AppColors.success : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(_roleLabel(s['role']?.toString() ?? '', isArabic),
                            style: textTheme.bodySmall?.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                        Text(s['email']?.toString() ?? '',
                            style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted), textDirection: TextDirection.ltr),
                        if (s['role'] == 'booking_agent')
                          Text(
                            '${AppStrings.t(isArabic, 'commission_rate_percent')}: ${s['commission_rate']}%',
                            style: textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                          ),
                        const Divider(height: AppDimens.lg),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  try {
                                    await _service.toggleStaffStatus(s['id'] as int);
                                    _reload();
                                  } on ApiException catch (e) {
                                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                                  }
                                },
                                child: Text(AppStrings.t(isArabic, active ? 'suspend' : 'activate')),
                              ),
                            ),
                            const SizedBox(width: AppDimens.sm),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(AppStrings.t(isArabic, 'confirm_delete')),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppStrings.t(isArabic, 'cancel'))),
                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppStrings.t(isArabic, 'delete'))),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    try {
                                      await _service.deleteStaff(s['id'] as int);
                                      _reload();
                                    } on ApiException catch (e) {
                                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                                    }
                                  }
                                },
                                child: Text(AppStrings.t(isArabic, 'delete')),
                              ),
                            ),
                          ],
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
