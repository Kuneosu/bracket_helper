import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class GroupHeaderWidget extends StatelessWidget {
  final GroupModel group;
  final int playerCount;
  final Color groupColor;
  final VoidCallback? onAddPlayer;

  const GroupHeaderWidget({
    super.key,
    required this.group,
    required this.playerCount,
    required this.groupColor,
    this.onAddPlayer,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 그룹 아이콘
        CircleAvatar(
          backgroundColor: groupColor.withValues(alpha: 0.2),
          radius: 40,
          child: Icon(Icons.group, size: 40, color: groupColor),
        ),
        const SizedBox(width: 16),

        // 그룹 이름과 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                style: TST.mediumTextBold.copyWith(
                  fontSize: 22,
                  color: groupColor,
                ),
              ),
              Text(
                '소속 선수: $playerCount명',
                style: TST.smallTextRegular.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // 선수 추가 버튼
        if (onAddPlayer != null)
          ElevatedButton.icon(
            onPressed: onAddPlayer,
            icon: const Icon(Icons.person_add),
            label: const Text('선수 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: groupColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
      ],
    );
  }
}
