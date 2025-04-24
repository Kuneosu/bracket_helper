import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class HelpDialog extends StatelessWidget {
  final VoidCallback onClose;

  const HelpDialog({super.key, required this.onClose});

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단 아이콘과 제목
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CST.primary40,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.help_outline,
                    color: CST.primary100,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.helpDialogTitle,
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 도움말 내용
            Text(
              AppStrings.helpDialogDescription,
              style: TST.smallTextRegular.copyWith(color: CST.gray1),
            ),
            const SizedBox(height: 15),

            Text(
              AppStrings.helpDialogFeaturesTitle, 
              style: TST.smallTextBold.copyWith(color: CST.gray1)
            ),
            const SizedBox(height: 8),

            _buildFeatureItem(AppStrings.helpDialogFeature1),
            _buildFeatureItem(AppStrings.helpDialogFeature2),
            _buildFeatureItem(AppStrings.helpDialogFeature3),
            _buildFeatureItem(AppStrings.helpDialogFeature4),

            const SizedBox(height: 20),

            // 확인 버튼
            Center(
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  foregroundColor: CST.white,
                  backgroundColor: CST.primary100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  AppStrings.confirm,
                  style: TST.smallTextBold.copyWith(color: CST.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: CST.primary80, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TST.smallTextRegular.copyWith(color: CST.gray2),
            ),
          ),
        ],
      ),
    );
  }

  // 다이얼로그를 표시하는 정적 메서드
  static Future<void> show({required BuildContext context}) {
    return showDialog<void>(
      context: context,
      builder:
          (context) => HelpDialog(onClose: () => Navigator.of(context).pop()),
    );
  }
}
