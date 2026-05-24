class SupportRequest {
  final String id;
  final String requesterName;
  final String requestType;
  final String description;
  final String status;
  final String? assignedVolunteerName;

  const SupportRequest({
    required this.id,
    required this.requesterName,
    required this.requestType,
    required this.description,
    required this.status,
    this.assignedVolunteerName,
  });

  SupportRequest copyWith({
    String? id,
    String? requesterName,
    String? requestType,
    String? description,
    String? status,
    String? assignedVolunteerName,
  }) {
    return SupportRequest(
      id: id ?? this.id,
      requesterName: requesterName ?? this.requesterName,
      requestType: requestType ?? this.requestType,
      description: description ?? this.description,
      status: status ?? this.status,
      assignedVolunteerName: assignedVolunteerName ?? this.assignedVolunteerName,
    );
  }
}

