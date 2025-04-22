import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

/// 선택된 선수 추가 버튼 위젯
class AddPlayerActionButton extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onTap;

  const AddPlayerActionButton({
    super.key,
    required this.selectedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: selectedCount > 0
          ? DefaultButton(
              text: '선택한 선수 추가하기 ($selectedCount명)',
              onTap: onTap,
              color: CST.primary100,
              textStyle: TST.normalTextBold.copyWith(color: Colors.white),
              height: 50,
            )
          : DefaultButton(
              text: '선택한 선수 추가하기 (0명)',
              onTap: () {}, // 빈 함수
              color: CST.gray3,
              textStyle: TST.normalTextBold.copyWith(color: Colors.white),
              height: 50,
            ),
    );
  }
} 