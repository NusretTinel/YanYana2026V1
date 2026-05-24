import 'package:yanyana_p/core/constants/role_constants.dart';

class AppUser {
  final String id;
  final String name;
  final String email;
  /// Authorization: user | moderator | admin
  final String authRole;
  final String userType;
  final String volunteerStatus;
  final String disabilityType;
  final String communicationPreference;
  final List<String> interests;
  final int points;
  final List<String> badges;
  final String about;
  final String voiceIntro;
  final List<String> accessibilityNeeds;
  final List<String> communicationPreferences;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String photoURL;
  final String provider;

  // İşletme alanları
  final String businessName;
  final String businessOwner;
  final String businessLocation;
  final String businessPhone;
  final List<String> businessFacilities;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.authRole,
    this.userType = AppUserType.regularUser,
    this.volunteerStatus = VolunteerStatus.none,
    required this.disabilityType,
    required this.communicationPreference,
    required this.interests,
    required this.points,
    required this.badges,
    this.about = '',
    this.voiceIntro = '',
    this.accessibilityNeeds = const [],
    this.communicationPreferences = const [],
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.photoURL = '',
    this.provider = 'email',
    this.businessName = '',
    this.businessOwner = '',
    this.businessLocation = '',
    this.businessPhone = '',
    this.businessFacilities = const [],
  });

  bool get hasEmergencyContact =>
      emergencyContactName.trim().isNotEmpty &&
      emergencyContactPhone.trim().isNotEmpty;

  bool get isAdmin => AppAuthRole.isAdmin(authRole);
  bool get isModerator => AppAuthRole.isModerator(authRole);
  bool get isStaff => AppAuthRole.isStaff(authRole);

  String get userTypeLabel => AppUserType.label(userType);
  String get authRoleLabel => AppAuthRole.label(authRole);
  String get volunteerStatusLabel => VolunteerStatus.label(volunteerStatus);

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? authRole,
    String? userType,
    String? volunteerStatus,
    String? disabilityType,
    String? communicationPreference,
    List<String>? interests,
    int? points,
    List<String>? badges,
    String? about,
    String? voiceIntro,
    List<String>? accessibilityNeeds,
    List<String>? communicationPreferences,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? photoURL,
    String? provider,
    String? businessName,
    String? businessOwner,
    String? businessLocation,
    String? businessPhone,
    List<String>? businessFacilities,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      authRole: authRole ?? this.authRole,
      userType: userType ?? this.userType,
      volunteerStatus: volunteerStatus ?? this.volunteerStatus,
      disabilityType: disabilityType ?? this.disabilityType,
      communicationPreference:
          communicationPreference ?? this.communicationPreference,
      interests: interests ?? this.interests,
      points: points ?? this.points,
      badges: badges ?? this.badges,
      about: about ?? this.about,
      voiceIntro: voiceIntro ?? this.voiceIntro,
      accessibilityNeeds: accessibilityNeeds ?? this.accessibilityNeeds,
      communicationPreferences:
          communicationPreferences ?? this.communicationPreferences,
      emergencyContactName:
          emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      photoURL: photoURL ?? this.photoURL,
      provider: provider ?? this.provider,
      businessName: businessName ?? this.businessName,
      businessOwner: businessOwner ?? this.businessOwner,
      businessLocation: businessLocation ?? this.businessLocation,
      businessPhone: businessPhone ?? this.businessPhone,
      businessFacilities: businessFacilities ?? this.businessFacilities,
    );
  }
}
