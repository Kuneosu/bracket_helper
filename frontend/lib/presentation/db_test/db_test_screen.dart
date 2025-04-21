import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/dao/team_dao.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/domain/use_case/group/add_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/add_player_to_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/player/add_player_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/create_match_use_case.dart';
import 'package:bracket_helper/domain/use_case/team/create_team_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/create_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/delete_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/delete_match_use_case.dart';
import 'package:bracket_helper/domain/use_case/player/delete_player_use_case.dart';
import 'package:bracket_helper/domain/use_case/team/delete_team_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/delete_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/domain/use_case/player/get_all_players_use_case.dart';
import 'package:bracket_helper/domain/use_case/team/get_all_teams_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_all_tournaments_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/get_matches_in_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/remove_player_from_group_use_case.dart';
import 'package:bracket_helper/domain/model/match_model.dart' as domain;
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:flutter/material.dart';

class DbTestScreen extends StatefulWidget {
  const DbTestScreen({super.key});

  @override
  State<DbTestScreen> createState() => _DbTestScreenState();
}

class _DbTestScreenState extends State<DbTestScreen>
    with SingleTickerProviderStateMixin {
  // DAOs

  // 상태 변수
  List<Player> _players = [];
  List<GroupModel> _groups = [];
  List<TeamWithPlayers> _teams = [];
  List<TournamentModel> _tournaments = [];
  String _statusMessage = '';

  // 선택한 그룹의 상세 정보
  int? _selectedGroupId;
  List<Player> _playersInSelectedGroup = [];

  // 선택한 토너먼트의 매치
  int? _selectedTournamentId;
  List<domain.MatchModel> _matchesInSelectedTournament = [];

  // 탭 컨트롤러
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      // UseCase 인스턴스 가져오기
      final getAllPlayersUseCase = getIt<GetAllPlayersUseCase>();
      final getAllGroupsUseCase = getIt<GetAllGroupsUseCase>();
      final getAllTeamsUseCase = getIt<GetAllTeamsUseCase>();
      final getAllTournamentsUseCase = getIt<GetAllTournamentsUseCase>();

      // 디버깅 정보
      debugPrint('----- 데이터 로드 시작 -----');

      // 선수 목록 조회
      final playersResult = await getAllPlayersUseCase.execute();
      if (playersResult.isFailure) {
        setState(() {
          _statusMessage = '선수 데이터 로드 실패: ${playersResult.error.message}';
        });
        return;
      }

      // 그룹 목록 조회
      final groupsResult = await getAllGroupsUseCase.execute();
      if (groupsResult.isFailure) {
        setState(() {
          _statusMessage = '그룹 데이터 로드 실패: ${groupsResult.error.message}';
        });
        return;
      }

      // 팀 목록 조회
      final teamsResult = await getAllTeamsUseCase.execute();
      if (teamsResult.isFailure) {
        setState(() {
          _statusMessage = '팀 데이터 로드 실패: ${teamsResult.error.message}';
        });
        return;
      }

      // 토너먼트 목록 조회
      final tournamentsResult = await getAllTournamentsUseCase.execute();
      if (tournamentsResult.isFailure) {
        setState(() {
          _statusMessage = '토너먼트 데이터 로드 실패: ${tournamentsResult.error.message}';
        });
        return;
      }

      setState(() {
        _players = playersResult.value;
        _groups = groupsResult.value;
        _teams = teamsResult.value as List<TeamWithPlayers>;
        _tournaments = tournamentsResult.value;
        _statusMessage = '데이터 로드 완료';
      });

      // 선택된 그룹이 있으면 그룹 내 선수 목록 갱신
      if (_selectedGroupId != null) {
        _loadPlayersInGroup(_selectedGroupId!);
      }

      // 선택된 토너먼트가 있으면 매치 목록 갱신
      if (_selectedTournamentId != null) {
        _loadMatchesInTournament(_selectedTournamentId!);
      }

      // 디버깅 정보
      debugPrint('----- 데이터 로드 완료 -----');
    } catch (e) {
      debugPrint('Screen: 데이터 로드 중 예외 발생 - $e');
      setState(() {
        _statusMessage = '데이터 로드 실패: $e';
      });
    }
  }

  // 특정 그룹에 속한 선수 목록 불러오기
  Future<void> _loadPlayersInGroup(int groupId) async {
    try {
      final getGroupUseCase = getIt<GetGroupUseCase>();

      // 디버깅 정보
      debugPrint('----- 그룹 정보 로드 시작 -----');
      debugPrint('Screen: 그룹 정보 로드 기능 시작 - 그룹 ID: $groupId');

      final result = await getGroupUseCase.execute(groupId);

      // 디버깅 정보
      debugPrint('Screen: UseCase 실행 결과 - $result');

      if (result.isSuccess) {
        // 성공 처리
        final groupWithPlayers = result.value;
        debugPrint(
          'Screen: 그룹 정보 로드 성공 - ${groupWithPlayers.group.name}, 선수 ${groupWithPlayers.players.length}명',
        );
        setState(() {
          _selectedGroupId = groupId;
          _playersInSelectedGroup = groupWithPlayers.players;
          _statusMessage = '${groupWithPlayers.group.name} 그룹 정보 로드 완료';
        });
      } else {
        // 에러 메시지 표시
        final error = result.error;
        debugPrint('Screen: 그룹 정보 로드 실패 - $error');
        setState(() {
          _statusMessage = '그룹 정보 로드 실패: ${error.message}';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('Screen: 예상치 못한 예외 발생 - $e');
      setState(() {
        _statusMessage = '그룹 내 선수 목록 로드 실패: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('예상치 못한 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      debugPrint('----- 그룹 정보 로드 종료 -----');
    }
  }

  // 특정 토너먼트의 매치 목록 불러오기
  Future<void> _loadMatchesInTournament(int tournamentId) async {
    try {
      final getMatchesInTournamentUseCase =
          getIt<GetMatchesInTournamentUseCase>();

      // 디버깅 정보
      debugPrint('----- 토너먼트 내 매치 로드 시작 -----');
      debugPrint('Screen: 토너먼트 매치 로드 기능 시작 - 토너먼트 ID: $tournamentId');

      final result = await getMatchesInTournamentUseCase.execute(tournamentId);

      // 디버깅 정보
      debugPrint('Screen: UseCase 실행 결과 - $result');

      if (result.isSuccess) {
        // 성공 처리
        final matches = result.value;
        debugPrint('Screen: 토너먼트 매치 로드 성공 - ${matches.length}개 매치');
        setState(() {
          _selectedTournamentId = tournamentId;
          _matchesInSelectedTournament = matches;
          _statusMessage = '토너먼트 내 매치 ${matches.length}개 로드 완료';
        });
      } else {
        // 에러 메시지 표시
        final error = result.error;
        debugPrint('Screen: 토너먼트 매치 로드 실패 - $error');
        setState(() {
          _statusMessage = '토너먼트 매치 목록 로드 실패: ${error.message}';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      debugPrint('Screen: 예상치 못한 예외 발생 - $e');
      setState(() {
        _statusMessage = '토너먼트 매치 목록 로드 실패: $e';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('예상치 못한 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      debugPrint('----- 토너먼트 내 매치 로드 종료 -----');
    }
  }

  Future<void> _addPlayer() async {
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('선수 추가'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: '선수 이름'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final addPlayerUseCase = getIt<AddPlayerUseCase>();

                    // 디버깅 정보
                    debugPrint('----- 선수 추가 시작 -----');
                    debugPrint(
                      'Screen: 선수 추가 기능 시작 - 선수 이름: ${nameController.text}',
                    );

                    try {
                      final result = await addPlayerUseCase.execute(
                        nameController.text,
                      );

                      // 디버깅 정보
                      debugPrint('Screen: UseCase 실행 결과 - $result');

                      // 항상 다이얼로그를 닫고
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      if (result.isSuccess) {
                        // 성공 처리 (result.value는 선수 ID)
                        debugPrint('Screen: 선수 추가 성공 - ID: ${result.value}');
                        setState(() {
                          _statusMessage =
                              '선수 추가됨: ${nameController.text} (ID: ${result.value})';
                        });
                        _loadData();

                        // 성공 메시지 표시
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${nameController.text} 선수가 추가되었습니다.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        // 에러 메시지 표시
                        final error = result.error;
                        debugPrint('Screen: 선수 추가 실패 - $error');
                        setState(() {
                          _statusMessage = error.message;
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // 예상치 못한 예외 처리
                      debugPrint('Screen: 예상치 못한 예외 발생 - $e');
                      // 다이얼로그 닫기
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      // 상태 업데이트
                      setState(() {
                        _statusMessage = '예상치 못한 오류: $e';
                      });
                      // 오류 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('예상치 못한 오류가 발생했습니다: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      debugPrint('----- 선수 추가 종료 -----');
                    }
                  }
                },
                child: const Text('추가'),
              ),
            ],
          ),
    );
  }

  Future<void> _addGroup() async {
    final nameController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('그룹 추가'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: '그룹 이름'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final addGroupUseCase = getIt<AddGroupUseCase>();

                    // 디버깅 정보
                    debugPrint('----- 그룹 추가 시작 -----');
                    debugPrint(
                      'Screen: 그룹 추가 기능 시작 - 그룹 이름: ${nameController.text}',
                    );

                    try {
                      final result = await addGroupUseCase.execute(
                        groupName: nameController.text,
                        colorValue: Colors.blue.value,
                      );

                      // 디버깅 정보
                      debugPrint('Screen: UseCase 실행 결과 - $result');

                      // 항상 다이얼로그를 닫고
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      if (result is int) {
                        // 성공 처리 (result는 그룹 ID)
                        debugPrint('Screen: 그룹 추가 성공 - ID: $result');
                        setState(() {
                          _statusMessage =
                              '그룹 추가됨: ${nameController.text} (ID: $result)';
                        });
                        _loadData();

                        // 성공 메시지 표시
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${nameController.text} 그룹이 추가되었습니다.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        // 에러 메시지 표시 (result는 에러 메시지)
                        debugPrint('Screen: 그룹 추가 실패 - $result');
                        setState(() {
                          _statusMessage = result.toString();
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // 예상치 못한 예외 처리
                      debugPrint('Screen: 예상치 못한 예외 발생 - $e');
                      // 다이얼로그 닫기
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                      // 상태 업데이트
                      setState(() {
                        _statusMessage = '예상치 못한 오류: $e';
                      });
                      // 오류 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('예상치 못한 오류가 발생했습니다: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      debugPrint('----- 그룹 추가 종료 -----');
                    }
                  }
                },
                child: const Text('추가'),
              ),
            ],
          ),
    );
  }

  Future<void> _addPlayerToGroup() async {
    if (_groups.isEmpty) {
      setState(() {
        _statusMessage = '그룹이 필요합니다';
      });
      return;
    }

    int? selectedPlayerId;
    int? selectedGroupId;
    final newPlayerNameController = TextEditingController();
    bool isAddingNewPlayer = false;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('그룹에 플레이어 추가'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 그룹 선택 드롭다운
                      DropdownButtonFormField<int>(
                        value: selectedGroupId,
                        hint: const Text('그룹 선택'),
                        decoration: const InputDecoration(labelText: '그룹'),
                        items:
                            _groups.map((group) {
                              return DropdownMenuItem<int>(
                                value: group.id,
                                child: Text(group.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedGroupId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // 새 선수 추가 체크박스
                      Row(
                        children: [
                          Checkbox(
                            value: isAddingNewPlayer,
                            onChanged: (value) {
                              setDialogState(() {
                                isAddingNewPlayer = value ?? false;
                                // 체크박스 상태 변경 시 선택된 선수 초기화
                                if (isAddingNewPlayer) {
                                  selectedPlayerId = null;
                                } else {
                                  newPlayerNameController.clear();
                                }
                              });
                            },
                          ),
                          const Text('새 선수 추가'),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // 조건부 위젯 표시 (선수 선택 or 새 선수 이름 입력)
                      if (isAddingNewPlayer)
                        TextField(
                          controller: newPlayerNameController,
                          decoration: const InputDecoration(
                            labelText: '새 선수 이름',
                            hintText: '새 선수 이름 입력',
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          value: selectedPlayerId,
                          hint: const Text('선수 선택'),
                          decoration: const InputDecoration(labelText: '선수'),
                          items:
                              _players.map((player) {
                                return DropdownMenuItem<int>(
                                  value: player.id,
                                  child: Text(player.name),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setDialogState(() {
                              selectedPlayerId = value;
                            });
                          },
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // 검증: 그룹 선택 필수
                        if (selectedGroupId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('그룹을 선택해주세요.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // 검증: 선수 선택 또는 새 선수 이름 입력 필수
                        if (!isAddingNewPlayer && selectedPlayerId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('선수를 선택해주세요.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (isAddingNewPlayer &&
                            newPlayerNameController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('새 선수 이름을 입력해주세요.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        final addPlayerToGroupUseCase =
                            getIt<AddPlayerToGroupUseCase>();

                        // 디버깅 정보
                        debugPrint('----- 그룹에 플레이어 추가 시작 -----');
                        final groupName =
                            _groups
                                .firstWhere((g) => g.id == selectedGroupId)
                                .name;

                        if (isAddingNewPlayer) {
                          // 새 선수 추가 로직
                          debugPrint(
                            'Screen: 새 플레이어 생성 및 그룹 추가 - 그룹: $groupName, 플레이어: ${newPlayerNameController.text}',
                          );

                          try {
                            // UseCase 실행 (새 선수 생성 및 그룹 추가)
                            final result = await addPlayerToGroupUseCase
                                .execute(
                                  AddPlayerToGroupParams(
                                    groupId: selectedGroupId!,
                                    playerName:
                                        newPlayerNameController.text.trim(),
                                  ),
                                );

                            // 디버깅 정보
                            debugPrint('Screen: UseCase 실행 결과 - $result');

                            // 항상 다이얼로그를 닫고
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }

                            if (result is int) {
                              // 성공 처리 (result는 플레이어 ID)
                              debugPrint('Screen: 플레이어 추가 성공 - ID: $result');
                              setState(() {
                                _statusMessage =
                                    '$groupName 그룹에 새 플레이어 추가됨: ${newPlayerNameController.text} (ID: $result)';
                              });

                              // 데이터 리로드
                              _loadData();
                              if (selectedGroupId == _selectedGroupId) {
                                _loadPlayersInGroup(selectedGroupId!);
                              }

                              // 성공 메시지 표시
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${newPlayerNameController.text}(새)가 $groupName 그룹에 추가되었습니다.',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              // 에러 메시지 표시 (result는 에러 메시지)
                              _handleAddPlayerError(result);
                            }
                          } catch (e) {
                            // 예상치 못한 예외 처리
                            _handleAddPlayerException(e);
                          }
                        } else {
                          // 기존 선수 그룹에 추가 로직
                          final player = _players.firstWhere(
                            (p) => p.id == selectedPlayerId,
                          );
                          debugPrint(
                            'Screen: 기존 플레이어를 그룹에 추가 - 그룹: $groupName, 플레이어: ${player.name}',
                          );

                          try {
                            // UseCase 사용 (Repository 직접 호출 대신)
                            final result = await addPlayerToGroupUseCase
                                .addExistingPlayerToGroup(
                                  selectedPlayerId!,
                                  selectedGroupId!,
                                );

                            // 디버깅 정보
                            debugPrint('Screen: UseCase 실행 결과 - $result');

                            // 항상 다이얼로그를 닫고
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }

                            if (result is bool && result) {
                              // 성공 처리
                              debugPrint('Screen: 기존 플레이어 그룹 추가 성공');
                              setState(() {
                                _statusMessage =
                                    '$groupName 그룹에 기존 플레이어 추가됨: ${player.name}';
                              });

                              // 데이터 리로드
                              if (selectedGroupId == _selectedGroupId) {
                                _loadPlayersInGroup(selectedGroupId!);
                              }

                              // 성공 메시지 표시
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${player.name}이(가) $groupName 그룹에 추가되었습니다.',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              // 에러 메시지 표시
                              final errorMessage = result.toString();

                              debugPrint(
                                'Screen: 기존 플레이어 그룹 추가 실패 - $errorMessage',
                              );
                              setState(() {
                                _statusMessage = errorMessage;
                              });

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            // 예상치 못한 예외 처리
                            _handleAddPlayerException(e);
                          }
                        }

                        // 종료 로그
                        debugPrint('----- 그룹에 플레이어 추가 종료 -----');
                      },
                      child: const Text('추가'),
                    ),
                  ],
                ),
          ),
    );
  }

  // 플레이어 추가 에러 처리 헬퍼 메서드
  void _handleAddPlayerError(dynamic result) {
    debugPrint('Screen: 플레이어 추가 실패 - $result');
    setState(() {
      _statusMessage = result.toString();
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.toString()), backgroundColor: Colors.red),
      );
    }
  }

  // 플레이어 추가 예외 처리 헬퍼 메서드
  void _handleAddPlayerException(dynamic e) {
    debugPrint('Screen: 예상치 못한 예외 발생 - $e');
    setState(() {
      _statusMessage = '예상치 못한 오류: $e';
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('예상치 못한 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createTeam() async {
    if (_players.isEmpty) {
      setState(() {
        _statusMessage = '선수가 필요합니다';
      });
      return;
    }

    int? selectedPlayer1Id;
    int? selectedPlayer2Id;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('팀 생성'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: selectedPlayer1Id,
                        hint: const Text('첫 번째 선수'),
                        items:
                            _players.map((player) {
                              return DropdownMenuItem<int>(
                                value: player.id,
                                child: Text(player.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedPlayer1Id = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedPlayer2Id,
                        hint: const Text('두 번째 선수 (선택)'),
                        items:
                            _players.map((player) {
                              return DropdownMenuItem<int>(
                                value: player.id,
                                child: Text(player.name),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedPlayer2Id = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () async {
                        if (selectedPlayer1Id != null) {
                          final createTeamUseCase = getIt<CreateTeamUseCase>();

                          // 디버깅 정보
                          debugPrint('----- 팀 생성 시작 -----');
                          debugPrint(
                            'Screen: 팀 생성 기능 시작 - 선수1: $selectedPlayer1Id, 선수2: $selectedPlayer2Id',
                          );

                          try {
                            final result = await createTeamUseCase.execute(
                              CreateTeamParams(
                                player1Id: selectedPlayer1Id!,
                                player2Id: selectedPlayer2Id,
                              ),
                            );

                            // 디버깅 정보
                            debugPrint('Screen: UseCase 실행 결과 - $result');

                            // 항상 다이얼로그를 닫고
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }

                            if (result.isSuccess) {
                              // 성공 처리 (result.value는 팀 ID)
                              final teamId = result.value;
                              final player1Name =
                                  _players
                                      .firstWhere(
                                        (p) => p.id == selectedPlayer1Id,
                                      )
                                      .name;
                              final player2Name =
                                  selectedPlayer2Id != null
                                      ? _players
                                          .firstWhere(
                                            (p) => p.id == selectedPlayer2Id,
                                          )
                                          .name
                                      : null;

                              final teamName =
                                  player2Name != null
                                      ? '$player1Name / $player2Name'
                                      : player1Name;

                              debugPrint(
                                'Screen: 팀 생성 성공 - ID: $teamId, 팀명: $teamName',
                              );
                              setState(() {
                                _statusMessage =
                                    '팀 생성됨: $teamName (ID: $teamId)';
                              });
                              _loadData();

                              // 성공 메시지 표시
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('팀 [$teamName]이(가) 생성되었습니다.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              // 에러 메시지 표시
                              final error = result.error;
                              debugPrint('Screen: 팀 생성 실패 - $error');
                              setState(() {
                                _statusMessage = error.message;
                              });

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            // 예상치 못한 예외 처리
                            debugPrint('Screen: 예상치 못한 예외 발생 - $e');
                            // 다이얼로그 닫기
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                            // 상태 업데이트
                            setState(() {
                              _statusMessage = '예상치 못한 오류: $e';
                            });
                            // 오류 메시지 표시
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('예상치 못한 오류가 발생했습니다: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } finally {
                            debugPrint('----- 팀 생성 종료 -----');
                          }
                        }
                      },
                      child: const Text('생성'),
                    ),
                  ],
                ),
          ),
    );
  }

  Future<void> _createTournament() async {
    final titleController = TextEditingController();
    final date = DateTime.now();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('토너먼트 생성'),
            content: TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: '토너먼트 이름'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  if (titleController.text.isNotEmpty) {
                    final createTournamentUseCase =
                        getIt<CreateTournamentUseCase>();

                    // 디버깅 정보
                    debugPrint('----- 토너먼트 생성 시작 -----');
                    debugPrint(
                      'Screen: 토너먼트 생성 시작 - 제목: ${titleController.text}',
                    );

                    try {
                      final result = await createTournamentUseCase.execute(
                        CreateTournamentParams(
                          title: titleController.text.trim(),
                          date: date,
                        ),
                      );

                      // 디버깅 정보
                      debugPrint('Screen: UseCase 실행 결과 - $result');

                      // 항상 다이얼로그를 닫고
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      if (result.isSuccess) {
                        // 성공 처리 (result.value는 토너먼트 ID)
                        final tournamentId = result.value;
                        debugPrint('Screen: 토너먼트 생성 성공 - ID: $tournamentId');
                        setState(() {
                          _statusMessage =
                              '토너먼트 생성됨: ${titleController.text} (ID: $tournamentId)';
                        });
                        _loadData();

                        // 성공 메시지 표시
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${titleController.text} 토너먼트가 생성되었습니다.',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        // 에러 메시지 표시
                        final error = result.error;
                        debugPrint('Screen: 토너먼트 생성 실패 - $error');
                        setState(() {
                          _statusMessage = error.message;
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // 예상치 못한 예외 처리
                      debugPrint('Screen: 예상치 못한 예외 발생 - $e');

                      // 다이얼로그 닫기
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      // 상태 업데이트
                      setState(() {
                        _statusMessage = '예상치 못한 오류: $e';
                      });

                      // 오류 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('예상치 못한 오류가 발생했습니다: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } finally {
                      debugPrint('----- 토너먼트 생성 종료 -----');
                    }
                  }
                },
                child: const Text('생성'),
              ),
            ],
          ),
    );
  }

  // 선수 삭제 다이얼로그
  Future<void> _confirmDeletePlayer(Player player) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('선수 삭제'),
            content: Text('${player.name} 선수를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  final deletePlayerUseCase = getIt<DeletePlayerUseCase>();

                  // 디버깅 정보
                  debugPrint('----- 선수 삭제 시작 -----');
                  debugPrint(
                    'Screen: 선수 삭제 기능 시작 - 선수 ID: ${player.id}, 이름: ${player.name}',
                  );

                  try {
                    final result = await deletePlayerUseCase.execute(player.id);

                    // 디버깅 정보
                    debugPrint('Screen: UseCase 실행 결과 - $result');

                    // 항상 다이얼로그를 닫고
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (result.isSuccess) {
                      // 성공 처리
                      debugPrint('Screen: 선수 삭제 성공');
                      setState(() {
                        _statusMessage = '선수 삭제됨: ${player.name}';
                      });
                      _loadData();

                      // 성공 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${player.name} 선수가 삭제되었습니다.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      // 에러 메시지 표시
                      final error = result.error;
                      debugPrint('Screen: 선수 삭제 실패 - $error');
                      setState(() {
                        _statusMessage = error.message;
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // 예상치 못한 예외 처리
                    debugPrint('Screen: 예상치 못한 예외 발생 - $e');

                    // 다이얼로그 닫기
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    // 상태 업데이트
                    setState(() {
                      _statusMessage = '예상치 못한 오류: $e';
                    });

                    // 오류 메시지 표시
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('예상치 못한 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    debugPrint('----- 선수 삭제 종료 -----');
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  // 그룹 삭제 다이얼로그
  Future<void> _confirmDeleteGroup(GroupModel group) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('그룹 삭제'),
            content: Text('${group.name} 그룹을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  final deleteGroupUseCase = getIt<DeleteGroupUseCase>();

                  // 디버깅 정보
                  debugPrint('----- 그룹 삭제 시작 -----');
                  debugPrint(
                    'Screen: 그룹 삭제 기능 시작 - 그룹 ID: ${group.id}, 이름: ${group.name}',
                  );

                  try {
                    final result = await deleteGroupUseCase.execute(group.id);

                    // 디버깅 정보
                    debugPrint('Screen: UseCase 실행 결과 - $result');

                    // 항상 다이얼로그를 닫고
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (result.isSuccess) {
                      // 성공 처리
                      debugPrint('Screen: 그룹 삭제 성공');
                      setState(() {
                        _statusMessage = '그룹 삭제됨: ${group.name}';
                        if (_selectedGroupId == group.id) {
                          _selectedGroupId = null;
                          _playersInSelectedGroup = [];
                        }
                      });
                      _loadData();

                      // 성공 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${group.name} 그룹이 삭제되었습니다.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      // 에러 메시지 표시
                      final error = result.error;
                      debugPrint('Screen: 그룹 삭제 실패 - $error');
                      setState(() {
                        _statusMessage = error.message;
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // 예상치 못한 예외 처리
                    debugPrint('Screen: 예상치 못한 예외 발생 - $e');

                    // 다이얼로그 닫기
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    // 상태 업데이트
                    setState(() {
                      _statusMessage = '예상치 못한 오류: $e';
                    });

                    // 오류 메시지 표시
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('예상치 못한 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    debugPrint('----- 그룹 삭제 종료 -----');
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  // 팀 삭제 다이얼로그
  Future<void> _confirmDeleteTeam(TeamWithPlayers team) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('팀 삭제'),
            content: Text('${team.teamName} 팀을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  final deleteTeamUseCase = getIt<DeleteTeamUseCase>();

                  // 디버깅 정보
                  debugPrint('----- 팀 삭제 시작 -----');
                  debugPrint(
                    'Screen: 팀 삭제 기능 시작 - 팀 ID: ${team.team.id}, 이름: ${team.teamName}',
                  );

                  try {
                    final result = await deleteTeamUseCase.execute(
                      team.team.id,
                    );

                    // 디버깅 정보
                    debugPrint('Screen: UseCase 실행 결과 - $result');

                    // 항상 다이얼로그를 닫고
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (result.isSuccess) {
                      // 성공 처리
                      debugPrint('Screen: 팀 삭제 성공');
                      setState(() {
                        _statusMessage = '팀 삭제됨: ${team.teamName}';
                      });
                      _loadData();

                      // 성공 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('팀이 삭제되었습니다: ${team.teamName}'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      // 에러 메시지 표시
                      final error = result.error;
                      debugPrint('Screen: 팀 삭제 실패 - $error');
                      setState(() {
                        _statusMessage = error.message;
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // 예상치 못한 예외 처리
                    debugPrint('Screen: 예상치 못한 예외 발생 - $e');

                    // 다이얼로그 닫기
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    // 상태 업데이트
                    setState(() {
                      _statusMessage = '예상치 못한 오류: $e';
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('예상치 못한 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  // 토너먼트 삭제 다이얼로그
  Future<void> _confirmDeleteTournament(TournamentModel tournament) async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('토너먼트 삭제'),
            content: Text('${tournament.title} 토너먼트를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  final deleteTournamentUseCase =
                      getIt<DeleteTournamentUseCase>();

                  // 디버깅 정보
                  debugPrint('----- 토너먼트 삭제 시작 -----');
                  debugPrint(
                    'Screen: 토너먼트 삭제 기능 시작 - 토너먼트 ID: ${tournament.id}, 제목: ${tournament.title}',
                  );

                  try {
                    final result = await deleteTournamentUseCase.execute(
                      tournament.id,
                    );

                    // 디버깅 정보
                    debugPrint('Screen: UseCase 실행 결과 - $result');

                    // 항상 다이얼로그를 닫고
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (result.isSuccess) {
                      // 성공 처리
                      debugPrint('Screen: 토너먼트 삭제 성공');
                      setState(() {
                        _statusMessage = '토너먼트 삭제됨: ${tournament.title}';
                        if (_selectedTournamentId == tournament.id) {
                          _selectedTournamentId = null;
                          _matchesInSelectedTournament = [];
                        }
                      });
                      _loadData();

                      // 성공 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${tournament.title} 토너먼트가 삭제되었습니다.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      // 에러 메시지 표시
                      final error = result.error;
                      debugPrint('Screen: 토너먼트 삭제 실패 - $error');
                      setState(() {
                        _statusMessage = error.message;
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // 예상치 못한 예외 처리
                    debugPrint('Screen: 예상치 못한 예외 발생 - $e');

                    // 다이얼로그 닫기
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    // 상태 업데이트
                    setState(() {
                      _statusMessage = '예상치 못한 오류: $e';
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('예상치 못한 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    debugPrint('----- 토너먼트 삭제 종료 -----');
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  // 그룹에서 선수 제거 다이얼로그
  Future<void> _confirmRemovePlayerFromGroup(Player player, int groupId) async {
    final group = _groups.firstWhere((g) => g.id == groupId);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('그룹에서 선수 제거'),
            content: Text('${group.name} 그룹에서 ${player.name} 선수를 제거하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  final removePlayerFromGroupUseCase =
                      getIt<RemovePlayerFromGroupUseCase>();

                  // 디버깅 정보
                  debugPrint('----- 그룹에서 선수 제거 시작 -----');
                  debugPrint(
                    'Screen: 그룹에서 선수 제거 기능 시작 - 선수: ${player.name}(ID: ${player.id}), 그룹: ${group.name}(ID: $groupId)',
                  );

                  try {
                    final result = await removePlayerFromGroupUseCase.execute(
                      player.id,
                      groupId,
                    );

                    // 디버깅 정보
                    debugPrint('Screen: UseCase 실행 결과 - $result');

                    // 항상 다이얼로그를 닫고
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (result.isSuccess) {
                      // 성공 처리
                      debugPrint('Screen: 선수 제거 성공');
                      setState(() {
                        _statusMessage =
                            '${group.name} 그룹에서 ${player.name} 선수가 제거됨';
                      });

                      // 그룹 내 선수 목록 갱신
                      _loadPlayersInGroup(groupId);

                      // 성공 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${player.name} 선수가 ${group.name} 그룹에서 제거되었습니다.',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      // 에러 메시지 표시
                      final error = result.error;
                      debugPrint('Screen: 선수 제거 실패 - $error');
                      setState(() {
                        _statusMessage = '선수 제거 실패: ${error.message}';
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // 예상치 못한 예외 처리
                    debugPrint('Screen: 예상치 못한 예외 발생 - $e');

                    // 다이얼로그 닫기
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    // 상태 업데이트
                    setState(() {
                      _statusMessage = '선수 제거 실패: $e';
                    });

                    // 오류 메시지 표시
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('예상치 못한 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    debugPrint('----- 그룹에서 선수 제거 종료 -----');
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('제거'),
              ),
            ],
          ),
    );
  }

  // 매치 삭제 다이얼로그
  Future<void> _confirmDeleteMatch(domain.MatchModel match) async {
    final String teamAName = match.teamAName ?? '팀 A';
    final String teamBName = match.teamBName ?? '팀 B';

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('매치 삭제'),
            content: Text('$teamAName vs $teamBName 매치를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  final deleteMatchUseCase = getIt<DeleteMatchUseCase>();

                  // 디버깅 정보
                  debugPrint('----- 매치 삭제 시작 -----');
                  debugPrint(
                    'Screen: 매치 삭제 기능 시작 - 매치 ID: ${match.id}, 팀: $teamAName vs $teamBName',
                  );

                  try {
                    final result = await deleteMatchUseCase.execute(match.id);

                    // 디버깅 정보
                    debugPrint('Screen: UseCase 실행 결과 - $result');

                    // 항상 다이얼로그를 닫고
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    if (result.isSuccess) {
                      // 성공 처리
                      debugPrint('Screen: 매치 삭제 성공');
                      setState(() {
                        _statusMessage = '매치 삭제됨: $teamAName vs $teamBName';
                      });

                      // 선택된 토너먼트의 매치 목록 갱신
                      if (_selectedTournamentId != null) {
                        _loadMatchesInTournament(_selectedTournamentId!);
                      }

                      // 성공 메시지 표시
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '매치가 삭제되었습니다: $teamAName vs $teamBName',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } else {
                      // 에러 메시지 표시
                      final error = result.error;
                      debugPrint('Screen: 매치 삭제 실패 - $error');
                      setState(() {
                        _statusMessage = error.message;
                      });

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error.message),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    // 예상치 못한 예외 처리
                    debugPrint('Screen: 예상치 못한 예외 발생 - $e');

                    // 다이얼로그 닫기
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }

                    // 상태 업데이트
                    setState(() {
                      _statusMessage = '예상치 못한 오류: $e';
                    });

                    // 오류 메시지 표시
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('예상치 못한 오류가 발생했습니다: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    debugPrint('----- 매치 삭제 종료 -----');
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('삭제'),
              ),
            ],
          ),
    );
  }

  // 매치 생성 함수 추가
  Future<void> _createMatch() async {
    if (_tournaments.isEmpty) {
      setState(() {
        _statusMessage = '토너먼트가 필요합니다';
      });
      return;
    }

    if (_teams.length < 2) {
      setState(() {
        _statusMessage = '최소 두 개의 팀이 필요합니다';
      });
      return;
    }

    int? selectedTournamentId;
    int? selectedTeamAId;
    int? selectedTeamBId;

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('매치 생성'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 토너먼트 선택 드롭다운
                      DropdownButtonFormField<int>(
                        value: selectedTournamentId,
                        hint: const Text('토너먼트 선택'),
                        items:
                            _tournaments.map((tournament) {
                              return DropdownMenuItem<int>(
                                value: tournament.id,
                                child: Text(tournament.title),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedTournamentId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // 팀 A 선택 드롭다운
                      DropdownButtonFormField<int>(
                        value: selectedTeamAId,
                        hint: const Text('팀 A 선택'),
                        items:
                            _teams.map((team) {
                              return DropdownMenuItem<int>(
                                value: team.team.id,
                                child: Text(team.teamName),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedTeamAId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // 팀 B 선택 드롭다운
                      DropdownButtonFormField<int>(
                        value: selectedTeamBId,
                        hint: const Text('팀 B 선택'),
                        items:
                            _teams.map((team) {
                              return DropdownMenuItem<int>(
                                value: team.team.id,
                                child: Text(team.teamName),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedTeamBId = value;
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // 입력 검증
                        if (selectedTournamentId == null ||
                            selectedTeamAId == null ||
                            selectedTeamBId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('모든 필드를 선택해주세요.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        if (selectedTeamAId == selectedTeamBId) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('같은 팀으로 매치를 구성할 수 없습니다.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // 팀 이름 가져오기
                        final teamA = _teams.firstWhere(
                          (t) => t.team.id == selectedTeamAId,
                        );
                        final teamB = _teams.firstWhere(
                          (t) => t.team.id == selectedTeamBId,
                        );

                        final createMatchUseCase = getIt<CreateMatchUseCase>();

                        // 디버깅 정보
                        debugPrint('----- 매치 생성 시작 -----');
                        debugPrint(
                          'Screen: 매치 생성 기능 시작 - '
                          '토너먼트: $selectedTournamentId, '
                          '팀A: $selectedTeamAId(${teamA.teamName}), '
                          '팀B: $selectedTeamBId(${teamB.teamName})',
                        );

                        try {
                          final result = await createMatchUseCase.execute(
                            CreateMatchParams(
                              tournamentId: selectedTournamentId!,
                              teamAId: selectedTeamAId!,
                              teamBId: selectedTeamBId!,
                              teamAName: teamA.teamName,
                              teamBName: teamB.teamName,
                            ),
                          );

                          // 디버깅 정보
                          debugPrint('Screen: UseCase 실행 결과 - $result');

                          // 다이얼로그 닫기
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }

                          if (result.isSuccess) {
                            // 성공 처리
                            final match = result.value;
                            debugPrint('Screen: 매치 생성 성공 - ID: ${match.id}');
                            setState(() {
                              _statusMessage =
                                  '매치 생성됨: ${teamA.teamName} vs ${teamB.teamName}';
                            });

                            // 선택된 토너먼트의 매치 목록 갱신
                            if (selectedTournamentId == _selectedTournamentId) {
                              if (selectedTournamentId != null) {
                                _loadMatchesInTournament(
                                  selectedTournamentId as int,
                                );
                              }
                            }

                            // 성공 메시지 표시
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '매치가 생성되었습니다: ${teamA.teamName} vs ${teamB.teamName}',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            // 에러 처리
                            final error = result.error;
                            debugPrint('Screen: 매치 생성 실패 - $error');
                            setState(() {
                              _statusMessage = error.message;
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error.message),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          // 예외 처리
                          debugPrint('Screen: 예상치 못한 예외 발생 - $e');

                          if (context.mounted) {
                            Navigator.of(context).pop();

                            setState(() {
                              _statusMessage = '예상치 못한 오류: $e';
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('예상치 못한 오류가 발생했습니다: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } finally {
                          debugPrint('----- 매치 생성 종료 -----');
                        }
                      },
                      child: const Text('생성'),
                    ),
                  ],
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DB 테스트'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '선수'),
            Tab(text: '그룹'),
            Tab(text: '팀'),
            Tab(text: '토너먼트'),
            Tab(text: '매치'), // 매치 탭 추가
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '상태: $_statusMessage',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // 선택된 그룹이 있을 때 상세 정보 표시
          if (_selectedGroupId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${_groups.firstWhere((g) => g.id == _selectedGroupId).name} 소속 선수',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedGroupId = null;
                            _playersInSelectedGroup = [];
                          });
                        },
                      ),
                    ],
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _playersInSelectedGroup.isEmpty
                            ? const Center(child: Text('선수가 없습니다'))
                            : ListView.builder(
                              itemCount: _playersInSelectedGroup.length,
                              itemBuilder: (context, index) {
                                final player = _playersInSelectedGroup[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(player.name),
                                  subtitle: Text('ID: ${player.id}'),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _confirmRemovePlayerFromGroup(
                                          player,
                                          _selectedGroupId!,
                                        ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),

          // 선택된 토너먼트가 있을 때 매치 목록 표시
          if (_selectedTournamentId != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${_tournaments.firstWhere((t) => t.id == _selectedTournamentId).title} 매치 목록',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _selectedTournamentId = null;
                            _matchesInSelectedTournament = [];
                          });
                        },
                      ),
                    ],
                  ),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        _matchesInSelectedTournament.isEmpty
                            ? const Center(child: Text('매치가 없습니다'))
                            : ListView.builder(
                              itemCount: _matchesInSelectedTournament.length,
                              itemBuilder: (context, index) {
                                final match =
                                    _matchesInSelectedTournament[index];
                                final teamAName = match.teamAName ?? '팀 A';
                                final teamBName = match.teamBName ?? '팀 B';
                                final scoreText =
                                    (match.scoreA != null &&
                                            match.scoreB != null)
                                        ? '${match.scoreA} : ${match.scoreB}'
                                        : '경기 전';

                                return ListTile(
                                  dense: true,
                                  title: Text('$teamAName vs $teamBName'),
                                  subtitle: Text(
                                    '순서: ${match.order ?? "미지정"}, 점수: $scoreText',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _confirmDeleteMatch(match),
                                  ),
                                );
                              },
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
                // 선수 탭
                ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    return ListTile(
                      title: Text(player.name),
                      subtitle: Text('ID: ${player.id}'),
                      onLongPress: () => _confirmDeletePlayer(player),
                    );
                  },
                ),

                // 그룹 탭
                ListView.builder(
                  itemCount: _groups.length,
                  itemBuilder: (context, index) {
                    final group = _groups[index];
                    return ListTile(
                      title: Text(group.name),
                      subtitle: Text('ID: ${group.id}'),
                      onTap: () => _loadPlayersInGroup(group.id),
                      onLongPress: () => _confirmDeleteGroup(group),
                    );
                  },
                ),

                // 팀 탭
                ListView.builder(
                  itemCount: _teams.length,
                  itemBuilder: (context, index) {
                    final team = _teams[index];
                    return ListTile(
                      title: Text(team.teamName),
                      subtitle: Text('ID: ${team.team.id}'),
                      onLongPress: () => _confirmDeleteTeam(team),
                    );
                  },
                ),

                // 토너먼트 탭
                ListView.builder(
                  itemCount: _tournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = _tournaments[index];
                    return ListTile(
                      title: Text(tournament.title),
                      subtitle: Text(
                        '날짜: ${tournament.date.toLocal().toString().split(' ')[0]}',
                      ),
                      onTap: () => _loadMatchesInTournament(tournament.id),
                      onLongPress: () => _confirmDeleteTournament(tournament),
                    );
                  },
                ),

                // 매치 탭
                _matchesInSelectedTournament.isEmpty
                    ? const Center(child: Text('토너먼트를 선택하여 매치를 확인하세요'))
                    : ListView.builder(
                      itemCount: _matchesInSelectedTournament.length,
                      itemBuilder: (context, index) {
                        final match = _matchesInSelectedTournament[index];
                        final teamAName = match.teamAName ?? '팀 A';
                        final teamBName = match.teamBName ?? '팀 B';
                        final scoreText =
                            (match.scoreA != null && match.scoreB != null)
                                ? '${match.scoreA} : ${match.scoreB}'
                                : '경기 전';

                        return ListTile(
                          title: Text('$teamAName vs $teamBName'),
                          subtitle: Text(
                            '순서: ${match.order ?? "미지정"}, 점수: $scoreText',
                          ),
                          onLongPress: () => _confirmDeleteMatch(match),
                        );
                      },
                    ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 8.0,
          children: [
            ElevatedButton(onPressed: _addPlayer, child: const Text('선수 추가')),
            ElevatedButton(onPressed: _addGroup, child: const Text('그룹 추가')),
            ElevatedButton(
              onPressed: _addPlayerToGroup,
              child: const Text('선수→그룹'),
            ),
            ElevatedButton(onPressed: _createTeam, child: const Text('팀 생성')),
            ElevatedButton(
              onPressed: _createTournament,
              child: const Text('토너먼트 생성'),
            ),
            ElevatedButton(onPressed: _createMatch, child: const Text('매치 생성')),
          ],
        ),
      ),
    );
  }
}
