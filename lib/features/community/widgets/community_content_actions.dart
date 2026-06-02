import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';

/// Shared dialogs and snackbars for community content management.
class CommunityContentActions {
  CommunityContentActions._();

  static const deleteConfirmMessage =
      'Bu paylaşımı silmek istediğine emin misin?';

  static Future<bool> confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Paylaşımı Sil',
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

  static void showDeletedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşım silindi.')),
    );
  }

  static void showUpdatedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paylaşım güncellendi.')),
    );
  }
}
