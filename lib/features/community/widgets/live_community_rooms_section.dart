import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/widgets/community_room_manager.dart';
import 'package:yanyana_p/features/community_rooms/widgets/community_room_card.dart';
import 'package:yanyana_p/features/rooms/room_detail_page.dart' as live_rooms;
import 'package:yanyana_p/shared/models/live_community_room_model.dart';

/// Inline Firestore live rooms list for the Community tab.
class LiveCommunityRoomsSection extends StatefulWidget {
  final String selectedCategory;

  const LiveCommunityRoomsSection({
    super.key,
    required this.selectedCategory,
  });

  @override
  State<LiveCommunityRoomsSection> createState() =>
      _LiveCommunityRoomsSectionState();
}

class _LiveCommunityRoomsSectionState extends State<LiveCommunityRoomsSection> {
  final _orchestrator = BackendOrchestrator.instance;

  List<LiveCommunityRoom> _rooms = const [];
  bool _loading = true;
  String? _error;
  final Set<String> _joiningIds = {};
  final Set<String> _deletingIds = {};

  StreamSubscription<List<LiveCommunityRoom>>? _sub;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _orchestrator.authService.currentUser?.id;
    _sub = _orchestrator.streamLiveCommunityRooms().listen(
      (rooms) {
        if (!mounted) return;
        setState(() {
          _rooms = rooms;
          _loading = false;
          _error = null;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  List<LiveCommunityRoom> get _filtered {
    if (widget.selectedCategory == 'Tümü') return _rooms;
    return _rooms.where((r) => r.category == widget.selectedCategory).toList();
  }

  Future<void> _joinRoom(LiveCommunityRoom room) async {
    final uid = _currentUserId;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Katılmak için oturum açmanız gerekir.')),
      );
      return;
    }
    if (room.isJoinedBy(uid)) return;

    setState(() => _joiningIds.add(room.id));
    try {
      await _orchestrator.joinLiveCommunityRoom(room.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${room.name} odasına katıldınız.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _joiningIds.remove(room.id));
    }
  }

  void _openRoom(LiveCommunityRoom room) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => live_rooms.RoomDetailPage(room: room.toCommunityRoom()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _currentUserId = _orchestrator.authService.currentUser?.id;
    final uid = _currentUserId;
    final filtered = _filtered;

    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: YanYanaColors.sosLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: YanYanaColors.sos.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, color: YanYanaColors.sos, size: 32),
            const SizedBox(height: 12),
            const Text(
              'Canlı odalar yüklenemedi',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: YanYanaColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: YanYanaColors.textMuted, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (filtered.isEmpty) {
      final emptyMessage = _rooms.isEmpty
          ? 'Henüz canlı topluluk odası yok. İlk odayı sen oluşturabilirsin.'
          : '“${widget.selectedCategory}” için canlı oda bulunamadı.';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: YanYanaColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: YanYanaColors.border),
        ),
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: YanYanaColors.textMuted,
            fontWeight: FontWeight.w600,
            fontSize: 15,
            height: 1.45,
          ),
        ),
      );
    }

    return Column(
      children: filtered.map((room) {
        final joined = uid != null && room.isJoinedBy(uid);
        final joining = _joiningIds.contains(room.id);
        final deleting = _deletingIds.contains(room.id);
        final canManage = CommunityRoomManager.canManageLiveRoom(room);

        return Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Stack(
            children: [
              CommunityRoomCard(
                room: room.toCommunityRoom(),
                joined: joined,
                onOpen: () => _openRoom(room),
                onJoin: joining ? () {} : () => _joinRoom(room),
                canManage: canManage,
                onEdit: canManage
                    ? () => CommunityRoomManager.editLiveRoom(context, room)
                    : null,
                onDelete: canManage
                    ? () => CommunityRoomManager.deleteLiveRoom(
                          context,
                          room,
                          isDeleting: () => _deletingIds.contains(room.id),
                          setDeleting: (v) {
                            setState(() {
                              if (v) {
                                _deletingIds.add(room.id);
                              } else {
                                _deletingIds.remove(room.id);
                              }
                            });
                          },
                        )
                    : null,
              ),
              if (joining || deleting)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: YanYanaColors.surface.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(communityRoomCardRadius),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
