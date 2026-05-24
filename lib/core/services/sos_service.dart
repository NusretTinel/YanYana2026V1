import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_utils.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/shared/models/emergency_request.dart';

/// Firestore SOS requests (no real SMS/calls).
class SOSService {
  SOSService._();

  static final SOSService instance = SOSService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _sos =>
      _db.collection(FirestoreCollections.sosRequests);

  Future<EmergencyRequest> createSOSRequest({
    required String userId,
    required String userName,
    required String emergencyContactName,
    required String emergencyContactPhone,
    required String source,
    double? latitude,
    double? longitude,
    String message = '',
  }) async {
    if (emergencyContactName.trim().isEmpty ||
        emergencyContactPhone.trim().isEmpty) {
      throw StateError(
        'Acil durum kişisi eksik. Profilden acil iletişim bilgisi ekleyin.',
      );
    }

    final ref = _sos.doc();
    final location = latitude != null && longitude != null
        ? '$latitude,$longitude'
        : null;

    final data = {
      'id': ref.id,
      'userId': userId,
      'userName': userName,
      'emergencyContactName': emergencyContactName.trim(),
      'emergencyContactPhone': emergencyContactPhone.trim(),
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'status': 'created',
      'source': source,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await ref.set(data);
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }

    return EmergencyRequest(
      id: ref.id,
      userId: userId,
      userName: userName,
      type: 'sos',
      status: 'created',
      location: location,
      trustedContactName: emergencyContactName,
      createdAt: DateTime.now(),
    );
  }

  Stream<List<EmergencyRequest>> streamUserSOSRequests(String userId) {
    return _sos
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_fromDoc).toList());
  }

  Future<List<EmergencyRequest>> listAllForAdmin() async {
    try {
      final snap = await _sos.limit(200).get();
      final list = snap.docs.map(_fromDoc).toList();
      list.sort((a, b) {
        final ta = a.createdAt.millisecondsSinceEpoch ?? 0;
        final tb = b.createdAt.millisecondsSinceEpoch ?? 0;
        return tb.compareTo(ta);
      });
      return list;
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Future<List<EmergencyRequest>> getUserSOSRequests(String userId) async {
    final snap = await _sos
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map(_fromDoc).toList();
  }

  Future<void> dismissRequest(String requestId) async {
    await _sos.doc(requestId).update({
      'status': 'cancelled',
    });
  }

  List<EmergencyRequest> mapVisibleOnMap(List<EmergencyRequest> requests) {
    return requests.where((r) => r.isVisibleOnMap).toList();
  }

  EmergencyRequest _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final lat = data['latitude'] as num?;
    final lon = data['longitude'] as num?;
    String? location;
    if (lat != null && lon != null) {
      location = '${lat.toDouble()},${lon.toDouble()}';
    }
    final status = data['status'] as String? ?? 'created';
    final createdAt = parseFirestoreDate(data['createdAt']);

    return EmergencyRequest(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      type: 'sos',
      status: status == 'cancelled' ? 'dismissed' : status,
      location: location,
      trustedContactName: data['emergencyContactName'] as String?,
      createdAt: createdAt,
    );
  }
}
