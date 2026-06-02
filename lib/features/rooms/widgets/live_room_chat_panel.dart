import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community_rooms/widgets/room_message_bubble.dart';
import 'package:yanyana_p/shared/models/live_room_message_model.dart';
import 'package:yanyana_p/shared/models/room_message.dart';

/// Real-time Firestore message list for a live community room.
class LiveRoomChatPanel extends StatefulWidget {
  final String roomId;
  final String currentUserId;
  final bool joined;

  const LiveRoomChatPanel({
    super.key,
    required this.roomId,
    required this.currentUserId,
    required this.joined,
  });

  @override
  State<LiveRoomChatPanel> createState() => LiveRoomChatPanelState();
}

class LiveRoomChatPanelState extends State<LiveRoomChatPanel> {
  final _scrollController = ScrollController();
  final _backend = BackendOrchestrator.instance;
  int _previousMessageCount = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  RoomMessage _toBubble(LiveRoomMessage message) {
    return RoomMessage(
      id: message.id,
      roomId: widget.roomId,
      authorName: message.senderName,
      text: message.text,
      sentAt: message.createdAt,
      isFromMe: message.senderId == widget.currentUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final listHeight =
        (MediaQuery.sizeOf(context).height * 0.38).clamp(240.0, 420.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: YanYanaColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                color: YanYanaColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Canlı Sohbet',
                    style: TextStyle(
                      color: YanYanaColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Firestore — gerçek zamanlı mesajlaşma',
                    style: TextStyle(
                      color: YanYanaColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          height: listHeight,
          decoration: BoxDecoration(
            color: YanYanaColors.surfaceSoft,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: YanYanaColors.border),
          ),
          child: StreamBuilder<List<LiveRoomMessage>>(
            stream: _backend.streamLiveRoomMessages(widget.roomId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: YanYanaColors.sos,
                        size: 32,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Mesajlar yüklenemedi',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: YanYanaColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: YanYanaColors.textMuted,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final messages = snapshot.data ?? const <LiveRoomMessage>[];

              if (messages.length != _previousMessageCount) {
                _previousMessageCount = messages.length;
                scrollToBottom();
              }

              if (messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      widget.joined
                          ? 'Henüz mesaj yok. İlk mesajı sen gönderebilirsin.'
                          : 'Henüz mesaj yok. Sohbete katılmak için odaya katılın.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final bubble = _toBubble(messages[index]);
                  return RoomMessageBubble(
                    message: bubble,
                    showAuthor: !bubble.isFromMe,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
