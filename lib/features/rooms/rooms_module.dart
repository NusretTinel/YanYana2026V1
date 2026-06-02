import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/widgets/create_live_room_dialog.dart';
import 'package:yanyana_p/features/community/widgets/live_community_rooms_section.dart';

/// Full-screen live community rooms (Firestore `community_rooms`).
class RoomsModulePage extends StatelessWidget {
  const RoomsModulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        elevation: 0,
        title: const Text(
          'Canlı Topluluk Odaları',
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => CreateLiveRoomDialog.show(context),
        backgroundColor: YanYanaColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Oda', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: LiveCommunityRoomsSection(selectedCategory: 'Tümü'),
        ),
      ),
    );
  }
}
