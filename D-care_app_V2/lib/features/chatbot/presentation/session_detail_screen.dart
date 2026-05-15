// lib/features/chatbot/presentation/session_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../provider/chat_history_provider.dart';

class SessionDetailScreen extends ConsumerWidget {
  final int sessionId;
  final String title;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(sessionMessagesProvider(sessionId));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: messagesAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => const Center(
          child: Text('메시지를 불러올 수 없습니다',
              style: TextStyle(color: AppColors.textTertiary)),
        ),
        data: (messages) {
          if (messages.isEmpty) {
            return const Center(
              child: Text('메시지가 없습니다',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 14)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isUser = msg.role == 'user';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: isUser
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    // 봇 아이콘
                    if (!isUser) ...[
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.smart_toy_outlined,
                            size: 15, color: AppColors.accent),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // 말풍선
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser
                              ? AppColors.accent.withOpacity(0.2)
                              : AppColors.bgSecondary,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isUser ? 16 : 4),
                            bottomRight: Radius.circular(isUser ? 4 : 16),
                          ),
                          border: Border.all(
                              color: AppColors.bgTertiary, width: 0.5),
                        ),
                        child: Text(
                          msg.content,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                    // 사용자 아이콘
                    if (isUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            size: 15, color: AppColors.accent),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}