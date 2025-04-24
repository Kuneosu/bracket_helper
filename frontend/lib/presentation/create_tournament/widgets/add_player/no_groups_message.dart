import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

/// 저장된 그룹이 없을 때 표시되는 메시지 위젯
class NoGroupsMessage extends StatelessWidget {
  const NoGroupsMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_off, size: 48, color: CST.gray3),
          const SizedBox(height: 12),
          Text(
            AppStrings.noGroupsMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: CST.gray2),
          ),
        ],
      ),
    );
  }
}
