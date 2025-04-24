import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class TournamentDeleteDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const TournamentDeleteDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 아이콘
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CST.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever,
                color: CST.error,
                size: 36,
              ),
            ),
            const SizedBox(height: 15),

            // 제목
            Text(
              AppStrings.tournamentDeleteTitle,
              style: TST.normalTextBold.copyWith(color: CST.gray1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // 내용
            Text(
              AppStrings.tournamentDeleteQuestion,
              style: TST.smallTextRegular.copyWith(color: CST.gray2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.tournamentDeleteWarning,
              style: TST.smallTextRegular.copyWith(
                color: CST.error,
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
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: CST.gray2,
                    backgroundColor: CST.gray4,
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
                    style: TST.smallTextBold.copyWith(color: CST.gray1),
                  ),
                ),
                const SizedBox(width: 16),

                // 삭제 버튼
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: CST.white,
                    backgroundColor: CST.error,
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
                    style: TST.smallTextBold.copyWith(color: CST.white),
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
  static Future<bool?> show({required BuildContext context}) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => TournamentDeleteDialog(
            onConfirm: () => Navigator.of(context).pop(true),
            onCancel: () => Navigator.of(context).pop(false),
          ),
    );
  }
}
