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