import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/models/community_room.dart';

/// Community rooms from Firestore (`community_rooms`).
class RoomsModulePage extends StatefulWidget {
  const RoomsModulePage({super.key});

  @override
  State<RoomsModulePage> createState() => _RoomsModulePageState();
}

class _RoomsModulePageState extends State<RoomsModulePage> {
  final _orchestrator = BackendOrchestrator.instance;
  List<CommunityRoom> _rooms = const [];
  bool _loading = true;
  StreamSubscription<List<CommunityRoom>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _orchestrator.streamCommunityRooms().listen(
      (rooms) {
        if (!mounted) return;
        setState(() {
          _rooms = rooms;
          _loading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _loading = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _joinRoom(CommunityRoom room) async {
    try {
      await _orchestrator.joinCommunityRoom(room.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${room.title} odasına katıldınız.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        elevation: 0,
        title: const Text(
          'Topluluk Odaları',
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _rooms.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Text(
                        'Henüz oda yok. Topluluk sekmesinden yeni oda oluşturabilirsiniz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: YanYanaColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: _rooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final r = _rooms[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: YanYanaColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: YanYanaColors.border),
                          boxShadow: YanYanaShadows.card,
                        ),
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.title,
                              style: const TextStyle(
                                color: YanYanaColors.textDark,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              r.category,
                              style: const TextStyle(
                                color: YanYanaColors.secondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (r.description.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                r.description,
                                style: const TextStyle(
                                  color: YanYanaColors.textMuted,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_alt_rounded,
                                  size: 20,
                                  color: YanYanaColors.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${r.memberCount} üye',
                                  style: const TextStyle(
                                    color: YanYanaColors.textMuted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _chip('Metin sohbet', YanYanaColors.primary),
                                if (r.isVoiceEnabled)
                                  _chip(
                                    'Sesli oda',
                                    YanYanaColors.accentPurple,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: FilledButton(
                                onPressed: () => _joinRoom(r),
                                style: FilledButton.styleFrom(
                                  backgroundColor: YanYanaColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Katıl',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  static Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: YanYanaColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
