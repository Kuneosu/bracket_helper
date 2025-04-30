// ignore_for_file: constant_identifier_names

import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/create_partner_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/add_player/inline_editable_player_item.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/index.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PartnerAddPlayerScreen extends StatefulWidget {
  final TournamentModel tournament;
  final List<PlayerModel> players;
  final List<GroupModel> groups;
  final bool isLoading;
  final Function(CreatePartnerTournamentAction) onAction;
  final List<PlayerModel> Function(int) getPlayersInGroup;

  const PartnerAddPlayerScreen({
    super.key,
    required this.tournament,
    required this.players,
    required this.groups,
    this.isLoading = false,
    required this.onAction,
    required this.getPlayersInGroup,
  });

  @override
  State<PartnerAddPlayerScreen> createState() => _PartnerAddPlayerScreenState();
}

class _PartnerAddPlayerScreenState extends State<PartnerAddPlayerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 저장된 선수 탭 관련 상태
  int? _selectedGroupId;
  final Map<int, bool> _selectedPlayers = {};
  static const int ALL_GROUPS = -999; // 모든 그룹을 선택했을 때 사용할 상수

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 기본 선택 그룹 설정 (전체 그룹)
    _selectedGroupId = ALL_GROUPS;

    debugPrint('PartnerAddPlayerScreen - 초기화: 저장된 그룹 수 ${widget.groups.length}개');
    if (widget.groups.isNotEmpty) {
      debugPrint(
        'PartnerAddPlayerScreen - 그룹 목록: ${widget.groups.map((g) => "${g.id}:${g.name}").join(', ')}',
      );

      // 초기화 시 모든 그룹의 선수 목록 로드 요청
      for (final group in widget.groups) {
        widget.onAction(CreatePartnerTournamentAction.loadPlayersFromGroup(group.id));
      }
    }

    // 모든 그룹에 대한 선수 목록 미리 로드 (지연 실행, 화면 빌드 후)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 전체 그룹 새로고침
      widget.onAction(const CreatePartnerTournamentAction.fetchAllGroups());

      // 선수 초기 로드
      _loadAllGroupPlayers();
    });

    // 저장된 선수 탭으로 이동 시 그룹 데이터 새로고침
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        // 저장된 선수 탭으로 이동 시
        debugPrint('AddPlayerScreen - 저장된 선수 탭으로 이동: 그룹 및 선수 데이터 새로고침');
        // 모든 그룹 새로고침
        widget.onAction(const CreatePartnerTournamentAction.fetchAllGroups());

        // 모든 그룹의 선수 데이터도 새로고침
        _loadAllGroupPlayers();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // 특정 그룹을 선택하면 해당 그룹의 선수만 표시
  void _selectGroup(int? groupId) {
    if (groupId == null) return;

    setState(() {
      _selectedGroupId = groupId;
    });

    // 전체 그룹 선택 시 각 그룹의 선수 데이터를 한번 더 로드
    if (groupId == ALL_GROUPS) {
      debugPrint('AddPlayerScreen - 전체 그룹 선택: 모든 그룹의 선수 데이터 새로고침');
      if (widget.groups.isNotEmpty) {
        for (final group in widget.groups) {
          widget.onAction(
            CreatePartnerTournamentAction.loadPlayersFromGroup(group.id),
          );
        }

        // 약간의 딜레이 후 상태 업데이트 (전체 그룹 선수 로드 후)
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              // 상태 갱신하여 UI 다시 그리기
            });
          }
        });
      }
    } else {
      // 특정 그룹 선택 시 해당 그룹 데이터 강제 로드
      widget.onAction(CreatePartnerTournamentAction.loadPlayersFromGroup(groupId));
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

    // 이미 처리된 선수 ID 목록
    Set<int> processedPlayerIds = {};
    // 추가에 성공한 선수 수
    int successCount = 0;

    // 모든 그룹에서 선택된 선수들을 찾아 추가
    final allGroupsPlayers = widget.getPlayersInGroup(ALL_GROUPS);

    // 선택된 선수들만 추가
    for (final playerId in _selectedPlayers.keys) {
      // 이미 처리된 선수는 건너뛰기
      if (processedPlayerIds.contains(playerId)) continue;

      // 모든 그룹의 선수 목록에서 해당 ID를 가진 선수 찾기
      final player = allGroupsPlayers.firstWhere(
        (p) => p.id == playerId,
        orElse: () => PlayerModel(id: -1, name: ''),
      );

      if (player.id != -1) {
        // 이미 추가된 선수인지 확인 (이름만으로 비교)
        final isAlreadyAdded = widget.players.any(
          (p) => p.name == player.name,
        );

        if (!isAlreadyAdded) {
          // 아직 추가되지 않은 선수만 추가 실행
          widget.onAction(CreatePartnerTournamentAction.selectPlayerFromGroup(player));
          successCount++;
        }
        
        // 처리 완료 표시
        processedPlayerIds.add(player.id);
        debugPrint('선수 추가: ID ${player.id}, 이름 ${player.name}, 이미 추가됨: $isAlreadyAdded');
      }
    }

    // 선택 초기화
    setState(() {
      _selectedPlayers.clear();
    });

    // 디버깅 정보
    debugPrint('총 ${processedPlayerIds.length}명의 선수가 처리되었습니다. 실제 추가된 선수: $successCount명');
    
    // 선수 목록 탭으로 자동 이동 (탭 인덱스 0은 선수 목록 탭)
    if (successCount > 0) {
      _tabController.animateTo(0);
      debugPrint('선수 추가 후 선수 목록 탭으로 자동 이동');
    }
  }

  // 현재 선택된 그룹의 선수 목록을 가져오는 헬퍼 메서드
  List<PlayerModel> _getPlayersInSelectedGroup() {
    if (_selectedGroupId == null) return [];

    // 전체 그룹 선택 시 모든 그룹의 선수 목록 병합하여 반환
    if (_selectedGroupId == ALL_GROUPS) {
      return widget.getPlayersInGroup(ALL_GROUPS);
    }

    // 특정 그룹 선택 시 해당 그룹의 선수 목록 반환
    return widget.getPlayersInGroup(_selectedGroupId!);
  }

  // 모든 그룹의 선수 목록을 로드하는 헬퍼 메서드
  void _loadAllGroupPlayers() {
    if (widget.groups.isEmpty) return;

    debugPrint('AddPlayerScreen - 모든 그룹의 선수 데이터 로드 시작');

    // 각 그룹의 선수 목록 로드
    for (final group in widget.groups) {
      widget.onAction(CreatePartnerTournamentAction.loadPlayersFromGroup(group.id));
    }

    // 약간의 딜레이 후 UI 갱신
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          // 상태 갱신을 통해 UI 다시 그리기
          debugPrint('AddPlayerScreen - 모든 그룹 선수 로드 후 UI 갱신');
        });

        // 전체 그룹의 선수 목록 확인 (디버깅 용도)
        final allPlayers = widget.getPlayersInGroup(ALL_GROUPS);
        debugPrint('AddPlayerScreen - 전체 그룹 선수: ${allPlayers.length}명 로드됨');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 선수 수 제한 조건 확인 (4~32명)
    final playerCount = widget.players.length;
    final bool isValidPlayerCount = playerCount >= 4 && playerCount <= 32;
    final String playerCountWarning =
        !isValidPlayerCount
            ? (playerCount < 4 ? AppStrings.minPlayersRequired : AppStrings.maxPlayersAllowed)
            : "";

    return Column(
      children: [
        // 탭바 추가
        Container(
          color: CST.primary20,
          child: TabBar(
            controller: _tabController,
            indicatorColor: CST.primary100,
            labelColor: CST.primary100,
            unselectedLabelColor: CST.gray2,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 18),
                    SizedBox(width: 8),
                    Text(AppStrings.playerList),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group, size: 18),
                    SizedBox(width: 8),
                    Text(AppStrings.savedPlayers),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 탭 내용
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 선수 목록 탭
              _buildPlayerListTab(),

              // 저장된 선수 탭
              _buildSavedPlayersTab(),
            ],
          ),
        ),

        // 선수 수 관련 안내 메시지
        if (!isValidPlayerCount)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: CST.primary20,
            child: Row(
              children: [
                Icon(
                  playerCount < 4
                      ? Icons.error_outline
                      : Icons.warning_amber_outlined,
                  color: playerCount < 4 ? Colors.red : Colors.orange,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    playerCountWarning,
                    style: TST.smallTextBold.copyWith(
                      color: playerCount < 4 ? Colors.red : Colors.orange,
                    ),
                  ),
                ),
                Text(
                  "$playerCount/32명",
                  style: TST.smallTextBold.copyWith(
                    color:
                        playerCount < 4
                            ? Colors.red
                            : playerCount > 32
                            ? Colors.orange
                            : CST.primary100,
                  ),
                ),
              ],
            ),
          ),

        // 하단 이전/다음 버튼
        NavigationButtonsWidget(
          onPrevious: () {
            debugPrint(
              'AddPlayerScreen - 이전 버튼 클릭: 현재 선수 수 ${widget.players.length}명',
            );
            // 이전 화면으로 이동 (데이터 유지)
            context.go(
              '${RoutePaths.createTournament}${RoutePaths.tournamentInfo}',
            );
          },
          onNext: () {
            if (!isValidPlayerCount) {
              // 선수 수가 유효하지 않을 때 스낵바로 안내
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.playersRequired),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }

            debugPrint(
              'AddPlayerScreen - 다음 버튼 클릭: 현재 선수 수 ${widget.players.length}명',
            );
            widget.onAction(CreatePartnerTournamentAction.updateProcess(2));

            context.go('${RoutePaths.createTournament}${RoutePaths.editMatch}');
          },
          isNextDisabled: widget.players.isEmpty || !isValidPlayerCount,
        ),
      ],
    );
  }

  // 선수 목록 탭 빌드
  Widget _buildPlayerListTab() {
    return Column(
      children: [
        // 선수 추가 입력 필드
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: PlayerInputField(onAction: widget.onAction as Function(CreateTournamentActionBase)),
        ),

        // 현재 선수 목록 라벨
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(Icons.people, size: 16, color: CST.primary100),
              SizedBox(width: 8),
              Text(
                '${AppStrings.currentPlayerList} (${widget.players.length}명)',
                style: TST.mediumTextBold.copyWith(color: CST.primary100),
              ),
            ],
          ),
        ),
        Divider(thickness: 1, color: CST.gray4),

        // 선수 목록
        Expanded(
          child:
              widget.players.isEmpty
                  ? EmptyPlayerListWidget()
                  : ListView.builder(
                    itemCount: widget.players.length,
                    itemBuilder: (context, index) {
                      return InlineEditablePlayerItem(
                        player: widget.players[index],
                        index: index + 1,
                        onAction: widget.onAction as Function(CreateTournamentActionBase),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  // 저장된 선수 탭 빌드
  Widget _buildSavedPlayersTab() {
    final hasGroups = widget.groups.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 그룹 선택 영역
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 그룹 선택 드롭다운
              GroupDropdown(
                groups: widget.groups,
                selectedGroupId: _selectedGroupId,
                onGroupSelected: _selectGroup,
                allGroupsConstant: ALL_GROUPS,
              ),

              // 새로고침 버튼
              const SizedBox(width: 10),
              GroupRefreshButton(
                onAction: widget.onAction as Function(CreateTournamentActionBase),
                onRefresh: _loadAllGroupPlayers,
              ),
            ],
          ),
        ),

        // 선수 선택 목록
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: CST.primary20,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CST.gray4),
            ),
            child:
                hasGroups
                    ? PlayerSelectionList(
                      players: _getPlayersInSelectedGroup(),
                      tournamentPlayers: widget.players,
                      selectedPlayers: _selectedPlayers,
                      onToggleSelection: _togglePlayerSelection,
                      selectedGroupId: _selectedGroupId,
                    )
                    : NoGroupsMessage(),
          ),
        ),

        // 선택된 선수 추가 버튼
        AddPlayerActionButton(
          selectedCount: _selectedPlayers.length,
          onTap: _addSelectedPlayers,
        ),
      ],
    );
  }

  // 선수 선택 목록 구성
}
