import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class EmptyPlayerList extends StatelessWidget {
  final VoidCallback onAddPlayerTap;

  const EmptyPlayerList({
    super.key,
    required this.onAddPlayerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_outline, size: 72, color: CST.gray3),
          const SizedBox(height: 16),
          Text(
            '참가 선수를 추가해주세요',
            style: TST.mediumTextBold.copyWith(color: CST.gray3),
          ),
          const SizedBox(height: 24),
          DefaultButton(
            text: '선수 추가하기',
            onTap: onAddPlayerTap,
            width: 150,
          ),
        ],
      ),
    );
  }
} 