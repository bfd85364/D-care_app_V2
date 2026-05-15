// lib/features/chatbot/provider/chat_provider.dart
// FastAPI /chat 실제 연동 버전

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/message_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../health_profile/provider/health_profile_provider.dart';

// ── 상태 ──────────────────────────────────────────────────
class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final int? sessionId;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.sessionId,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    int? sessionId,
    String? error,
  }) {
    return ChatState(
      messages:  messages  ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      sessionId: sessionId ?? this.sessionId,
      error:     error,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatNotifier(this._ref) : super(ChatState(messages: [
    Message(
      text:      '안녕하세요! 당뇨 관리 챗봇입니다. 무엇을 도와드릴까요?',
      isUser:    false,
      createdAt: DateTime.now(),
    ),
  ]));

  Future<void> sendMessage(String text) async {
    // 사용자 메시지 추가
    final userMsg = Message(
      text:      text,
      isUser:    true,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      messages:  [...state.messages, userMsg],
      isLoading: true,
      error:     null,
    );

    try {
      // ── 건강정보 로드 ──────────────────────────────
      final profile = _ref.read(healthProfileProvider).value;
      final userId  = await SecureStorage.getUserId();

      // ── 건강정보 → UserHealth 변환 ─────────────────
      Map<String, dynamic>? userHealth;
      if (profile != null) {
        userHealth = {
          'name':              await SecureStorage.getUserName() ?? '사용자',
          'age':               profile.age,
          'gender':            profile.gender == '남' ? 'male' : 'female',
          'height':            profile.heightCm,
          'weight':            profile.weightKg,
          'waist_circumference': profile.waistCm,
          'hypertension':      profile.hypertension,
          'dyslipidemia':      profile.dyslipidemia,
          'smoking':           profile.smoking != 0,
          'fasting_glucose':   profile.fastingGlucose,
          'hba1c':             profile.hba1c,
          'systolic_bp':       profile.systolicBp,
          'diastolic_bp':      profile.diastolicBp,
          'diabetes_father':   profile.familyHistory,
          'diabetes_mother':   profile.familyHistory,
          'diabetes_siblings': profile.familyHistory,
          'drinking_frequencys': profile.drinkFrequency?.toInt(),
          'drinking_amount':   profile.drinkAmount?.toInt(),
        };
      }

      // ── FastAPI /chat 호출 ─────────────────────────
      final res = await DioClient.instance.post('/chat', data: {
        'question':    text,
        'user_helth':  userHealth,
        'user_id':     userId,
        'session_id':  state.sessionId,
      });

      final answer    = res.data['answer'] as String;
      final sessionId = res.data['session_id'] as int?;

      // 봇 메시지 추가
      final botMsg = Message(
        text:      answer,
        isUser:    false,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages:  [...state.messages, botMsg],
        isLoading: false,
        sessionId: sessionId ?? state.sessionId,
      );

    } catch (e) {
      // 오류 메시지 표시
      final errMsg = Message(
        text:      '죄송합니다. 일시적인 오류가 발생했습니다. 다시 시도해주세요.',
        isUser:    false,
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        messages:  [...state.messages, errMsg],
        isLoading: false,
        error:     e.toString(),
      );
    }
  }

  // ── 대화 초기화 ───────────────────────────────────────
  void clearChat() {
    state = ChatState(messages: [
      Message(
        text:      '안녕하세요! 당뇨 관리 챗봇입니다. 무엇을 도와드릴까요?',
        isUser:    false,
        createdAt: DateTime.now(),
      ),
    ]);
  }
}

// ── Provider ──────────────────────────────────────────────
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});