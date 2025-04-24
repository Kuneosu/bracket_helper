import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/presentation/setting/widgets/contributor_item.dart';

class ContributorsDialog extends StatelessWidget {
  const ContributorsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더 부분
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: CST.primary100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                'Thanks for',
                style: TST.mediumTextBold.copyWith(color: CST.white),
              ),
            ),
          ),

          // 컨텐츠 부분 - 스크롤 가능하도록 수정
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  children: const [
                    ContributorItem(name: '하은이아빠', role: '앱 피드백'),
                    ContributorItem(name: '최은미', role: '앱 피드백'),
                    ContributorItem(name: '송치혁', role: '앱 피드백'),
                    ContributorItem(name: '김봉준', role: '앱 피드백'),
                    ContributorItem(name: '조소희', role: '앱 피드백'),
                    ContributorItem(name: '김정수', role: '앱 피드백'),
                    ContributorItem(name: '김지연', role: '앱 피드백'),
                    ContributorItem(name: '마코클럽', role: '앱 피드백'),
                  ],
                ),
              ),
            ),
          ),

          // 버튼 부분
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: CST.gray4, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: CST.primary20,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '닫기',
                      style: TST.normalTextBold.copyWith(color: CST.primary100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ContributorsDialog(),
    );
  }
}
