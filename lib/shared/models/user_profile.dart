import 'emergency_contact.dart';

/// Aggregated profile view for the current user (mock / future Firestore user doc).
class UserProfile {
  final String userId;
  final String fullName;
  final String email;
  final String technicalRole;
  final String disabilityType;
  final String communicationPreference;
  final List<String> interests;
  final int points;
  final List<String> badges;
  final List<EmergencyContact> emergencyContacts;

  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.technicalRole,
    required this.disabilityType,
    required this.communicationPreference,
    required this.interests,
    required this.points,
    required this.badges,
    required this.emergencyContacts,
  });
}
