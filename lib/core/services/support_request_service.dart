import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/shared/models/support_request.dart';

class SupportRequestService {
  SupportRequestService._();

  static final SupportRequestService instance = SupportRequestService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _db.collection(FirestoreCollections.supportRequests);

  Future<SupportRequest> create({
    required String userId,
    required String requesterName,
    required String requestType,
    required String description,
    required String status,
  }) async {
    final ref = _requests.doc();
    try {
      await ref.set({
        'id': ref.id,
        'userId': userId,
        'requesterName': requesterName.trim(),
        'requestType': requestType.trim(),
        'description': description.trim(),
        'status': status,
        'assignedVolunteerName': null,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return SupportRequest(
        id: ref.id,
        requesterName: requesterName,
        requestType: requestType,
        description: description,
        status: status,
      );
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<SupportRequest> updateMatch({
    required String requestId,
    required String status,
    required String assignedVolunteerName,
  }) async {
    try {
      await _requests.doc(requestId).update({
        'status': status,
        'assignedVolunteerName': assignedVolunteerName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final snap = await _requests.doc(requestId).get();
      return _fromSnap(snap);
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<List<SupportRequest>> getForUser(String userId) async {
    try {
      final snap = await _requests
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => _fromSnap(d)).toList();
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  SupportRequest _fromSnap(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return SupportRequest(
      id: data['id'] as String? ?? doc.id,
      requesterName: data['requesterName'] as String? ?? '',
      requestType: data['requestType'] as String? ?? '',
      description: data['description'] as String? ?? '',
      status: data['status'] as String? ?? '',
      assignedVolunteerName: data['assignedVolunteerName'] as String?,
    );
  }
}
