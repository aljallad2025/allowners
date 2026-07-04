import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/reviews_provider.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  final String hotelId;
  final String bookingId;
  const WriteReviewScreen({super.key, required this.hotelId, required this.bookingId});

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await ref.read(reviewsRepositoryProvider).submitReview(
            hotelId: widget.hotelId,
            bookingId: widget.bookingId,
            rating: _rating,
            comment: _commentController.text.trim().isEmpty ? null : _commentController.text.trim(),
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
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(AppStrings.t(isArabic, 'write_review'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.t(isArabic, 'your_rating'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starValue = i + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = starValue),
                    icon: Icon(
                      starValue <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                      color: AppColors.goldDark,
                      size: 34,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppDimens.lg),
              Text(AppStrings.t(isArabic, 'your_comment'), style: textTheme.titleSmall),
              const SizedBox(height: AppDimens.sm),
              TextField(
                controller: _commentController,
                maxLines: 4,
                decoration: InputDecoration(hintText: AppStrings.t(isArabic, 'review_comment_hint')),
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
                      : Text(AppStrings.t(isArabic, 'submit_review')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
