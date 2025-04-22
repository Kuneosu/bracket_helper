import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

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
    }

    // 편집 모드 종료
    setState(() {
      _isEditing = false;
    });
  }

  // 선수 삭제
  void _deletePlayer() {
    // 다이얼로그 없이 바로 삭제
    widget.onAction(CreateTournamentAction.removePlayer(widget.player.id));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: CST.primary40, width: 1),
      ),
      child: InkWell(
        onTap: _toggleEditMode,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // 선수 번호 표시 (원형 배지)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [CST.primary80, CST.primary100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CST.primary60.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    "${widget.index}",
                    style: TST.mediumTextBold.copyWith(color: Colors.white),
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
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: CST.primary100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: CST.primary100,
                                  width: 2,
                                ),
                              ),
                              hintText: '선수 이름 입력',
                              hintStyle: TextStyle(color: CST.gray3),
                              filled: true,
                              fillColor: Colors.white,
                              isDense: true,
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _saveName(),
                            style: TST.mediumTextBold.copyWith(
                              color: CST.gray1,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.check_circle,
                            color: CST.primary100,
                            size: 28,
                          ),
                          onPressed: _saveName,
                          tooltip: '저장',
                          padding: EdgeInsets.all(8),
                        ),
                        IconButton(
                          icon: Icon(Icons.cancel, color: CST.error, size: 28),
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _nameController.text = widget.player.name;
                            });
                          },
                          tooltip: '취소',
                          padding: EdgeInsets.all(8),
                        ),
                      ],
                    ),
                  )
                  : Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.player.name,
                                style: TST.mediumTextBold.copyWith(
                                  color: CST.gray1,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '탭하여 이름 수정',
                                style: TST.smallTextRegular.copyWith(
                                  color: CST.gray3,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // 편집 버튼
                        Container(
                          decoration: BoxDecoration(
                            color: CST.primary20,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: EdgeInsets.only(right: 8),
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: CST.primary100,
                            ),
                            onPressed: _toggleEditMode,
                            tooltip: '편집',
                            constraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                        // 삭제 버튼
                        Container(
                          decoration: BoxDecoration(
                            color: CST.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: CST.error,
                            ),
                            onPressed: _deletePlayer,
                            tooltip: '삭제',
                            constraints: BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
