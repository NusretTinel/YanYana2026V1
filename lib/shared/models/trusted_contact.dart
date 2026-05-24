/// User-added trusted contact for safe-call and emergency flows.
class TrustedContact {
  final String id;
  final String userId;
  final String name;
  final String phoneNumber;
  final String relationship;

  const TrustedContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
  });
}
