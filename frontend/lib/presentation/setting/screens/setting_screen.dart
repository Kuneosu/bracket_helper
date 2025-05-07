import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/presentation/setting/widgets/setting_item.dart';
import 'package:bracket_helper/presentation/setting/widgets/section_title.dart';
import 'package:bracket_helper/presentation/setting/widgets/developer_info_bottom_sheet.dart';
import 'package:bracket_helper/presentation/setting/widgets/contributors_dialog.dart';
import 'package:bracket_helper/presentation/setting/widgets/email_feedback_launcher.dart';
import 'package:bracket_helper/presentation/setting/widgets/privacy_policy_dialog.dart';
import 'package:bracket_helper/presentation/setting/widgets/terms_of_service_dialog.dart';
import 'package:bracket_helper/presentation/setting/widgets/language_dropdown.dart';
import 'package:bracket_helper/core/services/language_service.dart';
import 'package:in_app_review/in_app_review.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  void _onLanguageChanged(String? language) {
    // 언어 변경 후 현재 화면 UI를 먼저 갱신
    setState(() {});

    // 앱 전체 UI를 새로고침하기 위한 처리
    // 더 빠른 응답을 위해 지연 시간 감소
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        LanguageService.refreshApp(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.settings,
          style: TST.largeTextBold.copyWith(color: CST.white),
        ),
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
          // SettingItemWithBeta(
          //   icon: Icons.brightness_6,
          //   title: AppStrings.themeSettings,
          //   subtitle: AppStrings.themeOptions,
          //   trailing: const ThemeDropdown(
          //     onChanged: null, // 테마 변경 기능 구현 시 추가
          //   ),
          // ),
          SettingItem(
            icon: Icons.language,
            title: AppStrings.languageSettings,
            subtitle: AppStrings.languageOptions,
            trailing: LanguageDropdown(onChanged: _onLanguageChanged),
          ),
          SectionTitle(title: AppStrings.appInfoSection),
          SettingItem(
            icon: Icons.info_outline,
            title: AppStrings.appVersion,
            subtitle: AppStrings.currentVersion,
          ),
          SettingItem(
            icon: Icons.update,
            title: AppStrings.checkForUpdates,
            subtitle: AppStrings.checkForUpdatesSubtitle,
            onTap: () async {
              try {
                final Uri url =
                    Platform.isIOS
                        ? Uri.parse(
                          'https://apps.apple.com/app/id6745153734',
                        ) // iOS 앱스토어 ID
                        : Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.kuneosu.bracket_helper',
                        ); // 패키지명 기준

                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppStrings.storeOpenError)),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.storeOpenError)),
                  );
                }
              }
            },
          ),
          SectionTitle(title: AppStrings.customerSupportSection),
          SettingItem(
            icon: Icons.email_outlined,
            title: AppStrings.inquiryAndFeedback,
            subtitle: AppStrings.inquirySubtitle,
            onTap: () => EmailFeedbackLauncher.launch(context),
          ),
          SettingItem(
            icon: Icons.star_outline,
            title: AppStrings.rateUs,
            subtitle: AppStrings.rateUsSubtitle,
            onTap: () async {
              final InAppReview inAppReview = InAppReview.instance;
              try {
                if (await inAppReview.isAvailable()) {
                  await inAppReview.requestReview();
                } else {
                  await inAppReview.openStoreListing();
                }
              } catch (e) {
                // 시뮬레이터에서 발생하는 예외 처리
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.storeOpenError)),
                  );
                }
              }
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
