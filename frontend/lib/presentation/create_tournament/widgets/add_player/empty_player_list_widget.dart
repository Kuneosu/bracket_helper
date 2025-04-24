import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

/// 선수 목록이 비어있을 때 표시되는 위젯
class EmptyPlayerListWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;
  
  const EmptyPlayerListWidget({
    super.key, 
    this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Icon(icon ?? Icons.people_outline, size: 64, color: CST.gray3),
              SizedBox(height: 16),
              Text(
                message ?? '아직 추가된 선수가 없습니다',
                style: TST.mediumTextRegular.copyWith(color: CST.gray2),
              ),
              SizedBox(height: 8),
              Text(
                '위 입력창에 이름을 입력하거나\n저장된 선수 탭에서 선수를 추가하세요',
                textAlign: TextAlign.center,
                style: TST.smallTextRegular.copyWith(color: CST.gray3),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
} 