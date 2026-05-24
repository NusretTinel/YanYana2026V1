/// Result of matching a support request to a volunteer (mock; future callable / rules).
class VolunteerMatch {
  final String supportRequestId;
  final String volunteerName;
  final double mockScore;
  final DateTime createdAt;

  const VolunteerMatch({
    required this.supportRequestId,
    required this.volunteerName,
    required this.mockScore,
    required this.createdAt,
  });
}
