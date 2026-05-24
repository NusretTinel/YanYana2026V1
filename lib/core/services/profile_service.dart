import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/firebase/firestore_collections.dart';
import 'package:yanyana_p/core/firebase/firebase_auth_errors.dart';
import 'package:yanyana_p/core/firebase/user_document_mapper.dart';
import 'package:yanyana_p/shared/models/app_user.dart';

/// Firestore user profile operations (client-side only).
class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection(FirestoreCollections.users).doc(uid);

  Future<AppUser?> getProfile(String uid) async {
    try {
      final snap = await _userRef(uid).get();
      if (!snap.exists || snap.data() == null) return null;
      return UserDocumentMapper.fromFirestore(uid, snap.data()!);
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }

  Stream<AppUser?> streamProfile(String uid) {
    return _userRef(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserDocumentMapper.fromFirestore(uid, snap.data()!);
    });
  }

  Future<void> createUserDocument({
    required String uid,
    required String email,
    required String name,
    required String userType,
    required String provider,
    String? photoURL,
    String volunteerStatus = VolunteerStatus.none,
    String? businessName,
    String? businessOwner,
    String? businessLocation,
    String? businessPhone,
  }) async {
    final data = UserDocumentMapper.toFirestore(
      uid: uid,
      email: email.trim().toLowerCase(),
      name: name,
      userType: userType,
      provider: provider,
      photoURL: photoURL,
      volunteerStatus: volunteerStatus,
      businessName: businessName,
      businessOwner: businessOwner,
      businessLocation: businessLocation,
      businessPhone: businessPhone,
    );
    await _userRef(uid).set(data);
  }

  Future<AppUser> ensureUserDocument(User firebaseUser, {String provider = 'email'}) async {
    final uid = firebaseUser.uid;
    final snap = await _userRef(uid).get();
    if (snap.exists && snap.data() != null) {
      return UserDocumentMapper.fromFirestore(uid, snap.data()!);
    }

    await createUserDocument(
      uid: uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'Kullanıcı',
      userType: AppUserType.regularUser,
      provider: provider,
      photoURL: firebaseUser.photoURL,
    );
    final created = await getProfile(uid);
    if (created == null) {
      throw Exception('Kullanıcı profili oluşturulamadı.');
    }
    return created;
  }

  Future<void> createUserDocumentIfNeeded({
    required User firebaseUser,
    String userType = AppUserType.regularUser,
    String volunteerStatus = VolunteerStatus.none,
    required String provider,
  }) async {
    final uid = firebaseUser.uid;
    final snap = await _userRef(uid).get();
    if (snap.exists) return;

    await createUserDocument(
      uid: uid,
      email: firebaseUser.email ?? '',
      name: firebaseUser.displayName ?? 'Kullanıcı',
      userType: userType,
      provider: provider,
      photoURL: firebaseUser.photoURL,
      volunteerStatus: volunteerStatus,
    );
  }

  Future<void> setVolunteerStatus(String uid, String status) async {
    await _userRef(uid).update({
      'volunteerStatus': VolunteerStatus.normalize(status),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser> updateProfile({
    required String uid,
    String? name,
    String? disabilityType,
    String? about,
    String? voiceIntro,
    List<String>? interests,
    List<String>? accessibilityNeeds,
    List<String>? communicationPreferences,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? businessName,
    String? businessOwner,
    String? businessLocation,
    String? businessPhone,
    List<String>? businessFacilities,
  }) async {
    final updateData = UserDocumentMapper.profileUpdate(
      name: name,
      disabilityType: disabilityType,
      about: about,
      voiceIntro: voiceIntro,
      interests: interests,
      accessibilityNeeds: accessibilityNeeds,
      communicationPreferences: communicationPreferences,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      businessName: businessName,
      businessOwner: businessOwner,
      businessLocation: businessLocation,
      businessPhone: businessPhone,
      businessFacilities: businessFacilities,
    );
    await _userRef(uid).update(updateData);
    final profile = await getProfile(uid);
    if (profile == null) {
      throw Exception('Profil güncellenemedi.');
    }
    return profile;
  }

  Future<void> updateEmail(String uid, String newEmail) async {
    await _userRef(uid).update({
      'email': newEmail.trim().toLowerCase(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<AppUser> updateEmergencyContact({
    required String uid,
    required String name,
    required String phone,
  }) =>
      updateProfile(
        uid: uid,
        emergencyContactName: name.trim(),
        emergencyContactPhone: phone.trim(),
      );

  Future<AppUser> updateAccessibilityPreferences({
    required String uid,
    required List<String> accessibilityNeeds,
    required List<String> communicationPreferences,
  }) =>
      updateProfile(
        uid: uid,
        accessibilityNeeds: accessibilityNeeds,
        communicationPreferences: communicationPreferences,
      );

  Future<String?> getUserType(String uid) async {
    final snap = await _userRef(uid).get();
    return snap.data()?['userType'] as String?;
  }

  Future<String?> getAuthRole(String uid) async {
    final snap = await _userRef(uid).get();
    return snap.data()?['role'] as String?;
  }

  /// Prefix search on `users.email` (min 2 characters) for login autocomplete.
  Future<List<String>> searchRegisteredEmails(String rawPrefix) async {
    final prefix = rawPrefix.trim().toLowerCase();
    if (prefix.length < 2) return [];

    try {
      final snap = await _db
          .collection(FirestoreCollections.users)
          .where('email', isGreaterThanOrEqualTo: prefix)
          .where('email', isLessThan: '$prefix\uf8ff')
          .limit(12)
          .get();

      final emails = <String>{};
      for (final doc in snap.docs) {
        final email = (doc.data()['email'] as String?)?.trim() ?? '';
        if (email.isEmpty) continue;
        if (email.toLowerCase().startsWith(prefix)) {
          emails.add(email);
        }
      }
      final list = emails.toList()..sort();
      return list.take(8).toList();
    } catch (e) {
      throw Exception(firebaseAuthErrorMessage(e));
    }
  }
}
