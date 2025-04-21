import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/add_player_bottom_sheet.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 로컬에서 간단하게 사용할 임시 선수 클래스

class AddPlayerScreen extends StatelessWidget {
  final TournamentModel tournament;
  final List<PlayerModel> players;
  final Function(CreateTournamentAction) onAction;

  const AddPlayerScreen({
    super.key,
    required this.tournament,
    required this.players,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    // 실제 PlayerModel 리스트 사용
    final displayPlayers = players.isEmpty ? [] : players;

    debugPrint('AddPlayerScreen - build: 받은 선수 목록 ${players.length}명');
    if (players.isNotEmpty) {
      debugPrint(
        'AddPlayerScreen - 선수 목록: ${players.map((p) => "${p.id}:${p.name}").join(', ')}',
      );
    }

    // Expanded를 제거하고 일반 Column 사용
    return Column(
      children: [
        // 상단 헤더
        _buildHeader(context, displayPlayers.length),

        // 목록 부분은 고정 높이의 Container로 변경하고 키보드 대응
        Expanded(
          child: ListView.builder(
            // 오버스크롤 동작 제어를 위한 physics 설정
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: displayPlayers.length + 1,
            itemBuilder: (context, index) {
              if (index == displayPlayers.length) {
                return _buildAddPlayerItem(context);
              } else {
                return _buildPlayerItem(displayPlayers[index], index + 1);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 20,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DefaultButton(
                text: '이전',
                onTap: () {
                  // pop() 대신 go() 사용
                  debugPrint(
                    'AddPlayerScreen - 이전 버튼 클릭: 현재 선수 수 ${players.length}명',
                  );
                  context.go(
                    '${RoutePaths.createTournament}${RoutePaths.tournamentInfo}',
                  );
                },
                width: 70,
              ),
              DefaultButton(
                text: '다음',
                onTap: () {
                  // 프로세스 진행 상태 업데이트
                  debugPrint(
                    'AddPlayerScreen - 다음 버튼 클릭: 현재 선수 수 ${players.length}명',
                  );
                  onAction(CreateTournamentAction.updateProcess(2));

                  context.go(
                    '${RoutePaths.createTournament}${RoutePaths.editMatch}',
                  );
                },
                width: 70,
                // 선수가 없으면 버튼 비활성화
                color: displayPlayers.isEmpty ? CST.gray3 : CST.primary100,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 상단 헤더 위젯
  Widget _buildHeader(BuildContext context, int playerCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: CST.gray3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("참가 인원 수 : $playerCount 명", style: TST.largeTextRegular),
          DefaultButton(
            text: "선수 추가하기",
            onTap: () {
              // 바텀시트 표시
              _showAddPlayerBottomSheet(context);
            },
            width: 133,
            textStyle: TST.normalTextBold,
          ),
        ],
      ),
    );
  }

  // 선수 추가 아이템
  Widget _buildAddPlayerItem(BuildContext context) {
    return InkWell(
      onTap: () {
        _showAddPlayerBottomSheet(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: CST.primary40,
          border: Border(bottom: BorderSide(color: CST.gray3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: CST.primary100),
            SizedBox(width: 8),
            Text(
              "선수 추가하기",
              style: TST.mediumTextBold.copyWith(color: CST.primary100),
            ),
          ],
        ),
      ),
    );
  }

  // 선수 추가 바텀시트 표시 메서드
  void _showAddPlayerBottomSheet(BuildContext context) {
    debugPrint('AddPlayerScreen - 선수 추가 바텀시트 표시: 현재 선수 수 ${players.length}명');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 키보드가 올라올 때 바텀시트가 위로 올라가도록 설정
      backgroundColor: Colors.transparent, // 배경을 투명하게 설정하여 모서리 둥글게 보이도록
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AddPlayerBottomSheet(onAction: onAction),
          ),
    );
  }

  // 선수 항목 위젯
  Widget _buildPlayerItem(PlayerModel player, int index) {
    return Dismissible(
      key: Key('player_${player.id}'),
      background: Container(
        color: CST.error,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onAction(CreateTournamentAction.removePlayer(player.id));
      },
      child: Builder(
        // Builder 위젯을 사용하여 현재 BuildContext를 얻음
        builder: (BuildContext context) {
          return InlineEditablePlayerItem(
            player: player,
            index: index,
            onAction: onAction,
          );
        },
      ),
    );
  }
}

// 인라인 편집 가능한 선수 아이템 위젯 (클래스 외부로 이동)
class InlineEditablePlayerItem extends StatefulWidget {
  final PlayerModel player;
  final int index;
  final Function(CreateTournamentAction) onAction;

  const InlineEditablePlayerItem({
    super.key,
    required this.player,
    required this.index,
    required this.onAction,
  });

  @override
  State<InlineEditablePlayerItem> createState() =>
      _InlineEditablePlayerItemState();
}

class _InlineEditablePlayerItemState extends State<InlineEditablePlayerItem> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 편집 모드 토글
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        // 편집 모드 시작 시 현재 이름으로 컨트롤러 초기화
        _nameController.text = widget.player.name;
        // 키보드가 뜰 때 현재 항목이 가려지지 않도록 스크롤 위치 조정
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // 에디터에 포커스가 들어간 후 스크롤 위치 조정
          Scrollable.ensureVisible(
            context,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.5, // 화면 중앙에 위치하도록
          );
        });
      }
    });
  }

  // 이름 저장
  void _saveName() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      // 빈 이름이면 무시하고 편집 모드 종료
      setState(() {
        _isEditing = false;
        _nameController.text = widget.player.name; // 원래 이름으로 복원
      });
      return;
    }

    if (newName != widget.player.name) {
      // 이름이 변경된 경우에만 업데이트 액션 호출
      final updatedPlayer = PlayerModel(id: widget.player.id, name: newName);

      widget.onAction(CreateTournamentAction.updatePlayer(updatedPlayer));

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('선수 정보가 수정되었습니다.'),
          backgroundColor: CST.primary100,
          duration: Duration(seconds: 2),
        ),
      );
    }

    // 편집 모드 종료
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleEditMode,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: CST.gray3)),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CST.primary40,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${widget.index}",
                  style: TST.mediumTextBold.copyWith(color: CST.primary100),
                ),
              ),
            ),
            SizedBox(width: 16),

            // 편집 모드에 따라 다른 위젯 표시
            _isEditing
                ? Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          autofocus: true,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: CST.primary100),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                color: CST.primary100,
                                width: 2,
                              ),
                            ),
                            // 키보드가 뜰 때 오버플로우 방지를 위한 설정
                            isDense: true,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _saveName(),
                          style: TST.mediumTextBold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: CST.primary100),
                        onPressed: _saveName,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: CST.error),
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _nameController.text =
                                widget.player.name; // 원래 이름으로 복원
                          });
                        },
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.all(4),
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                )
                : Expanded(
                  child: Text(widget.player.name, style: TST.mediumTextBold),
                ),

            // 편집 모드가 아닐 때만 편집 아이콘 표시
            if (!_isEditing) Icon(Icons.edit, size: 16, color: CST.primary100),
          ],
        ),
      ),
    );
  }
}
