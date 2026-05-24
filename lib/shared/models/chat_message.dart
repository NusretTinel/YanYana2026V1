/// Chat message in a thread (mock; future Firestore subcollection `messages`).
class ChatMessage {
  final String id;
  final String threadId;
  final String senderId;
  final String text;
  final DateTime sentAt;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });
}
