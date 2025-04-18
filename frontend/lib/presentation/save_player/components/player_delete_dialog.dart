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
      title: const Text('선수 삭제'),
      content: Text('$playerName 선수를 삭제하시겠습니까?'),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('취소')),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('삭제'),
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
