import 'package:flutter/material.dart';

/// Shared UX for partial / future features.
void showFutureFeatureDialog(
  BuildContext context, {
  String title = 'Yakında',
  String message =
      'Bu özellik gelecek sürümde eklenecektir. Şu an yalnızca planlanmış durumdadır.',
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Tamam'),
        ),
      ],
    ),
  );
}
