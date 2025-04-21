// ignore_for_file: constant_identifier_names

import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class AddPlayerBottomSheet extends StatefulWidget {
  final Function(CreateTournamentAction) onAction;
  final List<GroupModel> groups;
  final List<PlayerModel> players;
  // 그룹별 선수 목록 조회 함수
  final List<PlayerModel> Function(int groupId) getPlayersInGroup;

  const AddPlayerBottomSheet({
    super.key,
    required this.onAction,
    required this.groups,
    required this.players,
    required this.getPlayersInGroup,
  });

  @override
  State<AddPlayerBottomSheet> createState() => _AddPlayerBottomSheetState();
}

class _AddPlayerBottomSheetState extends State<AddPlayerBottomSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = false;
  int? _selectedGroupId;
  final Map<int, bool> _selectedPlayers = {};
  bool _isLoadingPlayers = false;
  String? _errorMessage;

  // 모든 그룹을 선택했을 때 사용할 상수
  static const int ALL_GROUPS = -999;

  // 탭 컨트롤러
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
    _tabController = TabController(length: 2, vsync: this);

    // 탭 변경 이벤트 리스너 추가
    _tabController.addListener(_handleTabChange);

    debugPrint('AddPlayerBottomSheet - 초기화: 저장된 그룹 수 ${widget.groups.length}개');

    // 그룹 목록이 이미 로드되어 있고 비어있지 않다면 추가 로드 필요 없음
    if (widget.groups.isEmpty) {
      _loadAllGroups();
    } else {
      // 기본값으로 전체 그룹 선택
      _selectedGroupId = ALL_GROUPS;
      // 전체 그룹 선수 로드
      _loadAllPlayersFromAllGroups();
    }
  }

  // 탭 변경 시 처리 함수
  void _handleTabChange() {
    // '저장된 선수' 탭(인덱스 1)으로 변경되었을 때 필요시 그룹 목록 다시 로드
    if (_tabController.index == 1 && widget.groups.isEmpty) {
      debugPrint('저장된 선수 탭 선택됨 - 그룹 목록이 비어있어 새로고침');
      _loadAllGroups();
    }
  }

  // 모든 그룹 목록 불러오기
  void _loadAllGroups() {
    debugPrint('모든 그룹 목록 로드 시작');
    // Future로 래핑하여 빌드 중 상태 변경 방지
    Future(() {
      widget.onAction(const CreateTournamentAction.fetchAllGroups());
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _isNameValid = _nameController.text.trim().isNotEmpty;
    });
  }

  void _addPlayer() {
    if (!_isNameValid) return;

    final input = _nameController.text.trim();
    final names = input.split(' ').where((name) => name.isNotEmpty).toList();

    // 각 이름마다 addPlayer 액션 호출
    for (final name in names) {
      widget.onAction(CreateTournamentAction.addPlayer(name));
    }

    // 피드백 메시지 표시
    if (names.length > 1) {
      // 바텀시트를 닫기 전에 스낵바 표시를 위해 컨텍스트 저장
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      Navigator.pop(context); // 바텀시트 닫기

      // 추가된 선수 수 표시
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${names.length}명의 선수가 추가되었습니다.'),
          backgroundColor: CST.black,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      Navigator.pop(context); // 바텀시트 닫기
    }
  }

  // 특정 그룹의 선수 목록을 로드합니다
  Future<void> _loadPlayersFromGroup(int groupId) async {
    debugPrint('선수 목록 로드 시작: 그룹 ID $groupId');

    // 에러 메시지 초기화 및 로딩 상태 설정
    setState(() {
      _selectedGroupId = groupId;
      _selectedPlayers.clear(); // 선택된 선수 목록 초기화
      _isLoadingPlayers = true;
      _errorMessage = null;
    });

    try {
      // 로딩 액션은 Future로 래핑하여 빌드 중 상태 변경 방지
      await Future(() {
        widget.onAction(CreateTournamentAction.loadPlayersFromGroup(groupId));
      });

      // 액션 처리 및 데이터 로드 완료를 위한 짧은 지연
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        // 데이터가 로드되었는지 확인
        final players = widget.getPlayersInGroup(groupId);
        debugPrint('선수 목록 로드 완료: ${players.length}명 가져옴');

        setState(() {
          _isLoadingPlayers = false;
          if (players.isEmpty) {
            _errorMessage = '이 그룹에는 선수가 없습니다.';
          }
        });
      }
    } catch (e) {
      debugPrint('선수 목록 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoadingPlayers = false;
          _errorMessage = '선수 목록을 불러오는 중 오류가 발생했습니다.';
        });
      }
    }
  }

  // 모든 그룹의 선수 목록을 로드합니다
  Future<void> _loadAllPlayersFromAllGroups() async {
    debugPrint('모든 그룹의 선수 목록 로드 시작');

    // 에러 메시지 초기화 및 로딩 상태 설정
    setState(() {
      _selectedGroupId = ALL_GROUPS;
      _selectedPlayers.clear(); // 선택된 선수 목록 초기화
      _isLoadingPlayers = true;
      _errorMessage = null;
    });

    try {
      // 각 그룹의 선수 목록을 로드하기 위해 각 그룹에 대한 액션 실행
      for (final group in widget.groups) {
        if (!mounted) return;

        // 로딩 액션은 Future로 래핑하여 빌드 중 상태 변경 방지
        await Future(() {
          widget.onAction(
            CreateTournamentAction.loadPlayersFromGroup(group.id),
          );
        });
      }

      // 약간의 지연 후 로딩 상태 업데이트
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        setState(() {
          _isLoadingPlayers = false;
        });
      }
    } catch (e) {
      debugPrint('모든 그룹의 선수 목록 로드 중 오류: $e');
      if (mounted) {
        setState(() {
          _isLoadingPlayers = false;
          _errorMessage = '선수 목록을 불러오는 중 오류가 발생했습니다.';
        });
      }
    }
  }

  // 선수 선택 상태를 토글합니다
  void _togglePlayerSelection(PlayerModel player) {
    setState(() {
      if (_selectedPlayers.containsKey(player.id)) {
        _selectedPlayers.remove(player.id);
      } else {
        _selectedPlayers[player.id] = true;
      }
    });
  }

  // 선택된 선수들을 추가합니다
  void _addSelectedPlayers() {
    if (_selectedPlayers.isEmpty) return;

    // 선택된 선수들만 추가
    for (final playerId in _selectedPlayers.keys) {
      // 현재 선택된 그룹에서 해당 ID를 가진 선수 찾기
      final playerList = _getPlayersInSelectedGroup();
      final player = playerList.firstWhere(
        (p) => p.id == playerId,
        orElse: () => PlayerModel(id: -1, name: ''),
      );

      if (player.id != -1) {
        widget.onAction(CreateTournamentAction.selectPlayerFromGroup(player));
      }
    }

    // 피드백 메시지를 위해 컨텍스트 저장
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final selectedCount = _selectedPlayers.length;

    Navigator.pop(context);

    // 추가된 선수 수 표시
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('$selectedCount명의 선수가 추가되었습니다.'),
        backgroundColor: CST.primary100,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 바텀시트 핸들 (드래그 표시)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 상단 제목과 닫기 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person_add, color: CST.primary100, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '선수 추가하기',
                    style: TST.largeTextBold.copyWith(color: Colors.black),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: CST.gray2),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 탭 컨트롤러
          Container(
            decoration: BoxDecoration(
              color: CST.primary20,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: TabBar(
              controller: _tabController,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 16),
                      const SizedBox(width: 4),
                      const Text('직접 입력'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group, size: 16),
                      const SizedBox(width: 4),
                      const Text('저장된 선수'),
                    ],
                  ),
                ),
              ],
              labelColor: CST.primary100,
              unselectedLabelColor: CST.gray2,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 탭 내용
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4, // 높이 조정
            child: TabBarView(
              controller: _tabController,
              children: [
                // 직접 입력 탭
                _buildDirectInputTab(),

                // 저장된 선수 탭
                _buildSavedPlayersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 직접 입력 탭 내용
  Widget _buildDirectInputTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 이름 입력 필드
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: '선수 이름',
            hintText: '선수 이름 입력',
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            labelStyle: TextStyle(color: CST.gray2),
            floatingLabelStyle: TextStyle(
              color: CST.primary100,
              fontWeight: FontWeight.bold,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: CST.gray4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: CST.primary100, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: CST.gray4),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            isDense: false,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: Icon(Icons.person_outline, color: CST.primary80),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // 여러 선수 입력 안내 텍스트
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 14, color: CST.gray2),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '여러 선수는 공백으로 구분해서 입력할 수 있습니다. (예: 홍길동 김철수)',
                  style: TextStyle(fontSize: 12, color: CST.gray2),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // 추가 버튼
        _isNameValid
            ? DefaultButton(
              text: '추가하기',
              onTap: _addPlayer,
              color: CST.primary100,
              textStyle: TST.normalTextBold.copyWith(color: Colors.white),
              height: 50,
            )
            : DefaultButton(
              text: '추가하기',
              onTap: () {}, // 빈 함수
              color: CST.gray3,
              textStyle: TST.normalTextBold.copyWith(color: Colors.white),
              height: 50,
            ),
      ],
    );
  }

  // 저장된 선수 탭 내용
  Widget _buildSavedPlayersTab() {
    final hasGroups = widget.groups.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 그룹 선택 드롭다운
        hasGroups
            ? DropdownButtonFormField<int?>(
              value: _selectedGroupId,
              hint: Row(
                children: [
                  Icon(Icons.group_outlined, size: 16, color: CST.gray2),
                  const SizedBox(width: 8),
                  Text('그룹 선택', style: TextStyle(color: CST.gray2)),
                ],
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CST.gray4),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CST.gray4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: CST.primary100, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                isDense: false,
                filled: true,
                fillColor: Colors.white,
              ),
              iconSize: 30,
              icon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Icon(Icons.arrow_drop_down, color: CST.primary100),
              ),
              dropdownColor: Colors.white,
              elevation: 3,
              isExpanded: true,
              borderRadius: BorderRadius.circular(12),
              items: [
                // 전체 그룹 옵션
                DropdownMenuItem<int?>(
                  value: ALL_GROUPS,
                  child: Row(
                    children: [
                      Icon(Icons.group_outlined, size: 16, color: CST.gray2),
                      const SizedBox(width: 8),
                      Text('그룹 전체', style: TextStyle(color: CST.gray2)),
                    ],
                  ),
                ),
                // 각 그룹별 옵션
                ...widget.groups.map(
                  (group) => DropdownMenuItem<int?>(
                    value: group.id,
                    child: Row(
                      children: [
                        Icon(Icons.group, size: 16, color: CST.primary100),
                        const SizedBox(width: 8),
                        Text(
                          group.name,
                          style: TextStyle(
                            color: CST.gray1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              onChanged: (groupId) {
                if (groupId == ALL_GROUPS) {
                  // 전체 그룹 선택 시 모든 그룹의 선수 목록 로드
                  _loadAllPlayersFromAllGroups();
                } else if (groupId != null) {
                  // 특정 그룹 선택 시 해당 그룹의 선수 목록 로드
                  _loadPlayersFromGroup(groupId);
                } else {
                  // 그룹 선택 해제 시 처리
                  setState(() {
                    _selectedGroupId = null;
                    _selectedPlayers.clear();
                    _errorMessage = null;
                  });
                }
              },
            )
            : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: CST.gray4),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sync, size: 16, color: CST.gray3),
                      const SizedBox(width: 8),
                      Text('그룹 목록 로드 중...', style: TextStyle(color: CST.gray3)),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(CST.primary100),
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 16),

        // 선수 목록
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: CST.primary20,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CST.gray4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  hasGroups
                      ? _buildPlayerListContent()
                      : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.group_off, size: 48, color: CST.gray3),
                            const SizedBox(height: 8),
                            Text(
                              '저장된 그룹이 없습니다.\n그룹을 먼저 생성해주세요.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: CST.gray2),
                            ),
                          ],
                        ),
                      ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 선택된 선수 추가 버튼
        _selectedPlayers.isNotEmpty
            ? DefaultButton(
              text: '선택한 선수 추가하기 (${_selectedPlayers.length}명)',
              onTap: _addSelectedPlayers,
              color: CST.primary100,
              textStyle: TST.normalTextBold.copyWith(color: Colors.white),
              height: 50,
            )
            : DefaultButton(
              text: '선택한 선수 추가하기 (0명)',
              onTap: () {}, // 빈 함수
              color: CST.gray3,
              textStyle: TST.normalTextBold.copyWith(color: Colors.white),
              height: 50,
            ),
      ],
    );
  }

  // 선수 목록 내용 위젯
  Widget _buildPlayerListContent() {
    // 로딩 중이면 로딩 인디케이터 표시
    if (_isLoadingPlayers) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CST.primary100),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text('선수 목록을 불러오는 중입니다...', style: TextStyle(color: CST.gray2)),
          ],
        ),
      );
    }

    // 에러 메시지가 있으면 표시
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: CST.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: CST.gray2),
            ),
          ],
        ),
      );
    }

    // 그룹 선택 안 했으면 안내 메시지
    if (_selectedGroupId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app, size: 40, color: CST.primary60),
            const SizedBox(height: 16),
            Text('위에서 그룹을 선택하세요', style: TextStyle(color: CST.gray2)),
          ],
        ),
      );
    }

    // 선택한 그룹의 선수 목록 가져오기
    final playersInGroup = _getPlayersInSelectedGroup();

    // 선수가 없으면 안내 메시지
    if (playersInGroup.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off, size: 40, color: CST.gray3),
            const SizedBox(height: 16),
            Text('이 그룹에는 선수가 없습니다.', style: TextStyle(color: CST.gray2)),
          ],
        ),
      );
    }

    // 선수 목록 표시
    return ListView.separated(
      itemCount: playersInGroup.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: CST.gray4.withValues(alpha: 0.5),
          ),
      itemBuilder: (context, index) {
        final player = playersInGroup[index];
        final isSelected = _selectedPlayers.containsKey(player.id);

        // 이미 대회에 추가된 선수인지 확인
        final isAlreadyAdded = widget.players.any((p) => p.id == player.id);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            player.name,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isAlreadyAdded ? CST.gray3 : CST.gray1,
            ),
          ),
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? CST.primary100 : Colors.transparent,
              border: Border.all(
                color:
                    isAlreadyAdded
                        ? CST.gray3
                        : isSelected
                        ? CST.primary100
                        : CST.gray2,
                width: 2,
              ),
            ),
            child:
                isSelected
                    ? Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
          ),
          enabled: !isAlreadyAdded,
          subtitle:
              isAlreadyAdded
                  ? Row(
                    children: [
                      Icon(Icons.info_outline, size: 12, color: CST.gray3),
                      const SizedBox(width: 4),
                      Text(
                        '이미 추가됨',
                        style: TextStyle(color: CST.gray3, fontSize: 12),
                      ),
                    ],
                  )
                  : null,
          tileColor: isSelected ? CST.primary20 : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onTap: isAlreadyAdded ? null : () => _togglePlayerSelection(player),
        );
      },
    );
  }

  // 현재 선택된 그룹의 선수 목록을 가져오는 헬퍼 메서드
  List<PlayerModel> _getPlayersInSelectedGroup() {
    if (_selectedGroupId == null) return [];

    // 전체 그룹 선택 시 모든 그룹의 선수 목록 병합하여 반환
    if (_selectedGroupId == ALL_GROUPS) {
      final allPlayers = <PlayerModel>[];
      final seenPlayerIds = <int>{}; // 중복 제거용 집합

      // 모든 그룹에서 선수 목록 가져오기
      for (final group in widget.groups) {
        final playersInGroup = widget.getPlayersInGroup(group.id);

        // 중복 선수 제거 (같은 선수가 여러 그룹에 속할 수 있음)
        for (final player in playersInGroup) {
          if (!seenPlayerIds.contains(player.id)) {
            allPlayers.add(player);
            seenPlayerIds.add(player.id);
          }
        }
      }

      debugPrint('모든 그룹의 선수 목록: ${allPlayers.length}명');
      return allPlayers;
    }

    // 특정 그룹 선택 시 해당 그룹의 선수 목록 반환
    final players = widget.getPlayersInGroup(_selectedGroupId!);
    debugPrint('선택된 그룹($_selectedGroupId)의 선수 목록: ${players.length}명');
    return players;
  }
}
