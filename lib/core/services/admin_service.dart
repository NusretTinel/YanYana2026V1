import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/core/firebase/user_document_mapper.dart';
import 'package:yanyana_p/shared/models/app_user.dart';

class AdminStats {
  const AdminStats({
    required this.totalUsers,
    required this.totalPlaces,
    required this.totalSosRequests,
    required this.pendingVolunteerApplications,
  });

  final int totalUsers;
  final int totalPlaces;
  final int totalSosRequests;
  final int pendingVolunteerApplications;
}

/// Admin-only Firestore operations (client SDK).
class AdminService {
  AdminService._();

  static final AdminService instance = AdminService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AdminStats> fetchStats() async {
    try {
      final usersSnap =
          await _db.collection(FirestoreCollections.users).limit(500).get();
      final placesSnap = await _db
          .collection(FirestoreCollections.accessiblePlaces)
          .limit(500)
          .get();
      final sosSnap =
          await _db.collection(FirestoreCollections.sosRequests).limit(500).get();
      final volunteerSnap = await _db
          .collection(FirestoreCollections.volunteerApplications)
          .where('status', isEqualTo: 'pending')
          .limit(200)
          .get();

      return AdminStats(
        totalUsers: usersSnap.size,
        totalPlaces: placesSnap.size,
        totalSosRequests: sosSnap.size,
        pendingVolunteerApplications: volunteerSnap.size,
      );
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<List<AppUser>> listUsers({int limit = 80}) async {
    try {
      final snap =
          await _db.collection(FirestoreCollections.users).limit(limit).get();
      return snap.docs
          .map((d) => UserDocumentMapper.fromFirestore(d.id, d.data()))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> updateUserAuthRole(String uid, String role) async {
    final normalized = AppAuthRole.normalize(role);
    if (normalized != AppAuthRole.user &&
        normalized != AppAuthRole.moderator &&
        normalized != AppAuthRole.admin) {
      throw Exception('Geçersiz rol.');
    }
    try {
      await _db.collection(FirestoreCollections.users).doc(uid).update({
        'role': normalized,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<void> updateUserVolunteerStatus(String uid, String status) async {
    try {
      await _db.collection(FirestoreCollections.users).doc(uid).update({
        'volunteerStatus': VolunteerStatus.normalize(status),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }
}
