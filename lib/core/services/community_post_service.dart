import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/core/firebase/firestore_utils.dart';
import 'package:yanyana_p/shared/models/community_post.dart';

class CommunityPostService {
  CommunityPostService._();

  static final CommunityPostService instance = CommunityPostService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection(FirestoreCollections.communityPosts);

  List<CommunityPost> _mapAndSort(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final list = docs.map(_fromDoc).toList();
    sortByNewest(list, (p) => p.createdAt);
    return list;
  }

  Stream<List<CommunityPost>> streamPosts() {
    return _posts.snapshots().map((snap) => _mapAndSort(snap.docs));
  }

  Future<List<CommunityPost>> getPosts() async {
    try {
      final snap = await _posts.get();
      return _mapAndSort(snap.docs);
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> addPost({
    required String authorId,
    required String authorName,
    required String title,
    required String body,
  }) async {
    final ref = _posts.doc();
    try {
      await ref.set({
        'id': ref.id,
        'authorId': authorId,
        'authorName': authorName.trim(),
        'title': title.trim(),
        'body': body.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  CommunityPost _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final body = data['body'] as String?;
    final content = data['content'] as String?;
    return CommunityPost(
      id: data['id'] as String? ?? doc.id,
      authorId: data['authorId'] as String? ?? data['userId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Kullanıcı',
      title: data['title'] as String? ?? '',
      body: (body != null && body.isNotEmpty) ? body : (content ?? ''),
      createdAt: parseFirestoreDate(data['createdAt']),
    );
  }
}
