import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0), // 모서리 제거
      ),
      elevation: 0, // 그림자 제거
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                '개인정보 처리방침',
                style: TST.mediumTextBold.copyWith(color: CST.gray1),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: CST.gray4),
            const SizedBox(height: 20),
            Text(
              '이 앱은 인터넷 서버와 통신하지 않으며, 사용자의 어떤 개인정보도 수집하거나 저장하지 않습니다.',
              style: TST.smallTextRegular.copyWith(
                color: CST.gray1,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '단, 향후 광고 기능이 추가될 경우 광고 SDK를 통해 일부 정보가 수집될 수 있으며, 이에 대한 안내는 추후 별도로 제공됩니다.',
              style: TST.smallTextRegular.copyWith(
                color: CST.gray1,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1, color: CST.gray4),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '2025.04.24',
                style: TST.smallTextRegular.copyWith(color: CST.gray2),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: CST.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                    side: const BorderSide(color: CST.gray4, width: 1),
                  ),
                ),
                child: Text(
                  '닫기',
                  style: TST.normalTextRegular.copyWith(color: CST.primary100),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PrivacyPolicyDialog(),
    );
  }
}
