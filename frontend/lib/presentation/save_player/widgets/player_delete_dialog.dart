import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class PlayerDeleteDialog extends StatelessWidget {
  final String playerName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const PlayerDeleteDialog({
    super.key,
    required this.playerName,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.playerDelete),
      content: Text('$playerName${AppStrings.playerDeleteConfirm}'),
      actions: [
        TextButton(onPressed: onCancel, child: Text(AppStrings.cancel)),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(AppStrings.delete),
        ),
      ],
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required String playerName,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => PlayerDeleteDialog(
            playerName: playerName,
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
    );
  }
}
