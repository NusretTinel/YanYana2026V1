import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/widgets/community_content_menu_button.dart';
import 'package:yanyana_p/shared/models/success_story.dart';

/// Rounded preview card for a [SuccessStory] (Home + Topluluk tab).
class CommunityStoryPreviewCard extends StatelessWidget {
  final SuccessStory story;
  final String timeLabel;
  final VoidCallback? onTap;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommunityStoryPreviewCard({
    super.key,
    required this.story,
    required this.timeLabel,
    this.onTap,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final showMenu = canManage && onEdit != null && onDelete != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Semantics(
        label:
            'Başarı hikayesi. ${story.title}. ${story.content}. '
            '${story.authorName}. $timeLabel',
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
                      color: YanYanaColors.accentYellow.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: YanYanaColors.warning.withValues(alpha: 0.2),
                      ),
                      boxShadow: YanYanaShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: YanYanaColors.warning,
                              size: 20,
                              semanticLabel: 'Başarı hikayesi',
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Başarı Hikayesi',
                              style: TextStyle(
                                color: YanYanaColors.warning,
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          story.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: YanYanaColors.textDark,
                            fontSize: 16,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          story.content,
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
                          '${story.authorName} · $timeLabel',
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
