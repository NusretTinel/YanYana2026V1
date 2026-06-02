import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/models/community_room.dart';

/// Header card for live Firestore room detail.
class LiveRoomDetailHeader extends StatelessWidget {
  final CommunityRoom room;
  final int memberCount;
  final List<String> accessibilityTags;
  final bool joined;
  final bool joining;
  final VoidCallback onBack;
  final VoidCallback onJoinToggle;

  const LiveRoomDetailHeader({
    super.key,
    required this.room,
    required this.memberCount,
    required this.accessibilityTags,
    required this.joined,
    required this.joining,
    required this.onBack,
    required this.onJoinToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: calmGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: YanYanaShadows.card,
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.title,
                  style: const TextStyle(
                    color: YanYanaColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(room.category, YanYanaColors.secondary),
                    _chip('$memberCount üye', YanYanaColors.accentBlue),
                    if (joined) _chip('Katıldınız', YanYanaColors.success),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: accessibilityTags
                      .map((t) => _chip(t, YanYanaColors.primary))
                      .toList(),
                ),
                const SizedBox(height: 14),
                Text(
                  room.description,
                  style: const TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 15,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: joining ? null : onJoinToggle,
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          joined ? YanYanaColors.success : YanYanaColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          YanYanaColors.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: joining
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            joined
                                ? Icons.check_circle_rounded
                                : Icons.login_rounded,
                          ),
                    label: Text(
                      joined ? 'Katıldınız' : 'Katıl',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Semantics(
              label: 'Geri dön',
              button: true,
              child: Material(
                color: YanYanaColors.surface.withValues(alpha: 0.92),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: YanYanaColors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color == YanYanaColors.primary
              ? YanYanaColors.primaryDark
              : YanYanaColors.textDark,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}
