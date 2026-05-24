import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/models/community_room.dart';

class RoomDetailPage extends StatefulWidget {
  final CommunityRoom room;

  const RoomDetailPage({super.key, required this.room});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  late Future<bool> _joinedFuture;

  @override
  void initState() {
    super.initState();
    _refreshJoined();
  }

  void _refreshJoined() {
    _joinedFuture =
        BackendOrchestrator.instance.isRoomJoined(widget.room.id);
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final backend = BackendOrchestrator.instance;

    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        title: Text(
          room.title,
          style: const TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.category,
                style: const TextStyle(
                  color: YanYanaColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                room.description,
                style: const TextStyle(
                  color: YanYanaColors.textMuted,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${room.memberCount} üye',
                style: const TextStyle(
                  color: YanYanaColors.textLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: YanYanaColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: YanYanaColors.border),
                ),
                child: const Text(
                  'Mesajlaşma özelliği bir sonraki sürümde bağlanacaktır. '
                  'Şimdilik odaya katılım kaydı tutulmaktadır.',
                  style: TextStyle(
                    color: YanYanaColors.textMuted,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FutureBuilder<bool>(
                future: _joinedFuture,
                builder: (context, snap) {
                  final joined = snap.data == true;
                  return SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: joined
                          ? null
                          : () async {
                              try {
                                await backend.joinCommunityRoom(room.id);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Odaya katıldınız.'),
                                  ),
                                );
                                Navigator.pop(context, true);
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.toString())),
                                );
                              }
                            },
                      icon: Icon(
                        joined ? Icons.check_rounded : Icons.login_rounded,
                      ),
                      label: Text(joined ? 'Katıldınız' : 'Odaya Katıl'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
