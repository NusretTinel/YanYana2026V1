import 'package:yanyana_p/shared/models/community_board_post.dart';

/// Static mock posts for the community board feed (no Firebase).
class MockCommunityBoardData {
  MockCommunityBoardData._();

  static const List<CommunityBoardFilter> filters = [
    CommunityBoardFilter.all,
    CommunityBoardFilter.stories,
    CommunityBoardFilter.events,
    CommunityBoardFilter.awareness,
    CommunityBoardFilter.support,
    CommunityBoardFilter.opportunities,
  ];

  static final List<CommunityBoardPost> posts = [
    CommunityBoardPost(
      id: 'board-1',
      type: CommunityBoardPostType.successStory,
      filter: CommunityBoardFilter.stories,
      title: 'İlk iş görüşmemde özgüven kazandım',
      content:
          'Mentorluk odasındaki destek sayesinde görüşmeye hazır hissettim. '
          'Topluluğa teşekkürler!',
      authorName: 'Elif K.',
      publishedAt: DateTime(2026, 5, 18, 9, 15),
      supportCount: 48,
      commentCount: 12,
    ),
    CommunityBoardPost(
      id: 'board-2',
      type: CommunityBoardPostType.dailyAffirmation,
      filter: CommunityBoardFilter.awareness,
      title: 'Bugün küçük bir adım yeterli',
      content:
          'Kendine nazik ol. İlerleme bazen yavaş görünür ama değerlidir.',
      authorName: 'YanYana Ekibi',
      publishedAt: DateTime(2026, 5, 18, 7, 0),
      supportCount: 92,
      commentCount: 5,
    ),
    CommunityBoardPost(
      id: 'board-3',
      type: CommunityBoardPostType.awareness,
      filter: CommunityBoardFilter.awareness,
      title: 'Görünmez engeller hakkında',
      content:
          'Enerji kısıtlılığı olan kişiler için dinlenme molaları '
          'erişilebilirlik ihtiyacıdır. Farkındalık paylaşıyoruz.',
      authorName: 'Kerem A.',
      publishedAt: DateTime(2026, 5, 17, 14, 30),
      supportCount: 67,
      commentCount: 18,
    ),
    CommunityBoardPost(
      id: 'board-4',
      type: CommunityBoardPostType.complaintFeedback,
      filter: CommunityBoardFilter.support,
      title: 'Metro istasyonunda asansör önerisi',
      content:
          'Kadıköy çıkışındaki asansör sık arızalı. Belediyeye iletilmesi '
          'için topluluk geri bildirimi topluyoruz.',
      authorName: 'Merve D.',
      publishedAt: DateTime(2026, 5, 17, 11, 20),
      supportCount: 34,
      commentCount: 9,
    ),
    CommunityBoardPost(
      id: 'board-5',
      type: CommunityBoardPostType.eventAnnouncement,
      filter: CommunityBoardFilter.events,
      title: 'Online Erişilebilirlik Buluşması — 25 Mayıs',
      content:
          'Kayıtlar açıldı. Canlı altyazı ve işaret dili tercümanı '
          'desteği planlanıyor.',
      authorName: 'YanYana Etkinlik',
      publishedAt: DateTime(2026, 5, 16, 16, 0),
      supportCount: 56,
      commentCount: 14,
    ),
    CommunityBoardPost(
      id: 'board-6',
      type: CommunityBoardPostType.discountOpportunity,
      filter: CommunityBoardFilter.opportunities,
      title: '%20 indirim: Erişilebilir sinema seansı',
      content:
          'Partner salonumuzda tekerlekli koltuk alanları için özel seans. '
          'Kod: YANYANA20',
      authorName: 'Partner Ağı',
      publishedAt: DateTime(2026, 5, 16, 10, 45),
      supportCount: 41,
      commentCount: 7,
    ),
    CommunityBoardPost(
      id: 'board-7',
      type: CommunityBoardPostType.jobRelated,
      filter: CommunityBoardFilter.opportunities,
      title: 'Uzaktan müşteri destek uzmanı — kapsayıcı işveren',
      content:
          'Esnek çalışma, ekran okuyucu uyumlu araçlar ve mentorluk '
          'programı sunuluyor.',
      authorName: 'İK Ortağı',
      publishedAt: DateTime(2026, 5, 15, 13, 0),
      supportCount: 29,
      commentCount: 11,
    ),
    CommunityBoardPost(
      id: 'board-8',
      type: CommunityBoardPostType.successStory,
      filter: CommunityBoardFilter.stories,
      title: 'Yeni arkadaşlıklar kurdum',
      content:
          'Günlük sohbet odasında tanıştığım kişilerle hafta sonu '
          'buluştuk. Sosyal katılım gerçekten işe yarıyor.',
      authorName: 'Can Y.',
      publishedAt: DateTime(2026, 5, 15, 18, 30),
      supportCount: 73,
      commentCount: 16,
    ),
    CommunityBoardPost(
      id: 'board-9',
      type: CommunityBoardPostType.eventAnnouncement,
      filter: CommunityBoardFilter.events,
      title: 'Destek Odası: Haftalık dinleme saati',
      content:
          'Her Çarşamba 20:00’de moderatörlü güvenli dinleme oturumu.',
      authorName: 'Topluluk Moderatörü',
      publishedAt: DateTime(2026, 5, 14, 9, 0),
      supportCount: 38,
      commentCount: 6,
    ),
    CommunityBoardPost(
      id: 'board-10',
      type: CommunityBoardPostType.awareness,
      filter: CommunityBoardFilter.awareness,
      title: 'Kapsayıcı dil rehberi güncellendi',
      content:
          'Topluluk kurallarımıza saygılı iletişim örnekleri eklendi. '
          'Panodan inceleyebilirsiniz.',
      authorName: 'YanYana Ekibi',
      publishedAt: DateTime(2026, 5, 14, 15, 0),
      supportCount: 51,
      commentCount: 4,
    ),
  ];

  static List<CommunityBoardPost> filterPosts(CommunityBoardFilter filter) {
    if (filter == CommunityBoardFilter.all) {
      return List<CommunityBoardPost>.from(posts);
    }
    return posts.where((p) => p.filter == filter).toList();
  }

  static String formatTimeLabel(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inHours < 1) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d.$m.${dt.year}';
  }
}
