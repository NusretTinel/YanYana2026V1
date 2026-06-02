import 'package:flutter/material.dart';

/// Mock participant shown in community room detail previews.
class RoomParticipant {
  final String id;
  final String name;
  final String statusLabel;
  final String initials;
  final int avatarColorValue;

  const RoomParticipant({
    required this.id,
    required this.name,
    required this.statusLabel,
    required this.initials,
    required this.avatarColorValue,
  });
}

/// Live-style activity indicators for a mock room.
class RoomActivitySnapshot {
  final int onlineCount;
  final int typingCount;
  final bool isActiveToday;

  const RoomActivitySnapshot({
    required this.onlineCount,
    required this.typingCount,
    this.isActiveToday = true,
  });
}

/// Pinned community information shown at the top of a room.
class RoomPinnedInfo {
  final String title;
  final String body;
  final IconData icon;

  const RoomPinnedInfo({
    required this.title,
    required this.body,
    this.icon = Icons.info_outline_rounded,
  });
}
