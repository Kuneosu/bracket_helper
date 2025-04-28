import 'package:bracket_helper/domain/model/group_model.dart';
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
  bool _resumedFromBackground = false;

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
      _resumedFromBackground = true;
      debugPrint('GroupListRoot - 앱이 포그라운드로 돌아옴: 데이터 새로고침 플래그 설정');
    }
  }
  
  @override
  void didUpdateWidget(GroupListRoot oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 배경에서 돌아온 후 첫 업데이트에서 강제 새로고침
    if (_resumedFromBackground) {
      debugPrint('GroupListRoot - 백그라운드에서 복귀 후 첫 업데이트: 데이터 새로고침');
      _resumedFromBackground = false;
      _refreshData();
      return;
    }
    
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

 

  @override
  Widget build(BuildContext context) {
    // 화면 재구성 시 항상 최신 데이터 확인
    if (_resumedFromBackground) {
      debugPrint('GroupListRoot - build: 백그라운드에서 돌아옴, 데이터 새로고침');
      _resumedFromBackground = false;
      Future.microtask(() => _refreshData());
    }
    
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final filteredGroups = widget.viewModel.state.filteredGroups;
        final isGridView = widget.viewModel.state.isGridView;
        final isEditMode = widget.viewModel.state.isEditMode;
        final searchQuery = widget.viewModel.state.searchQuery;
        
        debugPrint('GroupListRoot - build: 필터링된 그룹 개수 ${filteredGroups.length}');
        
        return GroupListScreen(
          groups: filteredGroups,
          isGridView: isGridView,
          isEditMode: isEditMode,
          searchQuery: searchQuery,
          onAction: widget.viewModel.onAction,
          getPlayerCount: widget.viewModel.getPlayerCountSync,
          getMatchedPlayerNames: (groupId) => 
              widget.viewModel.state.matchedPlayerNamesByGroup[groupId] ?? [],
        );
      },
    );
  }
}
