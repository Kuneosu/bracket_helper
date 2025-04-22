import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/square_icon_menu.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/presentation/save_player/components/empty_state_widget.dart';
import 'package:bracket_helper/presentation/save_player/components/group_grid_item.dart';
import 'package:bracket_helper/presentation/save_player/components/group_list_item.dart';
import 'package:bracket_helper/presentation/save_player/components/rename_dialog.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

class GroupListScreen extends StatefulWidget {
  final List<GroupModel> groups;
  final bool isEditMode;
  final bool isGridView;
  final String searchQuery;
  final Function(SavePlayerAction) onAction;
  final Function(int) getPlayerCount;

  const GroupListScreen({
    super.key,
    required this.groups,
    this.isEditMode = false,
    required this.isGridView,
    required this.searchQuery,
    required this.onAction,
    required this.getPlayerCount,
  });

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // 검색어 컨트롤러 초기화
    _searchController = TextEditingController(text: widget.searchQuery);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(GroupListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      // 외부에서 검색어가 변경되면 컨트롤러도 업데이트
      _searchController.text = widget.searchQuery;
    }
  }

  void _onSearchChanged() {
    // 사용자가 검색어를 입력할 때마다 콜백 호출
    widget.onAction(SavePlayerAction.onSearchQueryChanged(_searchController.text));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // 새로고침 함수
  Future<void> _handleRefresh() async {
    debugPrint('GroupListScreen - 화면 새로고침 시작');
    widget.onAction(SavePlayerAction.onRefresh());
    // 새로고침이 완료됐다고 간주하기 위해 잠시 대기
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('GroupListScreen - 화면 새로고침 완료');
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    // 검색어에 따라 필터링된 그룹 목록
    final filteredGroups =
        widget.searchQuery.isEmpty
            ? widget.groups
            : widget.groups
                .where(
                  (group) => group.name.toLowerCase().contains(
                    widget.searchQuery.toLowerCase(),
                  ),
                )
                .toList();

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 메뉴 버튼들
            FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.2),
                  end: Offset.zero,
                ).animate(_animation),
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (!widget.isEditMode)
                          SquareIconMenu(
                            title: '그룹 생성',
                            imagePath: 'assets/image/add.png',
                            width: 160, // 너비 조정
                            onTap: () {
                              context.push(
                                '${RoutePaths.savePlayer}${RoutePaths.createGroup}',
                              );
                            },
                          ),
                        if (!widget.isEditMode) const SizedBox(width: 20),
                        if (!widget.isEditMode)
                          SquareIconMenu(
                            title: '관리',
                            imagePath: 'assets/image/setting.png',
                            width: 160, // 너비 조정
                            onTap: () {
                              widget.onAction(SavePlayerAction.onToggleEditMode());
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 헤더 영역 (검색바, 보기 방식 전환 버튼)
            FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_animation),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '그룹 목록 (${filteredGroups.length})',
                          style: TST.mediumTextBold,
                        ),
                        const Spacer(),

                        // 리스트/그리드 뷰 전환 버튼 - 편집 모드에서는 표시하지 않음
                        if (!widget.isEditMode)
                          IconButton(
                            icon: Icon(
                              widget.isGridView
                                  ? Icons.view_list
                                  : Icons.grid_view,
                              color: CST.primary100,
                            ),
                            onPressed: () {
                              widget.onAction(SavePlayerAction.onToggleGridView());
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 검색 입력 필드
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: CST.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: CST.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: '그룹 검색...',
                          hintStyle: TST.smallTextRegular.copyWith(
                            color: CST.gray3,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: CST.gray2,
                          ),
                          suffixIcon:
                              widget.searchQuery.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: CST.gray2,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      // 검색어 지우기 버튼 클릭 시 콜백 명시적 호출
                                      widget.onAction(SavePlayerAction.onSearchQueryChanged(''));
                                    },
                                  )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (query) {
                          widget.onAction(SavePlayerAction.onSearchQueryChanged(query));
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 그룹 목록 (그리드 또는 리스트)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: CST.primary100,
                child: filteredGroups.isEmpty
                    ? _buildEmptyStateWithScrollView()
                    : widget.isEditMode
                    ? _buildListView(filteredGroups) // 편집 모드에서는 항상 리스트뷰
                    : widget.isGridView
                    ? _buildGridView(filteredGroups)
                    : _buildListView(filteredGroups),
              ),
            ),

            // 편집 모드일 때 저장 버튼
            if (widget.isEditMode)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                child: DefaultButton(
                  text: '변경사항 저장',
                  onTap: () {
                    widget.onAction(SavePlayerAction.onToggleEditMode());
                  },
                  height: 50,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.group_off,
      title: '검색 결과가 없습니다',
      message: '다른 검색어를 입력하거나 그룹을 생성해보세요',
    );
  }

  // RefreshIndicator가 작동하기 위해 스크롤 가능한 빈 상태 위젯
  Widget _buildEmptyStateWithScrollView() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: _buildEmptyState(),
        ),
      ),
    );
  }

  Widget _buildListView(List<GroupModel> groups) {
    return AnimationLimiter(
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final playerCount = widget.getPlayerCount(group.id);
          debugPrint(
            'GroupListScreen - 그룹 ${group.id}(${group.name}): 선수 $playerCount명 표시',
          );

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: GroupListItem(
                  group: group,
                  playerCount: playerCount,
                  onTap: () {
                    // 그룹 ID 선택하고 상세 화면으로 이동
                    widget.onAction(SavePlayerAction.onSelectGroup(group.id));
                    debugPrint(
                      'GroupListScreen - 그룹 선택 후 화면 이동: ID=${group.id}, 이름=${group.name}',
                    );
                    // 약간의 지연 후 화면 이동 (상태 업데이트 시간 확보)
                    Future.microtask(() {
                      if (context.mounted) {
                        context.push(
                          '${RoutePaths.savePlayer}/group-detail/${group.id}',
                        );
                      }
                    });
                  },
                  onRemoveTap: () {
                    widget.onAction(SavePlayerAction.onDeleteGroup(group.id));
                  },
                  onRename: (newName) {
                    // 그룹 이름 변경 처리
                    _showRenameConfirmation(context, group.id, newName);
                  },
                  onUpdateColor: (color) {
                    // 그룹 색상 변경 처리
                    widget.onAction(
                      SavePlayerAction.onUpdateGroup(
                        groupId: group.id,
                        newName: null,
                        newColor: color,
                      ),
                    );
                  },
                  isEditMode: widget.isEditMode,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 이름 변경 확인 다이얼로그 표시
  void _showRenameConfirmation(
    BuildContext context,
    int groupId,
    String newName,
  ) {
    // build 단계에서 호출될 경우 microtask로 지연시켜 실행
    Future.microtask(() {
      if (!context.mounted) return;

      GroupRenameDialog.show(
        context,
        newName: newName,
        onConfirm: (confirmedName) {
          debugPrint('그룹 이름 변경: $groupId => $confirmedName');
          widget.onAction(
            SavePlayerAction.onUpdateGroup(
              groupId: groupId,
              newName: confirmedName,
              newColor: null,
            ),
          );
        },
      );
    });
  }

  Widget _buildGridView(List<GroupModel> groups) {
    return AnimationLimiter(
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 375),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(child: _buildGridItem(group)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridItem(GroupModel group) {
    final playerCount = widget.getPlayerCount(group.id);
    debugPrint(
      'GroupListScreen(Grid) - 그룹 ${group.id}(${group.name}): 선수 $playerCount명 표시',
    );

    return GroupGridItem(
      group: group,
      playerCount: playerCount,
      onTap: () {
        // 그룹 ID 선택하고 상세 화면으로 이동
        widget.onAction(SavePlayerAction.onSelectGroup(group.id));
        debugPrint(
          'GroupListScreen - 그룹 선택 후 화면 이동: ID=${group.id}, 이름=${group.name}',
        );
        // 약간의 지연 후 화면 이동 (상태 업데이트 시간 확보)
        Future.microtask(() {
          if (context.mounted) {
            context.push('${RoutePaths.savePlayer}/group-detail/${group.id}');
          }
        });
      },
    );
  }
}
