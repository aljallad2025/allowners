import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../utils/locale_provider.dart';
import '../utils/session_provider.dart';
import '../utils/tr.dart';

/// الصورة الشخصية القابلة للتغيير — تعمل لكل الحسابات (ضيف / مالك / وكيل حجوزات / إدارة فندق)
class AvatarPicker extends ConsumerStatefulWidget {
  final double radius;
  const AvatarPicker({super.key, this.radius = 48});

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker> {
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (picked == null) return;
      setState(() => _busy = true);
      await ref.read(sessionProvider.notifier).uploadAvatar(picked.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().isEmpty ? tr(isArabic, 'تعذّر تغيير الصورة', 'Could not change the photo') : e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove() async {
    setState(() => _busy = true);
    try {
      await ref.read(sessionProvider.notifier).removeAvatar();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showOptions(bool hasPhoto) {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(tr(isArabic, 'اختيار من المعرض', 'Choose from gallery')),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(tr(isArabic, 'التقاط صورة', 'Take a photo')),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
            if (hasPhoto)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                title: Text(tr(isArabic, 'حذف الصورة', 'Remove photo'), style: const TextStyle(color: AppColors.danger)),
                onTap: () {
                  Navigator.pop(ctx);
                  _remove();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = ref.watch(sessionProvider).user?.avatarUrl;
    final hasPhoto = url != null && url.isNotEmpty && url != 'null';

    return GestureDetector(
      onTap: _busy ? null : () => _showOptions(hasPhoto),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: AppColors.surfaceMuted,
            backgroundImage: hasPhoto ? CachedNetworkImageProvider(url!) : null,
            child: hasPhoto ? null : Icon(Icons.person_rounded, size: widget.radius, color: AppColors.textMuted),
          ),
          if (_busy)
            Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle),
              child: const Center(
                child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)),
              ),
            ),
          PositionedDirectional(
            bottom: 0,
            end: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.photo_camera_rounded, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
