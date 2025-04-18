import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/square_icon_menu.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/presentation/save_player/components/empty_state_widget.dart';
import 'package:bracket_helper/presentation/save_player/components/group_grid_item.dart';
import 'package:bracket_helper/presentation/save_player/components/group_list_item.dart';
import 'package:bracket_helper/presentation/save_player/components/rename_dialog.dart';
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
  final Function(String) onSearchChanged;
  final VoidCallback onToggleView;
  final VoidCallback onToggleEditMode;
  final Function(int) onDeleteGroup;
  final Function(int, String?) onUpdateGroup;
  final Function(int, Color) onUpdateColor;
  final Function(int) getPlayerCount;

  const GroupListScreen({
    super.key,
    required this.groups,
    this.isEditMode = false,
    required this.isGridView,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onToggleView,
    required this.onToggleEditMode,
    required this.onDeleteGroup,
    required this.onUpdateGroup,
    required this.onUpdateColor,
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
    widget.onSearchChanged(_searchController.text);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
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
                            onTap: widget.onToggleEditMode,
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
                            onPressed: widget.onToggleView,
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
                                      widget.onSearchChanged('');
                                    },
                                  )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged:
                            widget.onSearchChanged, // 직접적인 onChanged 핸들러 추가
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 그룹 목록 (그리드 또는 리스트)
            Expanded(
              child:
                  filteredGroups.isEmpty
                      ? _buildEmptyState()
                      : widget.isEditMode
                      ? _buildListView(filteredGroups) // 편집 모드에서는 항상 리스트뷰
                      : widget.isGridView
                      ? _buildGridView(filteredGroups)
                      : _buildListView(filteredGroups),
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
                  onTap: widget.onToggleEditMode,
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

  Widget _buildListView(List<GroupModel> groups) {
    return AnimationLimiter(
      child: ListView.builder(
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: GroupListItem(
                  group: group,
                  playerCount: widget.getPlayerCount(group.id),
                  onTap: () {
                    context.push(
                      '${RoutePaths.savePlayer}${RoutePaths.groupDetail}',
                    );
                  },
                  onRemoveTap: () {
                    widget.onDeleteGroup(group.id);
                  },
                  onRename: (newName) {
                    // 그룹 이름 변경 처리
                    _showRenameConfirmation(context, group.id, newName);
                  },
                  onUpdateColor: (color) {
                    // 그룹 색상 변경 처리
                    widget.onUpdateColor(group.id, color);
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
          widget.onUpdateGroup(groupId, confirmedName);
        },
      );
    });
  }

  Widget _buildGridView(List<GroupModel> groups) {
    return AnimationLimiter(
      child: GridView.builder(
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
    return GroupGridItem(
      group: group,
      playerCount: widget.getPlayerCount(group.id),
      onTap: () {
        context.push('${RoutePaths.savePlayer}${RoutePaths.groupDetail}');
      },
    );
  }
}
