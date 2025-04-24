import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';

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
                AppStrings.privacyPolicyTitle,
                style: TST.mediumTextBold.copyWith(color: CST.gray1),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1, thickness: 1, color: CST.gray4),
            const SizedBox(height: 20),
            Text(
              AppStrings.privacyPolicyDescription1,
              style: TST.smallTextRegular.copyWith(
                color: CST.gray1,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.privacyPolicyDescription2,
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
                AppStrings.privacyPolicyDate,
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
                  AppStrings.close,
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
