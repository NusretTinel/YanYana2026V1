import 'package:flutter/material.dart';
import 'package:yanyana_p/features/community/widgets/community_room_manager.dart';

/// Bottom sheet to create a live Firestore community room.
class CreateLiveRoomDialog {
  CreateLiveRoomDialog._();

  static Future<bool> show(BuildContext context) =>
      CommunityRoomManager.createLiveRoom(context);
}
