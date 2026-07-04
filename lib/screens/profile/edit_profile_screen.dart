import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../models/profile_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_mutations_provider.dart';
import '../../main.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final ProfileModel? profile;
  const EditProfileScreen({super.key, this.profile});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  File? _newAvatar;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.fullName ?? '');
    _phoneController = TextEditingController(text: widget.profile?.phone ?? '');
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _newAvatar = File(picked.path));
  }

  Future<void> _submit() async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    if (_nameController.text.trim().isEmpty) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'fill_all_fields'));
      return;
    }
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      final repo = ref.read(profileMutationsProvider);
      String? avatarUrl;
      final userId = supabase.auth.currentUser?.id;
      if (_newAvatar != null && userId != null) {
        avatarUrl = await repo.uploadAvatar(_newAvatar!, userId);
      }
      await repo.updateProfile(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarUrl: avatarUrl,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _errorMessage = AppStrings.t(isArabic, 'something_went_wrong'));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    ImageProvider<Object>? avatarImage;
    if (_newAvatar != null) {
      avatarImage = FileImage(_newAvatar!);
    } else if (widget.profile?.avatarUrl != null) {
      avatarImage = CachedNetworkImageProvider(widget.profile!.avatarUrl!);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'edit_profile'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: InkWell(
                  onTap: _pickImage,
                  customBorder: const CircleBorder(),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surfaceMuted,
                        backgroundImage: avatarImage,
                        child: _newAvatar == null && widget.profile?.avatarUrl == null
                            ? const Icon(Icons.person_rounded, color: AppColors.textMuted, size: 46)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimens.xl),

              Text(AppStrings.t(isArabic, 'full_name'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(controller: _nameController),
              const SizedBox(height: AppDimens.md),

              Text(AppStrings.t(isArabic, 'phone_number'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 13)),
              ],
              const SizedBox(height: AppDimens.xl),

              SizedBox(
                height: AppDimens.buttonHeight,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(AppStrings.t(isArabic, 'save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
