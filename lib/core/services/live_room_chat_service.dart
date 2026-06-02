import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/core/firebase/firestore_utils.dart';
import 'package:yanyana_p/shared/models/live_room_message_model.dart';

/// Firestore chat for live community rooms.
class LiveRoomChatService {
  LiveRoomChatService._();

  static final LiveRoomChatService instance = LiveRoomChatService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _messages(String roomId) =>
      _db
          .collection(FirestoreCollections.communityRooms)
          .doc(roomId)
          .collection(FirestoreCollections.messages);

  List<LiveRoomMessage> _mapDocs(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final list = docs
        .map(
          (d) => LiveRoomMessage.fromFirestore(
            d.id,
            _withParsedDate(d.data()),
          ),
        )
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Map<String, dynamic> _withParsedDate(Map<String, dynamic> data) {
    final copy = Map<String, dynamic>.from(data);
    copy['createdAt'] = parseFirestoreDate(data['createdAt']);
    return copy;
  }

  Stream<List<LiveRoomMessage>> streamMessages(String roomId) {
    return _messages(roomId).snapshots().map((snap) => _mapDocs(snap.docs));
  }

  Future<void> sendMessage({
    required String roomId,
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw Exception('Mesaj boş olamaz.');
    }

    final ref = _messages(roomId).doc();
    try {
      await ref.set({
        'text': trimmed,
        'senderId': senderId,
        'senderName': senderName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }
}
