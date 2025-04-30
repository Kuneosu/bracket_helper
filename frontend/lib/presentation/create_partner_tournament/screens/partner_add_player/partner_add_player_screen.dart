// ignore_for_file: constant_identifier_names

import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/create_partner_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/add_player/inline_editable_player_item.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/index.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/widgets/partner_add_player/index.dart';
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

  // 파트너 관련 상태 추가
  final List<List<String>> _fixedPairs = [];
  int? _firstSelectedPlayerId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 탭 개수를 3개로 변경

    // 기본 선택 그룹 설정 (전체 그룹)
    _selectedGroupId = ALL_GROUPS;

    debugPrint(
      'PartnerAddPlayerScreen - 초기화: 저장된 그룹 수 ${widget.groups.length}개',
    );
    if (widget.groups.isNotEmpty) {
      debugPrint(
        'PartnerAddPlayerScreen - 그룹 목록: ${widget.groups.map((g) => "${g.id}:${g.name}").join(', ')}',
      );

      // 초기화 시 모든 그룹의 선수 목록 로드 요청
      for (final group in widget.groups) {
        widget.onAction(
          CreatePartnerTournamentAction.loadPlayersFromGroup(group.id),
        );
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
      if (_tabController.index == 2) {
        // 인덱스 변경
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
      widget.onAction(
        CreatePartnerTournamentAction.loadPlayersFromGroup(groupId),
      );
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
        final isAlreadyAdded = widget.players.any((p) => p.name == player.name);

        if (!isAlreadyAdded) {
          // 아직 추가되지 않은 선수만 추가 실행
          widget.onAction(
            CreatePartnerTournamentAction.selectPlayerFromGroup(player),
          );
          successCount++;
        }

        // 처리 완료 표시
        processedPlayerIds.add(player.id);
        debugPrint(
          '선수 추가: ID ${player.id}, 이름 ${player.name}, 이미 추가됨: $isAlreadyAdded',
        );
      }
    }

    // 선택 초기화
    setState(() {
      _selectedPlayers.clear();
    });

    // 디버깅 정보
    debugPrint(
      '총 ${processedPlayerIds.length}명의 선수가 처리되었습니다. 실제 추가된 선수: $successCount명',
    );

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
      widget.onAction(
        CreatePartnerTournamentAction.loadPlayersFromGroup(group.id),
      );
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

  // 선수를 파트너로 선택하는 기능
  void _selectPlayerAsPartner(PlayerModel player) {
    if (_firstSelectedPlayerId == null) {
      // 첫 번째 선수 선택
      setState(() {
        _firstSelectedPlayerId = player.id;
      });
    } else if (_firstSelectedPlayerId == player.id) {
      // 같은 선수를, 선택 취소
      setState(() {
        _firstSelectedPlayerId = null;
      });
    } else {
      // 두 번째 선수 선택 - 파트너 쌍 생성
      final firstPlayer = widget.players.firstWhere(
        (p) => p.id == _firstSelectedPlayerId,
      );
      
      // 중복 쌍 확인
      bool isDuplicate = false;
      for (var pair in _fixedPairs) {
        if ((pair[0] == firstPlayer.name && pair[1] == player.name) ||
            (pair[0] == player.name && pair[1] == firstPlayer.name)) {
          isDuplicate = true;
          break;
        }
      }
      
      if (!isDuplicate) {
        setState(() {
          _fixedPairs.add([firstPlayer.name, player.name]);
          _firstSelectedPlayerId = null;
        });
      } else {
        // 중복된 쌍이면 선택 취소만
        setState(() {
          _firstSelectedPlayerId = null;
        });
      }
    }
  }
  
  // 파트너 쌍 제거
  void _removePartnerPair(int index) {
    setState(() {
      _fixedPairs.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 선수 수 제한 조건 확인 (8~32명)
    final playerCount = widget.players.length;
    final bool isValidPlayerCount = playerCount >= 8 && playerCount <= 32;
    final String playerCountWarning =
        !isValidPlayerCount
            ? (playerCount < 8
                ? AppStrings.partnerMinPlayersRequired
                : AppStrings.partnerMaxPlayersAllowed)
            : "";

    // 파트너 쌍 필수 조건 확인 (복식 일 때만)
    final bool hasRequiredPartnerPairs =
        !widget.tournament.isDoubles || _fixedPairs.isNotEmpty;

    // 경고 메시지 표시 여부 확인
    final bool showWarning =
        !isValidPlayerCount ||
        (widget.tournament.isDoubles &&
            _fixedPairs.isEmpty &&
            playerCount >= 8);

    // 경고 메시지 결정
    final String warningMessage =
        !isValidPlayerCount ? playerCountWarning : "최소 한 쌍 이상의 파트너를 지정해주세요.";

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
                    Icon(Icons.person, size: 16),
                    SizedBox(width: 6),
                    Text(AppStrings.playerList),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.link, size: 16),
                    SizedBox(width: 6),
                    Text("파트너 쌍"),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.group, size: 16),
                    SizedBox(width: 6),
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

              // 파트너 쌍 탭 (새로 추가)
              _buildPartnerPairsTab(),

              // 저장된 선수 탭
              _buildSavedPlayersTab(),
            ],
          ),
        ),

        // 선수 수 관련 안내 메시지
        if (showWarning)
          PartnerWarningBanner(
            message: warningMessage,
            isPlayerCountWarning: !isValidPlayerCount,
            currentCount: !isValidPlayerCount ? playerCount : _fixedPairs.length,
            requiredCount: !isValidPlayerCount ? 32 : 1,
          ),

        // 하단 이전/다음 버튼
        NavigationButtonsWidget(
          onPrevious: () {
            debugPrint(
              'AddPlayerScreen - 이전 버튼 클릭: 현재 선수 수 ${widget.players.length}명',
            );
            // 이전 화면으로 이동 (데이터 유지)
            context.go(
              '${RoutePaths.createPartnerTournament}${RoutePaths.partnerTournamentInfo}',
            );
          },
          onNext: () async {
            if (!isValidPlayerCount) {
              // 선수 수가 유효하지 않을 때 스낵바로 안내
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    playerCount < 8
                        ? "최소 8명의 선수가 필요합니다."
                        : AppStrings.partnerMaxPlayersAllowed,
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
              return;
            }

            // 복식일 때 파트너 쌍 필수 확인
            if (widget.tournament.isDoubles && _fixedPairs.isEmpty) {
              // 파트너 쌍이 없을 때 스낵바로 안내
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("최소 한 쌍 이상의 파트너를 지정해주세요."),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
              // 파트너 쌍 탭으로 자동 전환
              _tabController.animateTo(1);
              return;
            }

            debugPrint(
              'AddPlayerScreen - 다음 버튼 클릭: 현재 선수 수 ${widget.players.length}명, 고정 파트너 쌍: ${_fixedPairs.length}쌍',
            );

            // 고정 파트너 쌍 정보 로깅
            for (var pair in _fixedPairs) {
              debugPrint('  - 파트너 쌍: ${pair[0]} & ${pair[1]}');
            }

            // 플레이어 수가 홀수일 때 파트너 쌍 검증
            if (widget.players.length % 2 != 0 && _fixedPairs.isNotEmpty) {
              // 홀수 인원인 경우 고정 파트너 수 제한
              // 홀수 인원에 맞게 최대 고정 파트너 쌍 수를 계산
              // 홀수 인원의 경우 최대 (인원수 - 1) / 4 쌍까지 고정 가능
              int maxPairs = (widget.players.length - 1) ~/ 4;

              if (_fixedPairs.length > maxPairs) {
                _showErrorDialog(
                  '파트너 쌍 과다',
                  '홀수 인원(${widget.players.length}명)에 고정 파트너 쌍이 너무 많습니다.\n\n${widget.players.length}명일 경우 최대 $maxPairs쌍까지만 고정 파트너를 지정할 수 있습니다.\n\n파트너 쌍 수를 줄이거나 선수를 한 명 더 추가하세요.',
                );
                return;
              }
            }

            // 매치 생성 액션 호출
            widget.onAction(CreatePartnerTournamentAction.updateProcess(2));

            // 고정 파트너 쌍이 있으면 GenerateMatchesWithPartners 액션 호출
            if (_fixedPairs.isNotEmpty && context.mounted) {
              final courts = widget.players.length ~/ 4;

              // 로딩 표시
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) =>
                        const Center(child: CircularProgressIndicator()),
              );

              try {
                // 비동기 작업으로 대진표 생성 (계산이 오래 걸릴 수 있음)
                await Future.delayed(
                  Duration(milliseconds: 100),
                ); // UI 업데이트를 위한 약간의 지연
                widget.onAction(
                  CreatePartnerTournamentAction.generateMatchesWithPartners(
                    courts,
                    _fixedPairs,
                  ),
                );

                // 로딩 다이얼로그 닫기
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                // 다음 화면으로 이동
                if (context.mounted) {
                  context.go(
                    '${RoutePaths.createPartnerTournament}${RoutePaths.partnerEditMatch}',
                  );
                }
              } catch (e) {
                // 로딩 다이얼로그 닫기
                if (context.mounted) {
                  Navigator.of(context).pop();
                }

                debugPrint('대진표 생성 실패: $e');
                // 에러 다이얼로그 표시
                if (context.mounted) {
                  _showErrorDialog(
                    '대진표 생성 실패',
                    '지정된 파트너 쌍으로는 조건을 만족하는 대진표를 생성할 수 없습니다.\n\n다음 방법을 시도해보세요:\n- 파트너 쌍 수를 줄이기\n- 참가 인원 늘리기\n- 파트너 쌍을 다르게 지정하기',
                  );
                }
              }
            } else {
              // 고정 파트너가 없는 경우 바로 다음 화면으로 이동
              if (context.mounted) {
                context.go(
                  '${RoutePaths.createPartnerTournament}${RoutePaths.partnerEditMatch}',
                );
              }
            }
          },
          isNextDisabled:
              widget.players.isEmpty ||
              !isValidPlayerCount ||
              !hasRequiredPartnerPairs,
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
          child: PlayerInputField(
            onAction: (action) {
              // 간단하게 이름만 추출하여 CreatePartnerTournamentAction으로 변환
              if (action.toString().contains('addPlayer')) {
                // 액션 문자열에서 이름 추출 수정
                final actionStr = action.toString();
                // 문자열 형태: AddPlayer(name: 입력값)
                // 여기서 "입력값" 부분만 추출해야 함
                final nameStart = actionStr.indexOf('name: ') + 'name: '.length;
                final nameEnd = actionStr.lastIndexOf(')');
                if (nameStart > 0 && nameEnd > nameStart) {
                  final name = actionStr.substring(nameStart, nameEnd);
                  debugPrint('추출된 이름: $name');
                  widget.onAction(
                    CreatePartnerTournamentAction.addPlayer(name),
                  );
                }
              }
            },
          ),
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

        // 선수 목록 (스크롤 가능)
        Expanded(
          child:
              widget.players.isEmpty
                  ? EmptyPlayerListWidget()
                  : ListView.builder(
                      itemCount: widget.players.length,
                      itemBuilder: (context, index) {
                        final player = widget.players[index];
                        return _buildEditablePlayerItem(player, index);
                      },
                    ),
        ),
      ],
    );
  }

  // 파트너 쌍 설정 탭 (새로 추가)
  Widget _buildPartnerPairsTab() {
    return widget.tournament.isDoubles 
        ? Column(
            children: [
              // 선수 선택 영역
              Expanded(
                child:
                    widget.players.isEmpty
                        ? Center(
                          child: Text(
                            '선수 목록이 비어있습니다.\n선수 목록 탭에서 선수를 추가하세요.',
                            textAlign: TextAlign.center,
                            style: TST.mediumTextRegular.copyWith(
                              color: CST.gray3,
                            ),
                          ),
                        )
                        : Column(
                          children: [
                            // 선수 선택 목록 (비율 3/5)
                            Expanded(
                              flex: 3, 
                              child: PartnerSelectionGrid(
                                players: widget.players,
                                fixedPairs: _fixedPairs,
                                firstSelectedPlayerId: _firstSelectedPlayerId,
                                onSelectPlayer: _selectPlayerAsPartner,
                              ),
                            ),

                            // 구분선
                            Divider(thickness: 1, color: CST.primary40),
                            
                            // 고정 파트너 쌍 목록 (비율 2/5)
                            Expanded(
                              flex: 2,
                              child: FixedPartnerList(
                                fixedPairs: _fixedPairs,
                                onRemove: _removePartnerPair,
                              ),
                            ),
                          ],
                        ),
              ),
            ],
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_tennis, size: 64, color: CST.primary40),
                SizedBox(height: 16),
                Text(
                  '단식 토너먼트에서는\n파트너 설정이 필요하지 않습니다.',
                  textAlign: TextAlign.center,
                  style: TST.mediumTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
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
                onAction: (action) {
                  // 액션 문자열로 처리
                  if (action.toString().contains('fetchAllGroups')) {
                    widget.onAction(
                      CreatePartnerTournamentAction.fetchAllGroups(),
                    );
                    _loadAllGroupPlayers();
                  }
                },
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

  // 편집 가능한 선수 아이템 (선수 목록 탭용)
  Widget _buildEditablePlayerItem(PlayerModel player, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InlineEditablePlayerItem(
        player: player,
        index: index + 1,
        onAction: (action) {
          // 액션 문자열로 구분하여 처리
          final actionStr = action.toString();
          if (actionStr.contains('updatePlayer')) {
            // 선수 업데이트
            widget.onAction(CreatePartnerTournamentAction.updatePlayer(player));
          } else if (actionStr.contains('removePlayer')) {
            // 선수 삭제
            widget.onAction(
              CreatePartnerTournamentAction.removePlayer(player.id),
            );
          }
        },
      ),
    );
  }

  // 에러 다이얼로그를 표시하는 헬퍼 메서드
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: EdgeInsets.only(top: 24, left: 24, right: 24),
            contentPadding: EdgeInsets.fromLTRB(24, 16, 24, 0),
            title: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CST.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: CST.error,
                    size: 32,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TST.mediumTextBold.copyWith(
                    color: CST.error,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TST.normalTextRegular,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CST.primary100,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('확인', style: TST.normalTextBold),
                  ),
                ),
                SizedBox(height: 24),
              ],
            ),
            actionsPadding: EdgeInsets.zero,
            actions: [],
          ),
    );
  }
}
