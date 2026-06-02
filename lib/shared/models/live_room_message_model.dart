import 'package:yanyana_p/core/firebase/firestore_utils.dart';

/// Firestore message under `community_rooms/{roomId}/messages/{messageId}`.
class LiveRoomMessage {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime createdAt;

  const LiveRoomMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  factory LiveRoomMessage.fromFirestore(String id, Map<String, dynamic> data) {
    return LiveRoomMessage(
      id: id,
      text: data['text'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'YanYana User',
      createdAt: parseFirestoreDate(data['createdAt']),
    );
  }
}
