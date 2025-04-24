import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/presentation/setting/widget/social_icon.dart';
import 'package:bracket_helper/presentation/setting/widget/email_feedback_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperInfoBottomSheet extends StatelessWidget {
  const DeveloperInfoBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('개발자 정보', style: TST.mediumTextBold),
          const SizedBox(height: 16),
          const CircleAvatar(
            radius: 40,
            backgroundColor: CST.primary40,
            child: Icon(Icons.person, size: 40, color: CST.primary100),
          ),
          const SizedBox(height: 16),
          Text('김권수(Kuneosu)', style: TST.normalTextBold),
          const SizedBox(height: 8),
          Text(
            '대진표 도우미 앱을 개발한 개발자입니다.\n문의나 피드백은 언제든지 환영합니다.',
            style: TST.smallTextRegular.copyWith(color: CST.gray2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SocialIcon(
                icon: Icons.email,
                onTap: () => EmailFeedbackLauncher.launch(context),
              ),
              const SizedBox(width: 16),
              SocialIcon(
                icon: Icons.public,
                onTap: () => _launchWebsite(context, 'https://kimkwonsu.notion.site/'),
              ),
              const SizedBox(width: 16),
              SocialIcon(
                icon: Icons.code,
                onTap: () => _launchWebsite(context, 'https://github.com/kuneosu'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 웹사이트 실행 메서드
  Future<void> _launchWebsite(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, '웹사이트를 열 수 없습니다.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, '오류가 발생했습니다: $e');
      }
    }
  }

  // 스낵바 표시 헬퍼 함수
  void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
    }
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const DeveloperInfoBottomSheet(),
    );
  }
}
