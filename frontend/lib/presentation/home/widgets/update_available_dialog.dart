import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';

class UpdateAvailableDialog extends StatelessWidget {
  const UpdateAvailableDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '새로운 버전이 있습니다',
        style: TST.mediumTextBold,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Icon(
            Icons.system_update,
            size: 48,
            color: CST.primary100,
          ),
          const SizedBox(height: 16),
          Text(
            '최신 버전의 앱으로 업데이트해 보세요.\n새로운 기능과 개선사항이 추가되었습니다.',
            style: TST.normalTextRegular,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            AppStrings.cancel,
            style: TST.normalTextBold.copyWith(color: CST.gray2),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            '업데이트',
            style: TST.normalTextBold.copyWith(color: CST.primary100),
          ),
        ),
      ],
    );
  }

  static Future<bool> show({required BuildContext context}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => const UpdateAvailableDialog(),
        ) ??
        false;
  }
} 