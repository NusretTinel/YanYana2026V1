import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/shared/models/app_user.dart';

class RoleBadgesRow extends StatelessWidget {
  const RoleBadgesRow({
    super.key,
    required this.user,
    this.lightOnGradient = false,
  });

  final AppUser user;
  final bool lightOnGradient;

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[
      _BadgeChip(
        label: user.userTypeLabel,
        lightOnGradient: lightOnGradient,
        color: const Color(0xFF6366F1),
      ),
    ];

    final authLabel = user.authRoleLabel;
    if (authLabel.isNotEmpty) {
      badges.add(const SizedBox(width: 6));
      badges.add(
        _BadgeChip(
          label: authLabel,
          lightOnGradient: lightOnGradient,
          color: user.isAdmin
              ? const Color(0xFFDC2626)
              : const Color(0xFF7C3AED),
        ),
      );
    }

    final volunteerLabel = user.volunteerStatusLabel;
    if (volunteerLabel.isNotEmpty) {
      badges.add(const SizedBox(width: 6));
      badges.add(
        _BadgeChip(
          label: volunteerLabel,
          lightOnGradient: lightOnGradient,
          color: _volunteerColor(user.volunteerStatus),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 0,
      runSpacing: 6,
      children: badges,
    );
  }

  Color _volunteerColor(String status) {
    switch (VolunteerStatus.normalize(status)) {
      case VolunteerStatus.approved:
        return const Color(0xFF059669);
      case VolunteerStatus.rejected:
        return const Color(0xFFB45309);
      case VolunteerStatus.pending:
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFF64748B);
    }
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.label,
    required this.lightOnGradient,
    required this.color,
  });

  final String label;
  final bool lightOnGradient;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (lightOnGradient) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white30),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
