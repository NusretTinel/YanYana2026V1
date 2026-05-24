import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/core/firebase/firestore_utils.dart';
import 'package:yanyana_p/shared/models/chat_thread.dart';

class ChatThreadService {
  ChatThreadService._();

  static final ChatThreadService instance = ChatThreadService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _threads =>
      _db.collection(FirestoreCollections.chatThreads);

  Stream<List<ChatThread>> streamForUser(String userId) {
    return _threads
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Future<void> addThread({
    required String userId,
    required String peerName,
    required String contextLabel,
    required String lastMessage,
    String statusLabel = 'İletildi',
  }) async {
    final ref = _threads.doc();
    try {
      await ref.set({
        'id': ref.id,
        'userId': userId,
        'peerName': peerName.trim(),
        'contextLabel': contextLabel.trim(),
        'lastMessage': lastMessage.trim(),
        'statusLabel': statusLabel,
        'isRead': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<List<ChatThread>> getForUser(String userId) async {
    try {
      final snap = await _threads
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();
      return snap.docs.map(_fromDoc).toList();
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  ChatThread _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return ChatThread(
      id: data['id'] as String? ?? doc.id,
      userId: data['userId'] as String? ?? '',
      peerName: data['peerName'] as String? ?? '',
      contextLabel: data['contextLabel'] as String? ?? '',
      lastMessage: data['lastMessage'] as String? ?? '',
      updatedAt: parseFirestoreDate(data['updatedAt']),
      isRead: data['isRead'] as bool? ?? false,
      statusLabel: data['statusLabel'] as String? ?? 'İletildi',
    );
  }
}
