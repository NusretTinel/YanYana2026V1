/// Comment on a community post (mock; future Firestore `comments` subcollection).
class PostComment {
  final String id;
  final String postId;
  final String authorId;
  final String text;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.text,
    required this.createdAt,
  });
}
