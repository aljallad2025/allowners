import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../home/main_navigation_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
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
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'create_account'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimens.md),
              Text(AppStrings.t(isArabic, 'full_name'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              const SizedBox(height: AppDimens.md),

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

              Text(AppStrings.t(isArabic, 'email'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: AppDimens.md),

              Text(AppStrings.t(isArabic, 'password'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.lock_outline_rounded)),
              ),
              const SizedBox(height: AppDimens.xl),

              SizedBox(
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: _register,
                  child: Text(AppStrings.t(isArabic, 'create_account')),
                ),
              ),
              const SizedBox(height: AppDimens.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppStrings.t(isArabic, 'have_account'),
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppStrings.t(isArabic, 'login')),
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
