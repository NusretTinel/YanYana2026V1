import 'package:flutter/material.dart';

/// Compact map action button (min 44px tap target).
class MapCompactFab extends StatelessWidget {
  const MapCompactFab({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.semanticLabel,
    this.foregroundColor = Colors.white,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color foregroundColor;
  final VoidCallback onPressed;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        elevation: 2,
        shadowColor: color.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        color: color,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: foregroundColor),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
