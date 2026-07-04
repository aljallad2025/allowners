import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import '../../utils/app_strings.dart';
import '../../utils/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/messages_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String peerId;
  final String peerName;
  const ChatScreen({super.key, required this.peerId, required this.peerName});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(messagesRepositoryProvider).sendMessage(widget.peerId, text);
      _controller.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final messagesAsync = ref.watch(conversationMessagesProvider(widget.peerId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(widget.peerName.isEmpty ? AppStrings.t(isArabic, 'role_owner') : widget.peerName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                error: (err, st) => Center(
                  child: Text(AppStrings.t(isArabic, 'something_went_wrong'), style: const TextStyle(color: AppColors.textMuted)),
                ),
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(AppStrings.t(isArabic, 'start_conversation'), style: const TextStyle(color: AppColors.textMuted)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppDimens.pagePadding),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      final isMine = m['sender_id'] == currentUserId;
                      return Align(
                        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: AppDimens.sm),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                          decoration: BoxDecoration(
                            color: isMine ? AppColors.gold.withOpacity(0.16) : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(m['content'] as String),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding, vertical: AppDimens.sm),
              decoration: BoxDecoration(color: AppColors.surface, boxShadow: AppColors.cardShadow),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: AppStrings.t(isArabic, 'type_message')),
                    ),
                  ),
                  const SizedBox(width: AppDimens.sm),
                  IconButton(
                    onPressed: _sending ? null : _send,
                    icon: const Icon(Icons.send_rounded, color: AppColors.goldDark),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
