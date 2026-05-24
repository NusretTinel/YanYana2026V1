/// Trusted contact for safety flows (mock; future encrypted user subdocument).
class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
  });
}
