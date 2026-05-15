// lib/features/chatbot/provider/chat_history_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

// 세션 모델
class ChatSession {
  final int id;
  final String title;
  final String createdAt;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id:        json['id'] as int,
    title:     json['title'] as String,
    createdAt: json['created_at'] as String,
  );
}

//메시지 모델
class ChatHistoryMessage {
  final int id;
  final String role;
  final String content;
  final String createdAt;

  ChatHistoryMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory ChatHistoryMessage.fromJson(Map<String, dynamic> json) =>
      ChatHistoryMessage(
        id:        json['id'] as int,
        role:      json['role'] as String,
        content:   json['content'] as String,
        createdAt: json['created_at'] as String,
      );
}

//세션 목록 Provider
final sessionListProvider = FutureProvider<List<ChatSession>>((ref) async {
  final userId = await SecureStorage.getUserId();
  if (userId == null) return [];

  final res = await DioClient.instance.get('/api/sessions/$userId');
  final list = res.data as List;
  return list.map((e) => ChatSession.fromJson(e)).toList();
});

//특정 세션 메시지 Provider
final sessionMessagesProvider =
FutureProvider.family<List<ChatHistoryMessage>, int>((ref, sessionId) async {
  final res = await DioClient.instance.get('/api/messages/$sessionId');
  final list = res.data as List;
  return list.map((e) => ChatHistoryMessage.fromJson(e)).toList();
});