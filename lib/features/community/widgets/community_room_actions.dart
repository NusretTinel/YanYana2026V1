import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/widgets/community_room_form_sheet.dart';

/// Shared dialogs and snackbars for community room management.
class CommunityRoomActions {
  CommunityRoomActions._();

  static const deleteConfirmMessage =
      'Bu odayı silmek istediğine emin misin?';

  static Future<bool> confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Odayı Sil',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          deleteConfirmMessage,
          style: TextStyle(height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: YanYanaColors.sos,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    return result == true;
  }

  static void showCreatedSnackBar(
    BuildContext context, {
    required CommunityRoomCreationType type,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          type == CommunityRoomCreationType.live
              ? 'Canlı oda oluşturuldu.'
              : 'Örnek oda oluşturuldu.',
        ),
      ),
    );
  }

  static void showUpdatedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oda güncellendi.')),
    );
  }

  static void showDeletedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Oda silindi.')),
    );
  }
}
