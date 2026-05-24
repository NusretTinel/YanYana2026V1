/// Community success story stored in Firestore `success_stories`.
class SuccessStory {
  final String id;
  final String userId;
  final String authorName;
  final String title;
  final String content;
  final DateTime createdAt;
  final int likes;

  const SuccessStory({
    required this.id,
    required this.userId,
    required this.authorName,
    required this.title,
    required this.content,
    required this.createdAt,
    this.likes = 0,
  });
}
