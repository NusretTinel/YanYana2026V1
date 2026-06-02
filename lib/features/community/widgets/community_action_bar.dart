import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';

/// Header action buttons for Gönderi / Oda (replaces overlapping FABs on web).
class CommunityActionBar extends StatelessWidget {
  final VoidCallback onCreatePost;
  final VoidCallback onCreateRoom;

  const CommunityActionBar({
    super.key,
    required this.onCreatePost,
    required this.onCreateRoom,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 600;

    final postButton = _ActionTile(
      label: 'Gönderi',
      icon: Icons.post_add_rounded,
      color: YanYanaColors.secondary,
      onPressed: onCreatePost,
      expanded: isWide,
    );

    final roomButton = _ActionTile(
      label: 'Oda Oluştur',
      icon: Icons.add_rounded,
      color: YanYanaColors.primary,
      onPressed: onCreateRoom,
      expanded: isWide,
      subtitle: 'Yerel veya Firestore',
    );

    if (isWide) {
      return Row(
        children: [
          Expanded(child: postButton),
          const SizedBox(width: 12),
          Expanded(child: roomButton),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        postButton,
        const SizedBox(height: 10),
        roomButton,
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool expanded;

  const _ActionTile({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: subtitle != null ? '$label. $subtitle' : label,
      child: Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Container(
            width: expanded ? double.infinity : null,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment:
                  expanded ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: color.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
