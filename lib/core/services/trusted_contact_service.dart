import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/shared/models/trusted_contact.dart';

class TrustedContactService {
  TrustedContactService._();

  static final TrustedContactService instance = TrustedContactService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _contactsRef(String uid) =>
      _db
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.trustedContacts);

  Future<List<TrustedContact>> getContacts(String userId) async {
    try {
      final snap = await _contactsRef(userId).orderBy('name').get();
      return snap.docs.map(_fromDoc).toList();
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Stream<List<TrustedContact>> streamContacts(String userId) {
    return _contactsRef(userId).orderBy('name').snapshots().map(
          (snap) => snap.docs.map(_fromDoc).toList(),
        );
  }

  Future<TrustedContact> addContact({
    required String userId,
    required String name,
    required String phoneNumber,
    required String relationship,
  }) async {
    final ref = _contactsRef(userId).doc();
    final contact = TrustedContact(
      id: ref.id,
      userId: userId,
      name: name.trim(),
      phoneNumber: phoneNumber.trim(),
      relationship: relationship.trim().isEmpty
          ? 'Yakın'
          : relationship.trim(),
    );
    try {
      await ref.set({
        'id': contact.id,
        'userId': userId,
        'name': contact.name,
        'phoneNumber': contact.phoneNumber,
        'relationship': contact.relationship,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return contact;
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  TrustedContact _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return TrustedContact(
      id: data['id'] as String? ?? doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      relationship: data['relationship'] as String? ?? '',
    );
  }
}
