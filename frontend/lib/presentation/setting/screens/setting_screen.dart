import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/presentation/setting/widgets/setting_item.dart';
import 'package:bracket_helper/presentation/setting/widgets/setting_item_with_beta.dart';
import 'package:bracket_helper/presentation/setting/widgets/section_title.dart';
import 'package:bracket_helper/presentation/setting/widgets/theme_dropdown.dart';
import 'package:bracket_helper/presentation/setting/widgets/language_dropdown.dart';
import 'package:bracket_helper/presentation/setting/widgets/developer_info_bottom_sheet.dart';
import 'package:bracket_helper/presentation/setting/widgets/contributors_dialog.dart';
import 'package:bracket_helper/presentation/setting/widgets/email_feedback_launcher.dart';
import 'package:bracket_helper/presentation/setting/widgets/privacy_policy_dialog.dart';
import 'package:bracket_helper/presentation/setting/widgets/terms_of_service_dialog.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.settings, style: TST.largeTextBold.copyWith(color: CST.white)),
        backgroundColor: CST.primary100,
        foregroundColor: CST.white,
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          SectionTitle(title: AppStrings.displaySection),
          SettingItemWithBeta(
            icon: Icons.brightness_6,
            title: AppStrings.themeSettings,
            subtitle: AppStrings.themeOptions,
            trailing: const ThemeDropdown(
              onChanged: null, // 테마 변경 기능 구현 시 추가
            ),
          ),
          SettingItemWithBeta(
            icon: Icons.language,
            title: AppStrings.languageSettings,
            subtitle: AppStrings.languageOptions,
            trailing: const LanguageDropdown(
              onChanged: null, // 언어 변경 기능 구현 시 추가
            ),
          ),
          SectionTitle(title: AppStrings.appInfoSection),
          SettingItem(
            icon: Icons.info_outline,
            title: AppStrings.appVersion,
            subtitle: AppStrings.currentVersion,
          ),
          SettingItemWithBeta(
            icon: Icons.update,
            title: AppStrings.checkForUpdates,
            onTap: () {
              // 업데이트 확인 기능 구현
            },
          ),
          SectionTitle(title: AppStrings.customerSupportSection),
          SettingItem(
            icon: Icons.email_outlined,
            title: AppStrings.inquiryAndFeedback,
            subtitle: AppStrings.inquirySubtitle,
            onTap: () => EmailFeedbackLauncher.launch(context),
          ),
          SettingItemWithBeta(
            icon: Icons.star_outline,
            title: AppStrings.rateUs,
            subtitle: AppStrings.rateUsSubtitle,
            onTap: () {
              // 평가하기 기능 구현
            },
          ),
          SectionTitle(title: AppStrings.otherSection),
          SettingItem(
            icon: Icons.code,
            title: AppStrings.developerInfo,
            onTap: () => DeveloperInfoBottomSheet.show(context),
          ),
          SettingItem(
            icon: Icons.people_outline,
            title: AppStrings.thanksFor,
            onTap: () => ContributorsDialog.show(context),
          ),
          SettingItem(
            icon: Icons.policy_outlined,
            title: AppStrings.privacyPolicy,
            onTap: () => PrivacyPolicyDialog.show(context),
          ),
          SettingItem(
            icon: Icons.description_outlined,
            title: AppStrings.termsOfService,
            onTap: () => TermsOfServiceDialog.show(context),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.only(bottom: 24),
            alignment: Alignment.center,
            child: Text(
              AppStrings.copyright,
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
