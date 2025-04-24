import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';

class TermsOfServiceDialog extends StatelessWidget {
  const TermsOfServiceDialog({super.key});

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
                '서비스 이용약관',
                style: TST.mediumTextBold.copyWith(color: CST.gray1),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: CST.gray4),
            const SizedBox(height: 20),
            Text(
              '제 1조 (목적)',
              style: TST.smallTextBold.copyWith(color: CST.gray1),
            ),
            const SizedBox(height: 8),
            Text(
              '이 앱은 무료로 제공되며, 모든 콘텐츠는 "있는 그대로" 제공됩니다.',
              style: TST.smallTextRegular.copyWith(
                color: CST.gray1,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '제 2조 (이용제한)',
              style: TST.smallTextBold.copyWith(color: CST.gray1),
            ),
            const SizedBox(height: 8),
            Text(
              '사용자는 자유롭게 앱을 사용할 수 있으나, 불법적인 목적이나 타인의 권리를 침해하는 목적으로 사용해서는 안 됩니다.',
              style: TST.smallTextRegular.copyWith(
                color: CST.gray1,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '제 3조 (면책조항)',
              style: TST.smallTextBold.copyWith(color: CST.gray1),
            ),
            const SizedBox(height: 8),
            Text(
              '개발자는 이 앱의 사용으로 인해 발생하는 어떠한 직접적, 간접적, 부수적 손해에 대해서도 책임을 지지 않습니다.',
              style: TST.smallTextRegular.copyWith(
                color: CST.gray1,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(height: 1, thickness: 1, color: CST.gray4),
            const SizedBox(height: 16),
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
      builder: (context) => const TermsOfServiceDialog(),
    );
  }
}
