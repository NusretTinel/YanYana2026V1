import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';

/// Reusable titled info card for live room detail sections.
class LiveRoomInfoSection extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color accentColor;
  final List<String>? bulletRules;

  const LiveRoomInfoSection({
    super.key,
    required this.title,
    required this.body,
    required this.icon,
    this.accentColor = YanYanaColors.primary,
    this.bulletRules,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: YanYanaColors.border),
        boxShadow: YanYanaShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: YanYanaColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (bulletRules != null) ...[
            const SizedBox(height: 12),
            ...bulletRules!.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        size: 18, color: accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule,
                        style: const TextStyle(
                          color: YanYanaColors.textDark,
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
