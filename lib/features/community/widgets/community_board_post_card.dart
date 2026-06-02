import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/data/mock_community_board_data.dart';
import 'package:yanyana_p/shared/models/community_board_post.dart';

/// Accessible card for a single community board post.
class CommunityBoardPostCard extends StatelessWidget {
  final CommunityBoardPost post;
  final bool supported;
  final VoidCallback onSupport;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const CommunityBoardPostCard({
    super.key,
    required this.post,
    required this.supported,
    required this.onSupport,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final typeColor = communityBoardPostTypeColor(post.type);
    final timeLabel = MockCommunityBoardData.formatTimeLabel(post.publishedAt);

    return Semantics(
      label:
          '${post.typeLabel}. ${post.title}. ${post.content}. '
          '${post.authorName}. $timeLabel. '
          '${post.supportCount} destek, ${post.commentCount} yorum.',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: YanYanaColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: YanYanaColors.border),
          boxShadow: YanYanaShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      communityBoardPostTypeIcon(post.type),
                      color: typeColor,
                      size: 22,
                      semanticLabel: post.typeLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.typeLabel,
                          style: TextStyle(
                            color: typeColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            color: YanYanaColors.textLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: const TextStyle(
                      color: YanYanaColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.content,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: YanYanaColors.textMuted,
                      fontSize: 15,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: YanYanaColors.primaryLight,
                        child: Text(
                          post.authorName.isNotEmpty
                              ? post.authorName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: YanYanaColors.primaryDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.authorName,
                          style: const TextStyle(
                            color: YanYanaColors.textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1, color: YanYanaColors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: supported ? 'Desteklendi' : 'Destekle',
                      icon: supported
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      active: supported,
                      count: post.supportCount,
                      onPressed: onSupport,
                      semanticLabel: supported
                          ? 'Desteği geri al'
                          : 'Gönderiyi destekle',
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      label: 'Yorum',
                      icon: Icons.chat_bubble_outline_rounded,
                      count: post.commentCount,
                      onPressed: onComment,
                      semanticLabel: 'Yorumları gör',
                    ),
                  ),
                  Expanded(
                    child: _ActionButton(
                      label: 'Paylaş',
                      icon: Icons.share_rounded,
                      onPressed: onShare,
                      semanticLabel: 'Gönderiyi paylaş',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final bool active;
  final int? count;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.active = false,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? YanYanaColors.primary : YanYanaColors.textMuted;
    final labelText = count != null ? '$label ($count)' : label;

    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: SizedBox(
            height: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  labelText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
