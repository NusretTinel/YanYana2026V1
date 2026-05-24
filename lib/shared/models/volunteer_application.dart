class VolunteerApplication {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String reason;
  final String status;
  final DateTime? createdAt;

  const VolunteerApplication({
    required this.id,
    this.userId = '',
    required this.name,
    required this.email,
    required this.reason,
    required this.status,
    this.createdAt,
  });

  /// Legacy field used by some UI.
  String get supportArea => reason;

  VolunteerApplication copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? reason,
    String? status,
    DateTime? createdAt,
  }) {
    return VolunteerApplication(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
