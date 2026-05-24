class ChatThread {
  final String id;
  final String userId;
  final String peerName;
  final String contextLabel;
  final String lastMessage;
  final DateTime updatedAt;
  final bool isRead;
  final String statusLabel;

  const ChatThread({
    required this.id,
    required this.userId,
    required this.peerName,
    required this.contextLabel,
    required this.lastMessage,
    required this.updatedAt,
    this.isRead = false,
    this.statusLabel = 'İletildi',
  });
}
