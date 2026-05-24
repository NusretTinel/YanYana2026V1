/// Emergency or safe-call request record (mock; future Firestore `sos_requests` collection).
enum SosKind { emergency, safeCall }

class SosRequest {
  final String id;
  final String userId;
  final SosKind kind;
  final DateTime createdAt;
  final String status;

  const SosRequest({
    required this.id,
    required this.userId,
    required this.kind,
    required this.createdAt,
    required this.status,
  });
}
