import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

/// 선수 이름 입력 필드 위젯
class PlayerInputField extends StatefulWidget {
  final Function(CreateTournamentAction) onAction;

  const PlayerInputField({
    super.key,
    required this.onAction,
  });

  @override
  State<PlayerInputField> createState() => _PlayerInputFieldState();
}

class _PlayerInputFieldState extends State<PlayerInputField> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
  }

  @override
  void dispose() {
    _nameController.dispose();
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

    // 입력 필드 초기화
    _nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
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
                    borderSide: BorderSide(
                      color: CST.primary100,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CST.gray4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.person_add,
                    color: CST.primary80,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8),
            // 추가 버튼
            SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                onPressed: _isNameValid ? _addPlayer : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CST.primary100,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Icon(Icons.add),
              ),
            ),
          ],
        ),
        // 안내 문구
        Padding(
          padding: const EdgeInsets.only(left: 8, top: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 12, color: CST.gray3),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  '여러 선수는 공백으로 구분해서 입력할 수 있습니다. (예: 홍길동 김철수)',
                  style: TextStyle(fontSize: 11, color: CST.gray3),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 