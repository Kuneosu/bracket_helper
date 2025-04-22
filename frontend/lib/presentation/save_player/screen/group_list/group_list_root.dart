import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/presentation/save_player/save_player_view_model.dart';
import 'package:bracket_helper/presentation/save_player/screen/group_list/group_list_screen.dart';
import 'package:flutter/material.dart';

class GroupListRoot extends StatefulWidget {
  final List<GroupModel> groups;
  final SavePlayerViewModel viewModel;

  const GroupListRoot({
    super.key,
    required this.groups,
    required this.viewModel,
  });

  @override
  State<GroupListRoot> createState() => _GroupListRootState();
}

class _GroupListRootState extends State<GroupListRoot> {
  @override
  void initState() {
    super.initState();
    _refreshPlayerCounts();
  }
  
  @override
  void didUpdateWidget(GroupListRoot oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 그룹 목록이 변경되었을 때에도 선수 수 갱신
    if (oldWidget.groups.length != widget.groups.length) {
      _refreshPlayerCounts();
    }
  }
  
  // 선수 수 갱신 메서드
  void _refreshPlayerCounts() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.viewModel.refreshPlayerCounts();
    });
  }

  // 새로고침 처리 메서드
  void _handleRefresh() {
    debugPrint('GroupListRoot - 새로고침 요청 처리 시작');
    // 그룹 목록 및 선수 수 갱신 요청
    widget.viewModel.fetchAllGroups();
    _refreshPlayerCounts();
    debugPrint('GroupListRoot - 새로고침 요청 처리 완료');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        debugPrint(
          'GroupListRoot rebuild: isGridView=${widget.viewModel.state.isGridView}, '
          'searchQuery="${widget.viewModel.state.searchQuery}", '
          'isEditMode=${widget.viewModel.state.isEditMode}, '
          'groups=${widget.groups.length}',
        );

        return GroupListScreen(
          groups: widget.groups,
          isGridView: widget.viewModel.state.isGridView,
          searchQuery: widget.viewModel.state.searchQuery,
          isEditMode: widget.viewModel.state.isEditMode,
          getPlayerCount: (groupId) {
            return widget.viewModel.getPlayerCountSync(groupId);
          },
          onAction: (action) {
            debugPrint('GroupListRoot - 액션 수신: $action');
            
            // onRefresh 액션인 경우 로컬 메서드 호출
            if (action is OnRefresh) {
              _handleRefresh();
            } else {
              // 그 외 액션은 ViewModel로 전달
              widget.viewModel.onAction(action);
            }
          },
        );
      },
    );
  }
}
