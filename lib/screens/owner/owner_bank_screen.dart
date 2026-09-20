import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/api_client.dart';
import '../../services/owner_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/locale_provider.dart';
import '../../utils/tr.dart';

/// بيانات حساب المالك البنكي — تُعرض للضيف عند اختيار «تحويل مباشر لحساب المالك» في وحداته
class OwnerBankScreen extends ConsumerStatefulWidget {
  const OwnerBankScreen({super.key});

  @override
  ConsumerState<OwnerBankScreen> createState() => _OwnerBankScreenState();
}

class _OwnerBankScreenState extends ConsumerState<OwnerBankScreen> {
  final _service = OwnerService();
  final _bankCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _bankCtrl.dispose();
    _nameCtrl.dispose();
    _ibanCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final bank = await _service.getBank();
      if (!mounted) return;
      _bankCtrl.text = bank['bank_name']?.toString() ?? '';
      _nameCtrl.text = bank['bank_account_name']?.toString() ?? '';
      _ibanCtrl.text = bank['bank_iban']?.toString() ?? '';
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save(bool isArabic) async {
    setState(() => _saving = true);
    try {
      await _service.saveBank(
        bankName: _bankCtrl.text.trim(),
        accountName: _nameCtrl.text.trim(),
        iban: _ibanCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(isArabic, 'تم حفظ بيانات الحساب', 'Account details saved'))));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
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
        title: Text(tr(isArabic, 'حساب التحويل المباشر', 'Direct transfer account')),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : ListView(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                children: [
                  Text(
                    tr(isArabic,
                        'هذه البيانات تظهر للضيف تلقائياً في صفحة الحجز عند اختيار «تحويل مباشر لحساب المالك» على وحداتك. اترك الحقول فارغة لإيقاف هذا الخيار.',
                        'These details are shown automatically to guests on the booking page when they choose "Direct transfer to the owner\'s account" for your units. Leave the fields empty to disable this option.'),
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary, height: 1.6),
                  ),
                  const SizedBox(height: AppDimens.lg),
                  TextField(controller: _bankCtrl, decoration: InputDecoration(labelText: tr(isArabic, 'اسم البنك', 'Bank name'))),
                  const SizedBox(height: AppDimens.md),
                  TextField(
                    controller: _nameCtrl,
                    decoration: InputDecoration(labelText: tr(isArabic, 'اسم صاحب الحساب', 'Account holder name')),
                  ),
                  const SizedBox(height: AppDimens.md),
                  TextField(
                    controller: _ibanCtrl,
                    textDirection: TextDirection.ltr,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(labelText: 'IBAN', hintText: 'SA00 0000 0000 0000 0000 0000'),
                  ),
                  const SizedBox(height: AppDimens.xl),
                  SizedBox(
                    height: AppDimens.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _saving ? null : () => _save(isArabic),
                      child: _saving
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                          : Text(tr(isArabic, 'حفظ', 'Save')),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
