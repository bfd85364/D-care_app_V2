// lib/features/chatbot/data/message_model.dart
class Message {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  Message({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}