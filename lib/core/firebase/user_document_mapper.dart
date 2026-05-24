import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/shared/models/app_user.dart';

class UserDocumentMapper {
  UserDocumentMapper._();

  static Map<String, dynamic> toFirestore({
    required String uid,
    required String email,
    required String name,
    required String userType,
    required String provider,
    String role = AppAuthRole.user,
    String volunteerStatus = VolunteerStatus.none,
    String? photoURL,
    AppUser? existing,
    String? businessName,
    String? businessOwner,
    String? businessLocation,
    String? businessPhone,
  }) {
    final now = FieldValue.serverTimestamp();
    return {
      'uid': uid,
      'email': email.trim().toLowerCase(),
      'name': name,
      'photoURL': photoURL ?? existing?.photoURL ?? '',
      'provider': provider,
      'userType': AppUserType.normalize(userType),
      'role': AppAuthRole.normalize(role),
      'volunteerStatus': VolunteerStatus.normalize(volunteerStatus),
      'accessibilityNeeds': existing?.accessibilityNeeds ?? const [],
      'communicationPreferences':
          existing?.communicationPreferences ?? const [],
      'emergencyContactName': existing?.emergencyContactName ?? '',
      'emergencyContactPhone': existing?.emergencyContactPhone ?? '',
      'voiceDescription': existing?.voiceIntro ?? '',
      'favoriteTags': existing?.interests ?? const [],
      'points': existing?.points ?? 0,
      'badges': existing?.badges ?? const [],
      'disabilityType': existing?.disabilityType ?? '—',
      'about': existing?.about ?? '',
      'businessName': businessName ?? existing?.businessName ?? '',
      'businessOwner': businessOwner ?? existing?.businessOwner ?? '',
      'businessLocation': businessLocation ?? existing?.businessLocation ?? '',
      'businessPhone': businessPhone ?? existing?.businessPhone ?? '',
      'businessFacilities': existing?.businessFacilities ?? const [],
      'createdAt': existing == null ? now : null,
      'updatedAt': now,
    }..removeWhere((_, v) => v == null);
  }

  static AppUser fromFirestore(String uid, Map<String, dynamic> data) {
    final commPrefs = (data['communicationPreferences'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    return AppUser(
      id: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoURL: data['photoURL'] as String? ?? '',
      provider: data['provider'] as String? ?? 'email',
      userType: AppUserType.normalize(data['userType'] as String?),
      authRole: AppAuthRole.normalize(data['role'] as String?),
      volunteerStatus:
          VolunteerStatus.normalize(data['volunteerStatus'] as String?),
      disabilityType: data['disabilityType'] as String? ?? '—',
      communicationPreference:
          commPrefs.isNotEmpty ? commPrefs.join(', ') : 'Metin',
      interests: (data['favoriteTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      points: (data['points'] as num?)?.toInt() ?? 0,
      badges: (data['badges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      about: data['about'] as String? ?? '',
      voiceIntro: data['voiceDescription'] as String? ?? '',
      accessibilityNeeds: (data['accessibilityNeeds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      communicationPreferences: commPrefs,
      emergencyContactName: data['emergencyContactName'] as String? ?? '',
      emergencyContactPhone: data['emergencyContactPhone'] as String? ?? '',
      businessName: data['businessName'] as String? ?? '',
      businessOwner: data['businessOwner'] as String? ?? '',
      businessLocation: data['businessLocation'] as String? ?? '',
      businessPhone: data['businessPhone'] as String? ?? '',
      businessFacilities: (data['businessFacilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  static Map<String, dynamic> profileUpdate({
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
  }) {
    final map = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (name != null) map['name'] = name;
    if (disabilityType != null) map['disabilityType'] = disabilityType;
    if (about != null) map['about'] = about;
    if (voiceIntro != null) map['voiceDescription'] = voiceIntro;
    if (interests != null) map['favoriteTags'] = interests;
    if (accessibilityNeeds != null) {
      map['accessibilityNeeds'] = accessibilityNeeds;
    }
    if (communicationPreferences != null) {
      map['communicationPreferences'] = communicationPreferences;
    }
    if (emergencyContactName != null) {
      map['emergencyContactName'] = emergencyContactName;
    }
    if (emergencyContactPhone != null) {
      map['emergencyContactPhone'] = emergencyContactPhone;
    }
    if (businessName != null) map['businessName'] = businessName;
    if (businessOwner != null) map['businessOwner'] = businessOwner;
    if (businessLocation != null) map['businessLocation'] = businessLocation;
    if (businessPhone != null) map['businessPhone'] = businessPhone;
    if (businessFacilities != null) {
      map['businessFacilities'] = businessFacilities;
    }
    return map;
  }
}
