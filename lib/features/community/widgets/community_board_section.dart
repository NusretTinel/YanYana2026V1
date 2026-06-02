import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/community_board_page.dart';
import 'package:yanyana_p/features/community/data/mock_community_board_data.dart';
import 'package:yanyana_p/features/community/widgets/community_board_post_card.dart';
import 'package:yanyana_p/shared/models/community_board_post.dart';

/// Mock community board feed with filters and local interactions.
class CommunityBoardSection extends StatefulWidget {
  /// When set, only this many posts are shown with a “see all” action.
  final int? previewLimit;

  const CommunityBoardSection({super.key, this.previewLimit});

  @override
  State<CommunityBoardSection> createState() => _CommunityBoardSectionState();
}

class _CommunityBoardSectionState extends State<CommunityBoardSection> {
  CommunityBoardFilter _selectedFilter = CommunityBoardFilter.all;
  final Map<String, bool> _supported = {};
  final Map<String, int> _supportCounts = {};
  final Map<String, int> _commentCounts = {};

  @override
  void initState() {
    super.initState();
    for (final p in MockCommunityBoardData.posts) {
      _supportCounts[p.id] = p.supportCount;
      _commentCounts[p.id] = p.commentCount;
    }
  }

  List<CommunityBoardPost> get _filtered {
    return MockCommunityBoardData.filterPosts(_selectedFilter);
  }

  CommunityBoardPost _enriched(CommunityBoardPost post) {
    return post.copyWith(
      supportCount: _supportCounts[post.id] ?? post.supportCount,
      commentCount: _commentCounts[post.id] ?? post.commentCount,
    );
  }

  void _toggleSupport(String postId) {
    setState(() {
      final wasSupported = _supported[postId] == true;
      _supported[postId] = !wasSupported;
      final current = _supportCounts[postId] ?? 0;
      _supportCounts[postId] = wasSupported ? current - 1 : current + 1;
    });
  }

  void _showComments(CommunityBoardPost post) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.55,
            ),
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: YanYanaShadows.card,
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: YanYanaColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: YanYanaColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                const _MockComment(
                  author: 'Ayşe',
                  text: 'Çok güzel bir paylaşım, teşekkürler!',
                ),
                const _MockComment(
                  author: 'Moderatör',
                  text: 'Topluluk kurallarına uygun şekilde devam edelim.',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _commentCounts[post.id] =
                            (_commentCounts[post.id] ?? post.commentCount) + 1;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Yorumunuz eklendi (yerel).'),
                        ),
                      );
                    },
                    child: const Text(
                      'Yorum Ekle (Yerel)',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sharePost(CommunityBoardPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('“${post.title}” paylaşım linki kopyalandı (yerel).')),
    );
  }

  void _openFullBoard() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const CommunityBoardPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final limit = widget.previewLimit;
    final visible = limit != null && filtered.length > limit
        ? filtered.take(limit).toList()
        : filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topluluk Panosu',
                    style: TextStyle(
                      color: YanYanaColors.textDark,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Başarı hikayeleri, farkındalık, etkinlikler ve destek paylaşımları.',
                    style: TextStyle(
                      color: YanYanaColors.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (limit != null)
              Semantics(
                label: 'Tüm panoyu aç',
                button: true,
                child: TextButton(
                  onPressed: _openFullBoard,
                  child: const Text(
                    'Tümü',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: YanYanaColors.secondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Örnek içerik',
                style: TextStyle(
                  color: YanYanaColors.secondary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Yerel veri — sosyal katılım ve farkındalık',
                style: TextStyle(
                  color: YanYanaColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _BoardFilterChips(
          selected: _selectedFilter,
          onSelected: (f) => setState(() => _selectedFilter = f),
        ),
        const SizedBox(height: 14),
        if (visible.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: YanYanaColors.border),
            ),
            child: Text(
              '“${communityBoardFilterLabel(_selectedFilter)}” için gönderi bulunamadı.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: YanYanaColors.textMuted,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          )
        else
          ...visible.map((raw) {
            final post = _enriched(raw);
            return CommunityBoardPostCard(
              post: post,
              supported: _supported[post.id] == true,
              onSupport: () => _toggleSupport(post.id),
              onComment: () => _showComments(post),
              onShare: () => _sharePost(post),
            );
          }),
        if (limit != null && filtered.length > limit) ...[
          const SizedBox(height: 4),
          Semantics(
            label: 'Topluluk panosunun tamamını gör',
            button: true,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: _openFullBoard,
                icon: const Icon(Icons.dashboard_rounded, size: 22),
                label: const Text(
                  'Panonun Tamamını Gör',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: YanYanaColors.primary,
                  side: const BorderSide(color: YanYanaColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _BoardFilterChips extends StatelessWidget {
  final CommunityBoardFilter selected;
  final ValueChanged<CommunityBoardFilter> onSelected;

  const _BoardFilterChips({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MockCommunityBoardData.filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final f = MockCommunityBoardData.filters[i];
          final isSelected = f == selected;
          final label = communityBoardFilterLabel(f);
          return Semantics(
            label: '$label${isSelected ? ", seçili" : ""}',
            button: true,
            selected: isSelected,
            child: GestureDetector(
              onTap: () => onSelected(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? YanYanaColors.secondary : YanYanaColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected ? YanYanaColors.secondary : YanYanaColors.border,
                  ),
                  boxShadow: isSelected ? YanYanaShadows.soft : null,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : YanYanaColors.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MockComment extends StatelessWidget {
  final String author;
  final String text;

  const _MockComment({required this.author, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: YanYanaColors.primaryLight,
            child: Text(
              author[0],
              style: const TextStyle(
                color: YanYanaColors.primaryDark,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: YanYanaColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
