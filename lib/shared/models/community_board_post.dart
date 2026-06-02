import 'package:flutter/material.dart';

/// Content types on the YanYana community board (mock / future Firestore).
enum CommunityBoardPostType {
  successStory,
  dailyAffirmation,
  awareness,
  complaintFeedback,
  eventAnnouncement,
  discountOpportunity,
  jobRelated,
}

/// Filter chip groups for the community board feed.
enum CommunityBoardFilter {
  all,
  stories,
  events,
  awareness,
  support,
  opportunities,
}

/// Rich community board post used by the mock feed UI.
class CommunityBoardPost {
  final String id;
  final CommunityBoardPostType type;
  final CommunityBoardFilter filter;
  final String title;
  final String content;
  final String authorName;
  final DateTime publishedAt;
  final int supportCount;
  final int commentCount;

  const CommunityBoardPost({
    required this.id,
    required this.type,
    required this.filter,
    required this.title,
    required this.content,
    required this.authorName,
    required this.publishedAt,
    required this.supportCount,
    required this.commentCount,
  });

  String get typeLabel => communityBoardPostTypeLabel(type);

  CommunityBoardPost copyWith({
    int? supportCount,
    int? commentCount,
  }) {
    return CommunityBoardPost(
      id: id,
      type: type,
      filter: filter,
      title: title,
      content: content,
      authorName: authorName,
      publishedAt: publishedAt,
      supportCount: supportCount ?? this.supportCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}

String communityBoardPostTypeLabel(CommunityBoardPostType type) {
  switch (type) {
    case CommunityBoardPostType.successStory:
      return 'Başarı Hikayesi';
    case CommunityBoardPostType.dailyAffirmation:
      return 'Günlük Olumlama';
    case CommunityBoardPostType.awareness:
      return 'Farkındalık';
    case CommunityBoardPostType.complaintFeedback:
      return 'Geri Bildirim';
    case CommunityBoardPostType.eventAnnouncement:
      return 'Etkinlik Duyurusu';
    case CommunityBoardPostType.discountOpportunity:
      return 'İndirim / Fırsat';
    case CommunityBoardPostType.jobRelated:
      return 'İş İlanı';
  }
}

String communityBoardFilterLabel(CommunityBoardFilter filter) {
  switch (filter) {
    case CommunityBoardFilter.all:
      return 'Tümü';
    case CommunityBoardFilter.stories:
      return 'Hikayeler';
    case CommunityBoardFilter.events:
      return 'Etkinlikler';
    case CommunityBoardFilter.awareness:
      return 'Farkındalık';
    case CommunityBoardFilter.support:
      return 'Destek';
    case CommunityBoardFilter.opportunities:
      return 'Fırsatlar';
  }
}

IconData communityBoardPostTypeIcon(CommunityBoardPostType type) {
  switch (type) {
    case CommunityBoardPostType.successStory:
      return Icons.emoji_events_rounded;
    case CommunityBoardPostType.dailyAffirmation:
      return Icons.wb_sunny_rounded;
    case CommunityBoardPostType.awareness:
      return Icons.visibility_rounded;
    case CommunityBoardPostType.complaintFeedback:
      return Icons.feedback_outlined;
    case CommunityBoardPostType.eventAnnouncement:
      return Icons.event_rounded;
    case CommunityBoardPostType.discountOpportunity:
      return Icons.local_offer_rounded;
    case CommunityBoardPostType.jobRelated:
      return Icons.work_outline_rounded;
  }
}

Color communityBoardPostTypeColor(CommunityBoardPostType type) {
  switch (type) {
    case CommunityBoardPostType.successStory:
      return const Color(0xFF22C55E);
    case CommunityBoardPostType.dailyAffirmation:
      return const Color(0xFFF59E0B);
    case CommunityBoardPostType.awareness:
      return const Color(0xFF6366F1);
    case CommunityBoardPostType.complaintFeedback:
      return const Color(0xFFEF4444);
    case CommunityBoardPostType.eventAnnouncement:
      return const Color(0xFF14B8A6);
    case CommunityBoardPostType.discountOpportunity:
      return const Color(0xFFA78BFA);
    case CommunityBoardPostType.jobRelated:
      return const Color(0xFF60A5FA);
  }
}
