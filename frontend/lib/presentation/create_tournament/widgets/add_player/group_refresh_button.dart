import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

/// 그룹 목록 새로고침 버튼 위젯
class GroupRefreshButton extends StatelessWidget {
  final Function(CreateTournamentAction) onAction;
  final VoidCallback? onRefresh;

  const GroupRefreshButton({
    super.key, 
    required this.onAction,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CST.primary40,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          debugPrint('GroupRefreshButton - 새로고침 버튼 클릭: 데이터 새로고침');
          onAction(const CreateTournamentAction.fetchAllGroups());
          
          // 추가적인 새로고침 콜백이 있다면 호출
          if (onRefresh != null) {
            onRefresh!();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CST.primary60, width: 1),
          ),
          child: Tooltip(
            message: '그룹 목록 새로고침',
            child: Icon(
              Icons.refresh_rounded,
              color: CST.primary100,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
} 