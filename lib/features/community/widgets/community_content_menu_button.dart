import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';

/// Three-dots manage menu (edit + delete) for own community content.
class CommunityContentMenuButton extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CommunityContentMenuButton({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Semantics(
        label: 'Paylaşım seçenekleri',
        button: true,
        child: PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert_rounded,
            size: 22,
            color: YanYanaColors.textMuted,
          ),
          tooltip: 'Yönet',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
              case 'delete':
                onDelete();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Düzenle',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: YanYanaColors.sos,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Sil',
                    style: TextStyle(
                      color: YanYanaColors.sos,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
