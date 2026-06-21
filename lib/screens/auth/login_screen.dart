import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../home/main_navigation_screen.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  void _login() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
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

              Text(AppStrings.t(isArabic, 'phone_number'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  hintText: '05xxxxxxxx',
                  prefixIcon: Icon(Icons.phone_outlined),
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
              Align(
                alignment: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(AppStrings.t(isArabic, 'forgot_password')),
                ),
              ),
              const SizedBox(height: AppDimens.md),

              SizedBox(
                height: AppDimens.buttonHeight,
                child: ElevatedButton(onPressed: _login, child: Text(AppStrings.t(isArabic, 'login'))),
              ),
              const SizedBox(height: AppDimens.md),

              SizedBox(
                height: AppDimens.buttonHeight,
                child: OutlinedButton(
                  onPressed: _login,
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
