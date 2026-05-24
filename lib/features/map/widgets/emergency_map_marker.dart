import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';
import 'package:yanyana_p/shared/models/emergency_request.dart';

/// Map marker UI for a local MVP emergency / support request.
class EmergencyMapMarker extends StatelessWidget {
  const EmergencyMapMarker({
    super.key,
    required this.request,
    required this.onTap,
  });

  final EmergencyRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: YanYanaColors.sos,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: YanYanaColors.sos.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${request.typeLabel} · ${request.statusLabel}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: YanYanaColors.sos.withValues(alpha: 0.5)),
            ),
            child: const Text(
              'Yerel MVP',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: YanYanaColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: YanYanaColors.sosLight,
              shape: BoxShape.circle,
              border: Border.all(color: YanYanaColors.sos, width: 2),
            ),
            child: Icon(
              request.type == 'safe_call'
                  ? Icons.support_agent_rounded
                  : Icons.sos_rounded,
              color: YanYanaColors.sos,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
