import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/app_theme.dart';
import 'package:yanyana_p/shared/models/emergency_request.dart';

Future<void> showEmergencyRequestSheet({
  required BuildContext context,
  required EmergencyRequest request,
  required Future<void> Function() onDismiss,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _EmergencyRequestSheet(
      request: request,
      onDismiss: onDismiss,
    ),
  );
}

class _EmergencyRequestSheet extends StatelessWidget {
  const _EmergencyRequestSheet({
    required this.request,
    required this.onDismiss,
  });

  final EmergencyRequest request;
  final Future<void> Function() onDismiss;

  String _formatTime(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '${t.day}.${t.month}.${t.year} $h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final loc = request.latLng;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.paddingOf(context).bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: YanYanaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: YanYanaColors.sosLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  request.type == 'safe_call'
                      ? Icons.support_agent_rounded
                      : Icons.sos_rounded,
                  color: YanYanaColors.sos,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.typeLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Durum: ${request.statusLabel}',
                      style: const TextStyle(
                        color: YanYanaColors.sos,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: YanYanaColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: YanYanaColors.border),
            ),
            child: const Text(
              'Bu yalnızca yerel bir MVP kaydıdır. Gerçek acil arama veya SMS gönderilmez. '
              'Bildirim entegrasyonu gelecek sürümde planlanmıştır.',
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: YanYanaColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.schedule_rounded, 'Oluşturulma', _formatTime(request.createdAt)),
          if (loc != null)
            _infoRow(
              Icons.location_on_outlined,
              'Konum',
              '${loc.latitude.toStringAsFixed(5)}, ${loc.longitude.toStringAsFixed(5)}',
            ),
          if (request.trustedContactName != null)
            _infoRow(
              Icons.person_outline,
              'Güvenilir kişi',
              request.trustedContactName!,
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await onDismiss();
                if (context.mounted) Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Haritadan kaldır'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: YanYanaColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
