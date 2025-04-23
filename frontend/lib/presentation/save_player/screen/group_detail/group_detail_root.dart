import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/presentation/save_player/save_player_action.dart';
import 'package:bracket_helper/presentation/save_player/screen/group_detail/group_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:bracket_helper/domain/model/group_model.dart';

class GroupDetailRoot extends StatefulWidget {
  final int groupId;
  final Future<GroupModel?> Function(int) getGroupById;
  final Future<List<PlayerModel>> Function(int) getPlayersInGroup;
  final Function(SavePlayerAction) onAction;

  const GroupDetailRoot({
    super.key,
    required this.groupId,
    required this.getGroupById,
    required this.getPlayersInGroup,
    required this.onAction,
  });

  @override
  State<GroupDetailRoot> createState() => _GroupDetailRootState();
}

class _GroupDetailRootState extends State<GroupDetailRoot> {
  late Future<GroupModel?> groupFuture;
  late Future<List<PlayerModel>> playersFuture;
  // 마지막 갱신 시간 (자동 새로고침 방지용)
  DateTime _lastRefreshTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    debugPrint(
      'GroupDetailRoot: 그룹 및 선수 데이터 로드 시작 (groupId: ${widget.groupId})',
    );

    // 마지막 갱신 시간 업데이트
    _lastRefreshTime = DateTime.now();

    groupFuture = widget.getGroupById(widget.groupId);
    playersFuture = widget.getPlayersInGroup(widget.groupId);

    // 선수 데이터가 로드되면 콘솔에 로그
    playersFuture
        .then((players) {
          debugPrint('GroupDetailRoot: 선수 데이터 로드 완료 - ${players.length}명');
        })
        .catchError((error) {
          debugPrint('GroupDetailRoot: 선수 데이터 로드 실패 - $error');
        });
  }

  // 데이터 새로고침 (중복 호출 방지 로직 포함)
  void _refreshData() {
    // 마지막 갱신으로부터 500ms 이내면 무시 (중복 갱신 방지)
    final now = DateTime.now();
    final timeDiff = now.difference(_lastRefreshTime).inMilliseconds;

    if (timeDiff < 500) {
      debugPrint('GroupDetailRoot: 갱신 요청 무시 ($timeDiff ms)');
      return;
    }

    debugPrint('GroupDetailRoot: 데이터 새로고침 (마지막 갱신 후 $timeDiff ms)');
    setState(() {
      _initData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<GroupModel?>(
      future: groupFuture,
      builder: (context, groupSnapshot) {
        if (groupSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (groupSnapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  '오류가 발생했습니다',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  '${groupSnapshot.error}',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _refreshData,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        }

        final group = groupSnapshot.data;

        // 그룹 정보가 없는 경우
        if (group == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  '그룹을 찾을 수 없습니다',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  '그룹이 삭제되었거나 접근할 수 없습니다',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // 이전 화면으로 돌아가기
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('그룹 목록으로 돌아가기'),
                ),
              ],
            ),
          );
        }

        return FutureBuilder<List<PlayerModel>>(
          future: playersFuture,
          builder: (context, playersSnapshot) {
            if (playersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (playersSnapshot.hasError) {
              return Center(
                child: Text(
                  '선수 목록을 불러오는 중 오류가 발생했습니다: ${playersSnapshot.error}',
                ),
              );
            }

            final players = playersSnapshot.data ?? [];

            return GroupDetailScreen(
              group: group,
              players: players,
              onAction: (action) {
                debugPrint('GroupDetailRoot - 액션 수신: $action');

                // 선수 저장 액션 처리 - 빈 이름의 경우 다이얼로그 표시
                if (action is OnSavePlayer && action.name.isEmpty) {
                  _showAddPlayerDialog(context, group);
                  return;
                }

                // 나머지 액션 처리
                _handleAction(action);
              },
            );
          },
        );
      },
    );
  }

  // 액션 처리 메서드
  void _handleAction(SavePlayerAction action) {
    debugPrint('GroupDetailRoot - 액션 처리: $action');

    // onRefresh 액션인 경우 로컬 메서드 호출
    if (action is OnRefresh) {
      _refreshData();
      return;
    }

    // SavePlayer, DeletePlayer, UpdatePlayer 액션은 상위로 전달하고 데이터 갱신
    if (action is OnSavePlayer ||
        action is OnDeletePlayer ||
        action is OnUpdatePlayer) {
      // 액션 전달
      widget.onAction(action);

      // 약간의 지연 후 데이터 갱신
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          debugPrint('GroupDetailRoot: 액션 처리 후 데이터 새로고침');
          _refreshData();
        }
      });
      return;
    }

    // 그 외 액션은 상위 컴포넌트로 전달
    widget.onAction(action);
  }

  // 선수 추가 다이얼로그
  void _showAddPlayerDialog(BuildContext context, GroupModel group) {
    final playerNameController = TextEditingController();
    final groupColor = group.color ?? Colors.blue;
    bool isNameValid = false;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 상단 아이콘
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: groupColor.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add,
                            color: groupColor,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 제목
                        Text(
                          '${group.name}에 선수 추가',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // 입력 필드
                        TextField(
                          controller: playerNameController,
                          decoration: InputDecoration(
                            labelText: '선수 이름',
                            hintText: '선수 이름을 입력하세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: groupColor,
                                width: 2,
                              ),
                            ),
                            errorText:
                                playerNameController.text.trim().isEmpty &&
                                        !isNameValid
                                    ? null
                                    : (isNameValid ? null : '선수 이름을 입력해주세요'),
                          ),
                          autofocus: true,
                          onChanged: (value) {
                            final valid = value.trim().isNotEmpty;
                            if (valid != isNameValid) {
                              setState(() {
                                isNameValid = valid;
                              });

                              // 유효성 상태 외부 업데이트 (옵션)
                              widget.onAction(
                                SavePlayerAction.onPlayerNameChanged(value),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 10),

                        // 다중 선수 추가 안내 메시지
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 16,
                                    color: groupColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '여러 선수 한 번에 추가하기',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: groupColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                '띄어쓰기로 구분하여 여러 명의 선수를 한 번에 등록할 수 있습니다.\n예: "홍길동 김철수"',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 취소 버튼
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.grey[700],
                                backgroundColor: Colors.grey[200],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                '취소',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // 추가 버튼
                            ElevatedButton(
                              onPressed:
                                  isNameValid
                                      ? () async {
                                        final playerName =
                                            playerNameController.text.trim();

                                        // 다이얼로그 닫기
                                        Navigator.of(context).pop();

                                        // 선수 이름들을 공백으로 분리
                                        final playerNames =
                                            playerName
                                                .split(' ')
                                                .where(
                                                  (name) =>
                                                      name.trim().isNotEmpty,
                                                )
                                                .toList();

                                        // 여러 선수 처리
                                        if (playerNames.length > 1) {
                                          int addedCount = 0;
                                          debugPrint(
                                            '다중 선수 추가 시작: ${playerNames.length}명',
                                          );

                                          // 여러 선수 순차적으로 추가
                                          for (final name in playerNames) {
                                            widget.onAction(
                                              SavePlayerAction.onSavePlayer(
                                                name.trim(),
                                                widget.groupId,
                                              ),
                                            );
                                            addedCount++;

                                            // 약간의 딜레이 추가
                                            await Future.delayed(
                                              const Duration(milliseconds: 100),
                                            );
                                          }

                                          debugPrint(
                                            '다중 선수 추가 완료: $addedCount명',
                                          );

                                          // 모든 선수가 추가된 후 데이터 새로고침
                                          if (mounted) {
                                            Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () {
                                                if (mounted) {
                                                  debugPrint(
                                                    '다중 선수 추가 후 데이터 새로고침',
                                                  );
                                                  _refreshData();
                                                }
                                              },
                                            );
                                          }
                                        } else {
                                          // 단일 선수 추가 (기존 방식)
                                          _handleAction(
                                            SavePlayerAction.onSavePlayer(
                                              playerName,
                                              widget.groupId,
                                            ),
                                          );
                                        }
                                      }
                                      : null, // 유효하지 않으면 버튼 비활성화
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: groupColor,
                                disabledForegroundColor: Colors.white
                                    .withValues(alpha: 0.5),
                                disabledBackgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                              ),
                              child: const Text(
                                '추가',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    ).then((_) {
      // 다이얼로그가 닫힌 후 데이터 새로고침
      if (mounted) {
        debugPrint('GroupDetailRoot: 다이얼로그 종료 후 데이터 새로고침');
        _refreshData();
      }
    });
  }
}
