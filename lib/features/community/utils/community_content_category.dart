import 'package:yanyana_p/features/community/models/community_feed_content_type.dart';
import 'package:yanyana_p/shared/models/community_post.dart';

/// Display category for a [CommunityPost] in the community feed.
String communityPostCategoryLabel(CommunityPost post) {
  return feedContentTypeForPost(post).label;
}

CommunityFeedContentType feedContentTypeForPost(CommunityPost post) {
  final fromField = CommunityFeedContentType.fromFirestorePostType(post.postType);
  if (fromField != null) return fromField;

  final t = post.title.toLowerCase();
  if (t.contains('günün') || t.contains('söz')) {
    return CommunityFeedContentType.dailyQuote;
  }
  return CommunityFeedContentType.communityPost;
}

bool isDailyQuotePost(CommunityPost post) {
  return feedContentTypeForPost(post) == CommunityFeedContentType.dailyQuote;
}

/// Title shown in cards (strips auto-prefix for daily quotes when needed).
String displayPostTitle(CommunityPost post) {
  if (feedContentTypeForPost(post) == CommunityFeedContentType.dailyQuote &&
      post.title.trim().toLowerCase() == 'günün sözü') {
    return post.body.length > 60 ? '${post.body.substring(0, 60)}…' : post.body;
  }
  return post.title;
}

String normalizedPostTitle({
  required CommunityFeedContentType type,
  required String title,
}) {
  final trimmed = title.trim();
  if (type == CommunityFeedContentType.dailyQuote) {
    return trimmed.isEmpty ? 'Günün Sözü' : trimmed;
  }
  return trimmed;
}
