import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/utils/community_content_category.dart';
import 'package:yanyana_p/features/community/widgets/community_content_menu_button.dart';
import 'package:yanyana_p/shared/models/community_post.dart';

/// Rounded preview card for a [CommunityPost] (Home + Topluluk tab).
class CommunityPostPreviewCard extends StatelessWidget {
  final CommunityPost post;
  final String timeLabel;
  final VoidCallback? onTap;
  final String categoryLabel;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommunityPostPreviewCard({
    super.key,
    required this.post,
    required this.timeLabel,
    this.onTap,
    this.categoryLabel = 'Topluluk Gönderisi',
    this.canManage = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final showMenu = canManage && onEdit != null && onDelete != null;
    final displayTitle = displayPostTitle(post);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        label:
            '$categoryLabel. $displayTitle. ${post.body}. '
            '${post.authorName}. $timeLabel',
        button: onTap != null,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onTap,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 140),
                  child: Ink(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(18, 18, showMenu ? 44 : 18, 18),
                    decoration: BoxDecoration(
                      color: YanYanaColors.secondaryLight,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: YanYanaColors.secondary.withValues(alpha: 0.15),
                      ),
                      boxShadow: YanYanaShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: YanYanaColors.surface.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            categoryLabel,
                            style: const TextStyle(
                              color: YanYanaColors.secondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          displayTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: YanYanaColors.textDark,
                            fontSize: 16,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          post.body,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: YanYanaColors.textMuted,
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${post.authorName} · $timeLabel',
                          style: const TextStyle(
                            color: YanYanaColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showMenu)
                Positioned(
                  top: 10,
                  right: 6,
                  child: CommunityContentMenuButton(
                    onEdit: onEdit!,
                    onDelete: onDelete!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
