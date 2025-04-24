import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class PlayerConfirmDeleteDialog extends StatelessWidget {
  final PlayerModel player;
  final Function(int) onDelete;

  const PlayerConfirmDeleteDialog({
    super.key,
    required this.player,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 아이콘
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_outlined,
                color: Colors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 15),

            // 제목
            Text(
              AppStrings.playerDelete,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // 내용
            Text(
              '${player.name}${AppStrings.playerDeleteConfirm}',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.playerDeleteWarning,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 취소 버튼
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    AppStrings.cancel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),

                // 삭제 버튼
                ElevatedButton(
                  onPressed: () {
                    // 다이얼로그 닫기
                    Navigator.of(context).pop();

                    // 선수 삭제 콜백 호출
                    onDelete(player.id);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                    AppStrings.delete,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 다이얼로그를 표시하는 정적 메서드
  static Future<void> show({
    required BuildContext context,
    required PlayerModel player,
    required Function(int) onDelete,
  }) {
    return showDialog<void>(
      context: context,
      builder:
          (context) =>
              PlayerConfirmDeleteDialog(player: player, onDelete: onDelete),
    );
  }
}
