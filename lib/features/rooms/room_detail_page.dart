import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/utils/room_purpose_text.dart';
import 'package:yanyana_p/features/community/widgets/community_responsive_shell.dart';
import 'package:yanyana_p/features/community_rooms/widgets/room_activity_bar.dart';
import 'package:yanyana_p/features/community_rooms/widgets/room_chat_composer.dart';
import 'package:yanyana_p/features/rooms/widgets/live_room_chat_panel.dart';
import 'package:yanyana_p/features/rooms/widgets/live_room_detail_header.dart';
import 'package:yanyana_p/features/rooms/widgets/live_room_info_section.dart';
import 'package:yanyana_p/shared/models/community_room.dart';
import 'package:yanyana_p/shared/models/live_community_room_model.dart';

/// Live Firestore community room detail (demo-ready layout).
class RoomDetailPage extends StatefulWidget {
  final CommunityRoom room;

  const RoomDetailPage({super.key, required this.room});

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final _backend = BackendOrchestrator.instance;
  final _messageController = TextEditingController();
  final _chatPanelKey = GlobalKey<LiveRoomChatPanelState>();

  late int currentMemberCount;
  late bool isJoined;

  bool _joining = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    currentMemberCount = widget.room.memberCount;
    isJoined = false;
    _loadJoinedState();
  }

  Future<void> _loadJoinedState() async {
    final sender = _backend.resolveLiveRoomChatSender();
    if (sender.id == 'guest_yanyana') return;

    final joined = await _backend.isRoomJoined(widget.room.id);
    if (!mounted || !joined) return;
    setState(() => isJoined = true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  /// Syncs from Firestore only upward — never lowers [currentMemberCount].
  void _syncFromLiveRoom(LiveCommunityRoom? live, String userId) {
    if (live == null) return;

    var changed = false;
    if (live.isJoinedBy(userId) && !isJoined) {
      isJoined = true;
      changed = true;
    }
    if (live.memberCount > currentMemberCount) {
      currentMemberCount = live.memberCount;
      changed = true;
    }
    if (changed && mounted) setState(() {});
  }

  Future<void> _joinRoom(String roomId, String roomTitle) async {
    if (isJoined || _joining) return;

    final previousCount = currentMemberCount;
    final previousJoined = isJoined;

    setState(() {
      isJoined = true;
      currentMemberCount = currentMemberCount + 1;
      _joining = true;
    });

    try {
      await _backend.joinLiveCommunityRoom(roomId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$roomTitle odasına katıldınız.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isJoined = previousJoined;
        currentMemberCount = previousCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _sendMessage(String roomId) async {
    if (_sending) return;
    final text = _messageController.text;
    if (text.trim().isEmpty) return;

    setState(() => _sending = true);
    try {
      await _backend.sendLiveRoomMessage(roomId: roomId, text: text);
      if (!mounted) return;
      _messageController.clear();
      _chatPanelKey.currentState?.scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sender = _backend.resolveLiveRoomChatSender();

    return Scaffold(
      backgroundColor: YanYanaColors.background,
      body: SafeArea(
        child: StreamBuilder<List<LiveCommunityRoom>>(
          stream: _backend.streamLiveCommunityRooms(),
          builder: (context, snapshot) {
            LiveCommunityRoom? live;
            for (final r in snapshot.data ?? const <LiveCommunityRoom>[]) {
              if (r.id == widget.room.id) {
                live = r;
                break;
              }
            }

            if (live != null && sender.id != 'guest_yanyana') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _syncFromLiveRoom(live, sender.id);
              });
            }

            final room = live?.toCommunityRoom() ?? widget.room;
            final tags = displayAccessibilityTags(
              live?.accessibilityTags ?? room.accessibilityTags,
            );

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                    child: CommunityResponsiveShell(
                      maxWidth: 720,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LiveRoomDetailHeader(
                            room: room,
                            memberCount: currentMemberCount,
                            accessibilityTags: tags,
                            joined: isJoined,
                            joining: _joining,
                            onBack: () => Navigator.maybePop(context),
                            onJoinToggle: isJoined
                                ? () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Bu odaya zaten katıldınız.'),
                                      ),
                                    );
                                  }
                                : () => _joinRoom(room.id, room.title),
                          ),
                          RoomActivityBar(
                            memberCount: currentMemberCount,
                            chatActive: isJoined,
                          ),
                          const SizedBox(height: 20),
                          LiveRoomInfoSection(
                            title: 'Oda Amacı',
                            body: roomPurposeForCategory(room.category),
                            icon: Icons.flag_rounded,
                            accentColor: YanYanaColors.secondary,
                          ),
                          const SizedBox(height: 14),
                          const LiveRoomInfoSection(
                            title: 'Topluluk Kuralları',
                            body:
                                'Bu alanda herkesin güvende hissetmesi için aşağıdaki '
                                'kurallara uyalım:',
                            icon: Icons.gavel_rounded,
                            accentColor: YanYanaColors.primary,
                            bulletRules: liveRoomGuidelineRules,
                          ),
                          const SizedBox(height: 14),
                          LiveRoomChatPanel(
                            key: _chatPanelKey,
                            roomId: room.id,
                            currentUserId: sender.id,
                            joined: isJoined,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                CommunityResponsiveShell(
                  maxWidth: 720,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: RoomChatComposer(
                    controller: _messageController,
                    enabled: isJoined && !_sending,
                    onSend: () => _sendMessage(room.id),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
