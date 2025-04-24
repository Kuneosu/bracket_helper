import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class GroupRenameDialog extends StatelessWidget {
  final String newName;
  final Function(String) onConfirm;

  const GroupRenameDialog({
    super.key,
    required this.newName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CST.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CST.black.withValues(alpha: 0.1),
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
              decoration: const BoxDecoration(
                color: CST.primary20,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit,
                color: CST.primary100,
                size: 36,
              ),
            ),
            const SizedBox(height: 15),

            // 제목
            Text(
              AppStrings.changeGroupName,
              style: TST.normalTextBold.copyWith(color: CST.gray1),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),

            // 내용
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TST.smallTextRegular.copyWith(color: CST.gray2),
                children: [
                  TextSpan(text: AppStrings.changeGroupNamePrefix),
                  TextSpan(
                    text: '"$newName"',
                    style: TST.smallTextBold.copyWith(
                      color: CST.primary100,
                    ),
                  ),
                  TextSpan(text: AppStrings.changeGroupNameSuffix),
                ],
              ),
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

                // 변경 버튼
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // 이름 변경 액션 호출
                    onConfirm(newName);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: CST.white,
                    backgroundColor: CST.primary100,
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
                    AppStrings.change,
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

  static Future<void> show(
    BuildContext context, {
    required String newName,
    required Function(String) onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => GroupRenameDialog(
        newName: newName,
        onConfirm: onConfirm,
      ),
    );
  }
} 