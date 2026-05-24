class CommunityRoom {
  final String id;
  final String title;
  final String category;
  final String description;
  final int memberCount;
  final bool isVoiceEnabled;
  final bool isAuthorizedRoom;
  final String createdByUserId;

  const CommunityRoom({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    this.memberCount = 1,
    this.isVoiceEnabled = false,
    this.isAuthorizedRoom = false,
    this.createdByUserId = '',
  });

  CommunityRoom copyWith({
    int? memberCount,
  }) {
    return CommunityRoom(
      id: id,
      title: title,
      category: category,
      description: description,
      memberCount: memberCount ?? this.memberCount,
      isVoiceEnabled: isVoiceEnabled,
      isAuthorizedRoom: isAuthorizedRoom,
      createdByUserId: createdByUserId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'description': description,
        'memberCount': memberCount,
        'isVoiceEnabled': isVoiceEnabled,
        'isAuthorizedRoom': isAuthorizedRoom,
        'createdByUserId': createdByUserId,
      };

  factory CommunityRoom.fromJson(Map<String, dynamic> json) {
    return CommunityRoom(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 1,
      isVoiceEnabled: json['isVoiceEnabled'] as bool? ?? false,
      isAuthorizedRoom: json['isAuthorizedRoom'] as bool? ?? false,
      createdByUserId: json['createdByUserId'] as String? ?? '',
    );
  }
}
