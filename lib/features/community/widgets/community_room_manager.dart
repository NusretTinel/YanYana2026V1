import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/features/community/widgets/community_room_actions.dart';
import 'package:yanyana_p/features/community/widgets/community_room_form_sheet.dart';
import 'package:yanyana_p/features/community_rooms/data/mock_community_rooms_data.dart';
import 'package:yanyana_p/shared/models/community_room.dart';
import 'package:yanyana_p/shared/models/live_community_room_model.dart';

/// Add / edit / delete flows for live and mock community rooms.
class CommunityRoomManager {
  CommunityRoomManager._();

  static final _backend = BackendOrchestrator.instance;

  static String? get currentUserId => _backend.authService.currentUser?.id;

  static String get mockOwnerId => currentUserId ?? 'local_mock_user';

  static bool canManageLiveRoom(LiveCommunityRoom room) {
    final uid = currentUserId?.trim();
    if (uid == null || uid.isEmpty) return false;
    final owner = room.createdBy.trim();
    if (owner.isEmpty) return false;
    return owner == uid;
  }

  static bool canManageMockRoom(CommunityRoom room) {
    return MockCommunityRoomsData.canManage(room, mockOwnerId);
  }

  // --- Create room (unified) ---

  static Future<bool> createRoom(
    BuildContext context, {
    required VoidCallback onMockListChanged,
    CommunityRoomCreationType initialType = CommunityRoomCreationType.mock,
  }) async {
    CommunityRoomCreationType? savedType;

    final result = await CommunityRoomFormSheet.show(
      context,
      mode: CommunityRoomFormMode.create,
      initialCreationType: initialType,
      onSave: (data) async {
        final type = data.creationType ?? CommunityRoomCreationType.mock;
        savedType = type;
        if (type == CommunityRoomCreationType.live) {
          await _backend.createLiveCommunityRoom(
            name: data.name,
            description: data.description,
            category: data.category,
            accessibilityTags: data.accessibilityTags,
          );
        } else {
          MockCommunityRoomsData.addLocalRoom(
            title: data.name,
            description: data.description,
            category: data.category,
            accessibilityTags: data.accessibilityTags,
            ownerId: mockOwnerId,
          );
        }
      },
    );

    if (result == null || !context.mounted || savedType == null) return false;

    if (savedType == CommunityRoomCreationType.mock) {
      onMockListChanged();
    }

    CommunityRoomActions.showCreatedSnackBar(context, type: savedType!);
    return true;
  }

  /// Opens create dialog with live room pre-selected (e.g. Rooms module FAB).
  static Future<bool> createLiveRoom(BuildContext context) => createRoom(
        context,
        onMockListChanged: () {},
        initialType: CommunityRoomCreationType.live,
      );

  static Future<void> editLiveRoom(
    BuildContext context,
    LiveCommunityRoom room,
  ) async {
    if (!canManageLiveRoom(room)) return;

    final result = await CommunityRoomFormSheet.show(
      context,
      mode: CommunityRoomFormMode.liveEdit,
      initialName: room.name,
      initialDescription: room.description,
      initialCategory: room.category,
      initialTags: room.accessibilityTags,
      onSave: (data) async {
        await _backend.updateLiveCommunityRoom(
          roomId: room.id,
          name: data.name,
          description: data.description,
          category: data.category,
          accessibilityTags: data.accessibilityTags,
        );
      },
    );
    if (result == null || !context.mounted) return;
    CommunityRoomActions.showUpdatedSnackBar(context);
  }

  static Future<void> deleteLiveRoom(
    BuildContext context,
    LiveCommunityRoom room, {
    bool Function()? isDeleting,
    void Function(bool)? setDeleting,
  }) async {
    if (!canManageLiveRoom(room)) return;
    if (isDeleting?.call() == true) return;

    final confirmed = await CommunityRoomActions.confirmDelete(context);
    if (!confirmed || !context.mounted) return;

    setDeleting?.call(true);
    try {
      await _backend.deleteLiveCommunityRoom(room.id);
      if (!context.mounted) return;
      CommunityRoomActions.showDeletedSnackBar(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setDeleting?.call(false);
    }
  }

  // --- Mock rooms ---

  static Future<void> editMockRoom(
    BuildContext context,
    CommunityRoom room,
    VoidCallback onChanged,
  ) async {
    if (!canManageMockRoom(room)) return;

    final result = await CommunityRoomFormSheet.show(
      context,
      mode: CommunityRoomFormMode.mockEdit,
      initialName: room.title,
      initialDescription: room.description,
      initialCategory: room.category,
      initialTags: room.accessibilityTags,
      onSave: (data) async {
        MockCommunityRoomsData.updateLocalRoom(
          roomId: room.id,
          title: data.name,
          description: data.description,
          category: data.category,
          accessibilityTags: data.accessibilityTags,
          ownerId: mockOwnerId,
        );
      },
    );
    if (result == null || !context.mounted) return;
    onChanged();
    CommunityRoomActions.showUpdatedSnackBar(context);
  }

  static Future<void> deleteMockRoom(
    BuildContext context,
    CommunityRoom room,
    VoidCallback onChanged, {
    bool Function()? isDeleting,
    void Function(bool)? setDeleting,
  }) async {
    if (!canManageMockRoom(room)) return;
    if (isDeleting?.call() == true) return;

    final confirmed = await CommunityRoomActions.confirmDelete(context);
    if (!confirmed || !context.mounted) return;

    setDeleting?.call(true);
    try {
      MockCommunityRoomsData.deleteLocalRoom(
        roomId: room.id,
        ownerId: mockOwnerId,
      );
      if (!context.mounted) return;
      onChanged();
      CommunityRoomActions.showDeletedSnackBar(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setDeleting?.call(false);
    }
  }
}
