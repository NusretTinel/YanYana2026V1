import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/core/firebase/firestore_utils.dart';
import 'package:yanyana_p/shared/models/notification_model.dart';

/// In-app notifications stored in Firestore.
class FirestoreNotificationService {
  FirestoreNotificationService._();

  static final FirestoreNotificationService instance =
      FirestoreNotificationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notifications =>
      _db.collection(FirestoreCollections.notifications);

  Stream<List<NotificationModel>> streamForUser(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(_fromDoc).toList();
          list.sort((a, b) {
            final ta = a.createdAt.millisecondsSinceEpoch;
            final tb = b.createdAt.millisecondsSinceEpoch;
            return tb.compareTo(ta);
          });
          return list;
        });
  }

  Future<List<NotificationModel>> getForUser(String userId) async {
    try {
      final snap = await _notifications
          .where('userId', isEqualTo: userId)
          .get();
      final list = snap.docs.map(_fromDoc).toList();
      list.sort((a, b) {
        final ta = a.createdAt.millisecondsSinceEpoch;
        final tb = b.createdAt.millisecondsSinceEpoch;
        return tb.compareTo(ta);
      });
      return list;
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> add({
    required String userId,
    required String title,
    required String message,
  }) async {
    final ref = _notifications.doc();
    try {
      await ref.set({
        'id': ref.id,
        'userId': userId,
        'title': title.trim(),
        'message': message.trim(),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> markRead(String notificationId) async {
    try {
      await _notifications.doc(notificationId).update({'isRead': true});
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final snap = await _notifications
          .where('userId', isEqualTo: userId)
          .get();
          
      final unreadDocs = snap.docs.where((d) => d.data()['isRead'] == false).toList();
          
      if (unreadDocs.isEmpty) return;
      
      final batch = _db.batch();
      for (final doc in unreadDocs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  NotificationModel _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return NotificationModel(
      id: data['id'] as String? ?? doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      createdAt: parseFirestoreDate(data['createdAt']),
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
