import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/core/firebase/firestore_utils.dart';
import 'package:yanyana_p/shared/models/volunteer_application.dart';

/// Firestore volunteer applications (client-side SDK only).
class VolunteerService {
  VolunteerService._();

  static final VolunteerService instance = VolunteerService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _apps =>
      _db.collection(FirestoreCollections.volunteerApplications);

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection(FirestoreCollections.users).doc(uid);

  Future<VolunteerApplication> submitVolunteerApplication({
    required String userId,
    required String name,
    required String email,
    required String reason,
  }) async {
    final ref = _apps.doc();
    await ref.set({
      'id': ref.id,
      'userId': userId,
      'name': name,
      'email': email,
      'reason': reason,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _userRef(userId).update({
      'volunteerStatus': VolunteerStatus.pending,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return VolunteerApplication(
      id: ref.id,
      userId: userId,
      name: name,
      email: email,
      reason: reason,
      status: 'pending',
    );
  }

  Stream<List<VolunteerApplication>> streamApplicationsForAdmin() {
    return _apps.snapshots().map((snap) {
      final list = snap.docs.map(_fromDoc).toList();
      list.sort((a, b) {
        final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta);
      });
      return list;
    });
  }

  Future<List<VolunteerApplication>> getApplicationsForAdmin() async {
    final snap = await _apps.get();
    final list = snap.docs.map(_fromDoc).toList();
    list.sort((a, b) {
      final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return tb.compareTo(ta);
    });
    return list;
  }

  Future<VolunteerApplication?> getApplicationForUser(String userId) async {
    final snap = await _apps.where('userId', isEqualTo: userId).get();
    if (snap.docs.isEmpty) return null;
    final list = snap.docs.map(_fromDoc).toList();
    list.sort((a, b) {
      final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return tb.compareTo(ta);
    });
    return list.first;
  }

  Future<VolunteerApplication> approveApplication(
    String applicationId, {
    required String reviewedBy,
  }) async {
    final doc = await _apps.doc(applicationId).get();
    final userId = doc.data()?['userId'] as String?;

    await _apps.doc(applicationId).update({
      'status': 'approved',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': reviewedBy,
    });

    if (userId != null && userId.isNotEmpty) {
      await _userRef(userId).update({
        'volunteerStatus': VolunteerStatus.approved,
        'userType': AppUserType.volunteer,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    final snap = await _apps.doc(applicationId).get();
    return _fromDoc(snap);
  }

  Future<VolunteerApplication> rejectApplication(
    String applicationId, {
    required String reviewedBy,
  }) async {
    final doc = await _apps.doc(applicationId).get();
    final userId = doc.data()?['userId'] as String?;

    await _apps.doc(applicationId).update({
      'status': 'rejected',
      'reviewedAt': FieldValue.serverTimestamp(),
      'reviewedBy': reviewedBy,
    });

    if (userId != null && userId.isNotEmpty) {
      await _userRef(userId).update({
        'volunteerStatus': VolunteerStatus.rejected,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    final snap = await _apps.doc(applicationId).get();
    return _fromDoc(snap);
  }

  VolunteerApplication _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return VolunteerApplication(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      reason: data['reason'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: parseFirestoreDate(data['createdAt']),
    );
  }
}
