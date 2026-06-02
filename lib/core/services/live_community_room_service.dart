import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/core/firebase/firestore_utils.dart';
import 'package:yanyana_p/shared/models/live_community_room_model.dart';

/// Live community rooms in Firestore `community_rooms`.
class LiveCommunityRoomService {
  LiveCommunityRoomService._();

  static final LiveCommunityRoomService instance = LiveCommunityRoomService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection(FirestoreCollections.communityRooms);

  List<LiveCommunityRoom> _mapAndSort(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final list = docs
        .map((d) => LiveCommunityRoom.fromFirestore(
              d.id,
              _withParsedDate(d.data(), d),
            ))
        .toList();
    sortByNewest(list, (r) => r.createdAt);
    return list;
  }

  Map<String, dynamic> _withParsedDate(
    Map<String, dynamic> data,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final copy = Map<String, dynamic>.from(data);
    copy['createdAt'] = parseFirestoreDate(data['createdAt']);
    return copy;
  }

  Stream<List<LiveCommunityRoom>> streamRooms() {
    return _rooms.snapshots().map((snap) => _mapAndSort(snap.docs));
  }

  Future<List<LiveCommunityRoom>> getRooms() async {
    try {
      final snap = await _rooms.get();
      return _mapAndSort(snap.docs);
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<LiveCommunityRoom> createRoom({
    required String name,
    required String description,
    required String category,
    required List<String> accessibilityTags,
    required String createdByUserId,
  }) async {
    final ref = _rooms.doc();
    final payload = {
      'id': ref.id,
      'name': name.trim(),
      'description': description.trim(),
      'category': category,
      'memberCount': 1,
      'accessibilityTags': accessibilityTags,
      'createdBy': createdByUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'joinedUserIds': [createdByUserId],
    };

    try {
      await ref.set(payload);
      final snap = await ref.get();
      return LiveCommunityRoom.fromFirestore(
        snap.id,
        _withParsedDate(snap.data()!, snap),
      );
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> joinRoom({
    required String roomId,
    required String userId,
  }) async {
    final ref = _rooms.doc(roomId);
    try {
      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists) {
          throw Exception('Oda bulunamadı.');
        }
        final data = snap.data()!;
        final joined = List<String>.from(
          (data['joinedUserIds'] as List<dynamic>? ?? []).map((e) => e.toString()),
        );
        if (joined.contains(userId)) return;

        tx.update(ref, {
          'joinedUserIds': FieldValue.arrayUnion([userId]),
          'memberCount': FieldValue.increment(1),
        });
      });
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<bool> isUserJoined(String roomId, String userId) async {
    final snap = await _rooms.doc(roomId).get();
    if (!snap.exists) return false;
    final joined = snap.data()?['joinedUserIds'];
    if (joined is! List) return false;
    return joined.map((e) => e.toString()).contains(userId);
  }

  Future<void> updateRoom({
    required String roomId,
    required String userId,
    required String name,
    required String description,
    required String category,
    required List<String> accessibilityTags,
  }) async {
    final ref = _rooms.doc(roomId);
    try {
      final snap = await ref.get();
      if (!snap.exists) {
        throw Exception('Oda bulunamadı.');
      }
      final createdBy = snap.data()?['createdBy'] as String? ??
          snap.data()?['createdByUid'] as String? ??
          '';
      if (createdBy != userId) {
        throw Exception('Bu odayı düzenleme yetkiniz yok.');
      }

      await ref.update({
        'name': name.trim(),
        'description': description.trim(),
        'category': category,
        'accessibilityTags': accessibilityTags,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> _deleteMessages(String roomId) async {
    final messagesRef =
        _rooms.doc(roomId).collection(FirestoreCollections.messages);
    while (true) {
      final snap = await messagesRef.limit(200).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < 200) break;
    }
  }

  Future<void> deleteRoom({
    required String roomId,
    required String userId,
  }) async {
    final ref = _rooms.doc(roomId);
    try {
      final snap = await ref.get();
      if (!snap.exists) {
        throw Exception('Oda bulunamadı.');
      }
      final createdBy = snap.data()?['createdBy'] as String? ??
          snap.data()?['createdByUid'] as String? ??
          '';
      if (createdBy != userId) {
        throw Exception('Bu odayı silme yetkiniz yok.');
      }

      await _deleteMessages(roomId);
      await ref.delete();
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }
}
