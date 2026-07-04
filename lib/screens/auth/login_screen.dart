import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../utils/user_role_provider.dart';
import '../../providers/auth_provider.dart';
import '../../main.dart';
import '../../models/profile_model.dart';
import '../home/main_navigation_screen.dart';
import '../owner/owner_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'fill_all_fields'));
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      // نجيب الدور مباشرة من قاعدة البيانات بالـ id الطازج، بدون الاعتماد
      // على تدفق الحالة (authStateProvider) اللي ممكن يتأخر شوي بالتحديث
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('تعذر تسجيل الدخول');
      final profileData =
          await supabase.from('profiles').select().eq('id', userId).maybeSingle();
      final role = userRoleFromString(profileData?['role'] as String?);

      ref.read(userRoleProvider.notifier).setRole(role);
      ref.invalidate(currentProfileProvider);

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => role == UserRole.owner ? const OwnerNavigationScreen() : const MainNavigationScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'login_failed'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _continueAsGuest() {
    ref.read(userRoleProvider.notifier).setRole(UserRole.guest);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimens.xl),
              Center(child: Image.asset('assets/images/logo.png', width: 110)),
              const SizedBox(height: AppDimens.xl),
              Text(
                AppStrings.t(isArabic, 'welcome_back'),
                textAlign: TextAlign.center,
                style: textTheme.headlineLarge,
              ),
              const SizedBox(height: AppDimens.sm),
              Text(
                AppStrings.t(isArabic, 'login_subtitle'),
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimens.xl),

              Text(AppStrings.t(isArabic, 'email'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppDimens.md),

              Text(AppStrings.t(isArabic, 'password'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
              Align(
                alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.t(isArabic, 'enter_email_first'))),
                      );
                      return;
                    }
                    try {
                      await ref.read(authRepositoryProvider).resetPassword(email: email);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.t(isArabic, 'reset_email_sent'))),
                      );
                    } catch (_) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.t(isArabic, 'something_went_wrong'))),
                      );
                    }
                  },
                  child: Text(AppStrings.t(isArabic, 'forgot_password')),
                ),
              ),
              const SizedBox(height: AppDimens.md),

              SizedBox(
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(AppStrings.t(isArabic, 'login')),
                ),
              ),
              const SizedBox(height: AppDimens.md),

              SizedBox(
                height: AppDimens.buttonHeight,
                child: OutlinedButton(
                  onPressed: _continueAsGuest,
                  child: Text(AppStrings.t(isArabic, 'continue_as_guest')),
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.t(isArabic, 'no_account'),
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    },
                    child: Text(AppStrings.t(isArabic, 'create_account')),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.goldDark : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: isSelected ? AppColors.goldDark : AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.goldDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
