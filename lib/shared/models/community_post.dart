/// Community feed post (`community_posts` in Firestore).
class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String title;
  final String body;
  final DateTime createdAt;
  /// `daily_quote` or `community_post` when stored in Firestore.
  final String? postType;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.title,
    required this.body,
    required this.createdAt,
    this.postType,
  });

  /// Alias used in service/API specs.
  String get userId => authorId;

  /// Alias used in UI copy specs.
  String get content => body;
}
