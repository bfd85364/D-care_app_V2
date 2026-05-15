// lib/features/chatbot/presentation/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/chat_provider.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/glucose_drawer.dart';
import 'widgets/typing_indicator.dart';
import 'widgets/risk_badge.dart';
import 'widgets/quick_question_chip.dart';
import '../../../core/constants/app_colors.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage([String? text]) {
    final msg = (text ?? _inputController.text).trim();
    if (msg.isEmpty) return;
    _inputController.clear();
    ref.read(chatProvider.notifier).sendMessage(msg);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    ref.listen(chatProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.bgPrimary,

      // 혈당 기록 드로어
      drawer: const GlucoseDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 22),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          tooltip: '혈당 기록',
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('D-Care 챗봇'),
            Row(
              children: [
                Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.riskLow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'OpenRouter 연결됨',
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
                ),
              ],
            ),
          ],
        ),
        actions: const [
          RiskBadge(),
          SizedBox(width: 12),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),

      // 바디 그룹
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12,
              ),
              itemCount: chatState.messages.length +
                  (chatState.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length) {
                  return const TypingIndicator();
                }
                return ChatBubble(
                  message: chatState.messages[index],
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  //빈 화면
  Widget _buildEmptyState() {
    final quickQuestions = [
      '오늘 혈당 분석해줘',
      '공복혈당 105면?',
      '아침 식단 추천',
      'HbA1c 관리법',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Colors.white, size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '혈당 수치, 증상, 식단을\n자유롭게 물어보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8, runSpacing: 8,
              alignment: WrapAlignment.center,
              children: quickQuestions
                  .map((q) => QuickQuestionChip(
                label: q,
                onTap: () => _sendMessage(q),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
  // 프롬프트
  Widget _buildInputBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: EdgeInsets.fromLTRB(
        14, 10, 14,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.bgTertiary, width: 0.5),
            ),
            padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    maxLines: 4,
                    minLines: 1,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: '혈당 수치, 증상, 식단 등 질문하세요...',
                      hintStyle: TextStyle(
                        color: AppColors.textTertiary, fontSize: 13,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                ValueListenableBuilder(
                  valueListenable: _inputController,
                  builder: (_, value, __) {
                    final hasText = value.text.trim().isNotEmpty;
                    return GestureDetector(
                      onTap: hasText ? _sendMessage : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: hasText ? AppColors.accentGradient : null,
                          color: hasText ? null : AppColors.bgTertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white, size: 18,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '이 서비스는 의료 진단을 대체하지 않습니다',
            style: TextStyle(fontSize: 10, color: AppColors.bgTertiary),
          ),
        ],
      ),
    );
  }
}