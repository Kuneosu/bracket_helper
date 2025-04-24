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
                  '도움말',
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 도움말 내용
            Text(
              '대진 도우미는 배드민턴·탁구·테니스 등 생활 체육 동호회나 학교·사내 친선전을 쉽고 빠르게 운영할 수 있도록 돕는 모바일 앱입니다.',
              style: TST.smallTextRegular.copyWith(color: CST.gray1),
            ),
            const SizedBox(height: 15),

            Text('주요 기능:', style: TST.smallTextBold.copyWith(color: CST.gray1)),
            const SizedBox(height: 8),

            _buildFeatureItem('복식/단식 대진표 자동 생성'),
            _buildFeatureItem('승/무/패 점수 설정'),
            _buildFeatureItem('경기 진행 현황 관리'),
            _buildFeatureItem('대진표 공유'),

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
                  '확인',
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
