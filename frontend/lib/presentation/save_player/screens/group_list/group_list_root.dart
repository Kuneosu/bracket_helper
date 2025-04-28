import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/presentation/save_player/save_player_view_model.dart';
import 'package:bracket_helper/presentation/save_player/screens/group_list/group_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

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

class _GroupListRootState extends State<GroupListRoot> with WidgetsBindingObserver {
  bool _isFirstLoad = true;
  int _lastGroupCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
    _lastGroupCount = widget.groups.length;
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 다시 화면에 표시될 때 데이터 새로고침
    if (state == AppLifecycleState.resumed) {
      debugPrint('GroupListRoot - 앱이 포그라운드로 돌아옴: 데이터 새로고침');
      _refreshData();
    }
  }
  
  @override
  void didUpdateWidget(GroupListRoot oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 그룹 목록 개수가 변경되었는지 체크
    if (widget.groups.length != _lastGroupCount) {
      debugPrint('GroupListRoot - 그룹 개수 변경 감지: $_lastGroupCount -> ${widget.groups.length}');
      _lastGroupCount = widget.groups.length;
      _refreshData();
      return;
    }
    
    // 그룹 목록 ID가 변경되었는지 확인
    final oldGroupIds = oldWidget.groups.map((g) => g.id).toSet();
    final newGroupIds = widget.groups.map((g) => g.id).toSet();
    
    // 그룹 목록이 변경된 경우 데이터 갱신
    if (!const SetEquality().equals(oldGroupIds, newGroupIds)) {
      debugPrint('GroupListRoot - 그룹 목록 변경 감지: 데이터 새로고침');
      _refreshData();
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 최초 로드 시에만 데이터 갱신
    if (_isFirstLoad) {
      debugPrint('GroupListRoot - 최초 화면 로드: 데이터 갱신');
      _isFirstLoad = false;
      _refreshData();
    }
  }
  
  // 모든 데이터 갱신 메서드
  void _refreshData() {
    debugPrint('GroupListRoot - _refreshData 호출됨: 현재 그룹 수=${widget.groups.length}');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 그룹 목록 새로고침
      widget.viewModel.fetchAllGroups();
      // 선수 수 갱신
      widget.viewModel.refreshPlayerCounts();
      debugPrint('GroupListRoot - 모든 데이터 새로고침 요청 완료');
    });
  }

  // 새로고침 처리 메서드
  void _handleRefresh() {
    debugPrint('GroupListRoot - 새로고침 요청 처리 시작');
    // 모든 데이터 새로고침
    widget.viewModel.refreshAllData();
    debugPrint('GroupListRoot - 새로고침 요청 처리 완료');
  }

  @override
  Widget build(BuildContext context) {
    // 상태 로깅
    debugPrint('GroupListRoot - build 호출: widget.groups=${widget.groups.length}, viewModel.state.groups=${widget.viewModel.state.groups.length}');
    
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        debugPrint('GroupListRoot - ListenableBuilder 호출: ${widget.viewModel.state.groups.length}개 그룹');
      
        // 그룹 목록 - viewModel의 filteredGroups 사용 (검색 필터링 적용)
        final filteredGroups = widget.viewModel.state.filteredGroups;
        final searchQuery = widget.viewModel.state.searchQuery;
        final isGridView = widget.viewModel.state.isGridView;
        final isEditMode = widget.viewModel.state.isEditMode;
        
        // debugPrint로 상태 로깅
        debugPrint(
          'GroupListRoot build: isGridView=$isGridView, '
          'searchQuery="$searchQuery", '
          'isEditMode=$isEditMode, '
          'groups=${widget.viewModel.state.groups.length}, '
          'filteredGroups=${filteredGroups.length}'
        );
        
        // getPlayerCount 함수 참조 - GroupListScreen으로 전달
        final getPlayerCount = widget.viewModel.getPlayerCountSync;
        
        // 검색어에 일치하는 선수 이름 가져오는 함수
        getMatchedPlayerNames(int groupId) {
          // 해당 그룹의 매치된 선수 이름 목록 반환
          return widget.viewModel.state.matchedPlayerNamesByGroup[groupId] ?? [];
        }
        
        return GroupListScreen(
          groups: filteredGroups, // viewModel의 필터링된 그룹 목록 사용
          isGridView: isGridView,
          isEditMode: isEditMode,
          searchQuery: searchQuery,
          onAction: (action) {
            // onRefresh 액션인 경우 로컬 메서드 호출
            if (action is OnRefresh) {
              _handleRefresh();
            } else {
              // 그 외 액션은 ViewModel로 전달
              widget.viewModel.onAction(action);
            }
          },
          getPlayerCount: getPlayerCount,
          getMatchedPlayerNames: getMatchedPlayerNames,
        );
      }
    );
  }
}
