// lib/features/chatbot/presentation/session_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../provider/chat_history_provider.dart';
import 'session_detail_screen.dart';

class SessionListScreen extends ConsumerWidget {
  const SessionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(sessionListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('대화 기록'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: sessionsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => const Center(
          child: Text('대화 기록을 불러올 수 없습니다',
              style: TextStyle(color: AppColors.textTertiary)),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Text('대화 기록이 없습니다',
                  style: TextStyle(
                      color: AppColors.textTertiary, fontSize: 14)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              // 날짜 파싱
              final dt = DateTime.tryParse(session.createdAt);
              final dateStr = dt != null
                  ? '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}'
                  : session.createdAt;

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SessionDetailScreen(sessionId: session.id, title: session.title),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.bgTertiary, width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chat_bubble_outline,
                            size: 18, color: AppColors.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(dateStr,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textTertiary)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios,
                          size: 12, color: AppColors.textTertiary),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}