import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/presentation/save_player/widgets/empty_state_widget.dart';
import 'package:bracket_helper/presentation/save_player/widgets/group_grid_item.dart';
import 'package:bracket_helper/presentation/save_player/widgets/group_list_item.dart';
import 'package:bracket_helper/presentation/save_player/widgets/rename_dialog.dart';
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
  bool _isMenuExpanded = false;

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
    widget.onAction(
      SavePlayerAction.onSearchQueryChanged(_searchController.text),
    );
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
    await Future.delayed(const Duration(milliseconds: 100));
    debugPrint('GroupListScreen - 화면 새로고침 완료');
    return Future.value();
  }

  // 메뉴 상태 토글
  void _toggleMenu() {
    setState(() {
      _isMenuExpanded = !_isMenuExpanded;
    });
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

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

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
                                  widget.onAction(
                                    SavePlayerAction.onToggleGridView(),
                                  );
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
                                          widget.onAction(
                                            SavePlayerAction.onSearchQueryChanged(
                                              '',
                                            ),
                                          );
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
                              widget.onAction(
                                SavePlayerAction.onSearchQueryChanged(query),
                              );
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
                    child:
                        filteredGroups.isEmpty
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
        ),

        // 플로팅 버튼들
        if (!widget.isEditMode)
          Positioned(
            bottom: 20,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 펼쳐졌을 때만 보이는 하위 메뉴들
                if (_isMenuExpanded) ...[
                  // 관리 버튼 (순서 변경: 위로)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(30 * (1 - value), 0),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: _buildMenuItemButton(
                            icon: Icons.settings,
                            label: '관리',
                            onTap: () {
                              _toggleMenu();
                              widget.onAction(
                                SavePlayerAction.onToggleEditMode(),
                              );
                            },
                            color: CST.gray2,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // 그룹 생성 버튼 (순서 변경: 아래로)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(50 * (1 - value), 0),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: _buildMenuItemButton(
                            icon: Icons.add_circle,
                            label: '그룹 생성',
                            onTap: () {
                              _toggleMenu();
                              context.push(
                                '${RoutePaths.savePlayer}${RoutePaths.createGroup}',
                              );
                            },
                            color: CST.primary100,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                ],
                // 메인 토글 버튼
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: _isMenuExpanded ? CST.error : CST.primary100,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isMenuExpanded ? CST.error : CST.primary100)
                            .withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggleMenu,
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white.withValues(alpha: 0.2),
                      child: AnimatedRotation(
                        turns: _isMenuExpanded ? 0.125 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          _isMenuExpanded ? Icons.close : Icons.menu,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
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
        child: Center(child: _buildEmptyState()),
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
          if (mounted) {
            context.push('${RoutePaths.savePlayer}/group-detail/${group.id}');
          }
        });
      },
    );
  }

  // 플로팅 버튼 메뉴 아이템
  Widget _buildMenuItemButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: CST.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TST.normalTextBold.copyWith(
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ),
    );
  }
}
