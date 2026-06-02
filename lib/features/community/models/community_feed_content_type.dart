/// Feed content types shown in Topluluk Akışı.
enum CommunityFeedContentType {
  dailyQuote('Günün Sözü'),
  communityPost('Topluluk Gönderisi'),
  successStory('Başarı Hikayesi');

  final String label;
  const CommunityFeedContentType(this.label);

  String get firestorePostType {
    switch (this) {
      case CommunityFeedContentType.dailyQuote:
        return 'daily_quote';
      case CommunityFeedContentType.communityPost:
        return 'community_post';
      case CommunityFeedContentType.successStory:
        return 'success_story';
    }
  }

  static CommunityFeedContentType? fromFirestorePostType(String? value) {
    switch (value) {
      case 'daily_quote':
        return CommunityFeedContentType.dailyQuote;
      case 'community_post':
        return CommunityFeedContentType.communityPost;
      default:
        return null;
    }
  }
}

/// Result from create/edit content form.
class CommunityContentFormData {
  final CommunityFeedContentType type;
  final String title;
  final String content;

  const CommunityContentFormData({
    required this.type,
    required this.title,
    required this.content,
  });
}
