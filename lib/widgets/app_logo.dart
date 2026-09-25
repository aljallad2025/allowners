import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_settings_provider.dart';

/// شعار التطبيق — يُعرض من إعدادات لوحة تحكم السي بانل (قابل للتغيير من الإدارة
/// بدون إعادة نشر التطبيق)، ويرجع تلقائيًا للشعار المحلي وقت التحميل أو لو تعذّر الاتصال.
class AppLogo extends ConsumerWidget {
  final double width;

  const AppLogo({super.key, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final localFallback = Image.asset('assets/images/logo.png', width: width);

    return settings.when(
      data: (data) {
        final url = data['logo_url']?.toString();
        if (url == null || url.isEmpty) return localFallback;
        return CachedNetworkImage(
          imageUrl: url,
          width: width,
          fit: BoxFit.contain,
          placeholder: (context, _) => localFallback,
          errorWidget: (context, _, __) => localFallback,
        );
      },
      loading: () => localFallback,
      error: (_, __) => localFallback,
    );
  }
}
