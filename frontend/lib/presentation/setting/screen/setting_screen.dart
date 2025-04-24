import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/presentation/setting/widget/setting_item.dart';
import 'package:bracket_helper/presentation/setting/widget/setting_item_with_beta.dart';
import 'package:bracket_helper/presentation/setting/widget/section_title.dart';
import 'package:bracket_helper/presentation/setting/widget/theme_dropdown.dart';
import 'package:bracket_helper/presentation/setting/widget/language_dropdown.dart';
import 'package:bracket_helper/presentation/setting/widget/developer_info_bottom_sheet.dart';
import 'package:bracket_helper/presentation/setting/widget/contributors_dialog.dart';
import 'package:bracket_helper/presentation/setting/widget/email_feedback_launcher.dart';
import 'package:bracket_helper/presentation/setting/widget/privacy_policy_dialog.dart';
import 'package:bracket_helper/presentation/setting/widget/terms_of_service_dialog.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정', style: TST.largeTextBold.copyWith(color: CST.white)),
        backgroundColor: CST.primary100,
        foregroundColor: CST.white,
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const SectionTitle(title: '디스플레이'),
          SettingItemWithBeta(
            icon: Icons.brightness_6,
            title: '테마 설정',
            subtitle: '라이트 / 다크 / 시스템',
            trailing: const ThemeDropdown(
              onChanged: null, // 테마 변경 기능 구현 시 추가
            ),
          ),
          SettingItemWithBeta(
            icon: Icons.language,
            title: '언어',
            subtitle: '한국어 / 영어',
            trailing: const LanguageDropdown(
              onChanged: null, // 언어 변경 기능 구현 시 추가
            ),
          ),
          const SectionTitle(title: '앱 정보'),
          const SettingItem(
            icon: Icons.info_outline,
            title: '앱 버전',
            subtitle: 'v1.0.0',
          ),
          SettingItemWithBeta(
            icon: Icons.update,
            title: '업데이트 확인',
            onTap: () {
              // 업데이트 확인 기능 구현
            },
          ),
          const SectionTitle(title: '고객 지원'),
          SettingItem(
            icon: Icons.email_outlined,
            title: '문의 및 피드백',
            subtitle: '문제가 있거나 건의사항이 있으신가요?',
            onTap: () => EmailFeedbackLauncher.launch(context),
          ),
          SettingItemWithBeta(
            icon: Icons.star_outline,
            title: '평가하기',
            subtitle: '앱 스토어에서 평가해주세요',
            onTap: () {
              // 평가하기 기능 구현
            },
          ),
          const SectionTitle(title: '기타'),
          SettingItem(
            icon: Icons.code,
            title: '개발자 정보',
            onTap: () => DeveloperInfoBottomSheet.show(context),
          ),
          SettingItem(
            icon: Icons.people_outline,
            title: 'Thanks for',
            onTap: () => ContributorsDialog.show(context),
          ),
          SettingItem(
            icon: Icons.policy_outlined,
            title: '개인정보 처리방침',
            onTap: () => PrivacyPolicyDialog.show(context),
          ),
          SettingItem(
            icon: Icons.description_outlined,
            title: '서비스 이용약관',
            onTap: () => TermsOfServiceDialog.show(context),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            alignment: Alignment.center,
            child: Text(
              '© 2025 Kuneosu. All rights reserved.',
              style: TST.smallTextRegular.copyWith(
                color: CST.gray2,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
