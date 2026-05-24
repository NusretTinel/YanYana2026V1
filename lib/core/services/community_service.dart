import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/shared/models/community_room.dart';

/// Firestore community rooms (client-side SDK only).
class CommunityService {
  CommunityService._();

  static final CommunityService instance = CommunityService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _rooms =>
      _db.collection(FirestoreCollections.communityRooms);

  Stream<List<CommunityRoom>> streamRooms() {
    return _rooms.orderBy('createdAt', descending: true).snapshots().map(
          (snap) => snap.docs.map(_fromDoc).toList(),
        );
  }

  Future<List<CommunityRoom>> getRooms() async {
    final snap = await _rooms.orderBy('createdAt', descending: true).get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<CommunityRoom> createRoom({
    required String title,
    required String category,
    required String description,
    required String createdByUid,
  }) async {
    final ref = _rooms.doc();
    await ref.set({
      'id': ref.id,
      'name': title.trim(),
      'category': category,
      'description': description.trim(),
      'createdByUid': createdByUid,
      'memberCount': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await joinRoom(roomId: ref.id, uid: createdByUid, role: 'owner');
    final snap = await ref.get();
    return _fromDoc(snap);
  }

  Future<void> joinRoom({
    required String roomId,
    required String uid,
    String role = 'member',
  }) async {
    final memberRef = _rooms
        .doc(roomId)
        .collection(FirestoreCollections.members)
        .doc(uid);
    final existing = await memberRef.get();
    if (existing.exists) return;

    await memberRef.set({
      'uid': uid,
      'joinedAt': FieldValue.serverTimestamp(),
      'role': role,
    });
    await _rooms.doc(roomId).update({
      'memberCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> leaveRoom({required String roomId, required String uid}) async {
    final memberRef = _rooms
        .doc(roomId)
        .collection(FirestoreCollections.members)
        .doc(uid);
    final existing = await memberRef.get();
    if (!existing.exists) return;
    await memberRef.delete();
    await _rooms.doc(roomId).update({
      'memberCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isMember(String roomId, String uid) async {
    final snap = await _rooms
        .doc(roomId)
        .collection(FirestoreCollections.members)
        .doc(uid)
        .get();
    return snap.exists;
  }

  Future<List<String>> getJoinedRoomIds(String uid) async {
    final rooms = await getRooms();
    final ids = <String>[];
    for (final room in rooms) {
      if (await isMember(room.id, uid)) ids.add(room.id);
    }
    return ids;
  }

  CommunityRoom _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CommunityRoom(
      id: doc.id,
      title: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      description: data['description'] as String? ?? '',
      memberCount: (data['memberCount'] as num?)?.toInt() ?? 0,
      createdByUserId: data['createdByUid'] as String? ?? '',
    );
  }
}
