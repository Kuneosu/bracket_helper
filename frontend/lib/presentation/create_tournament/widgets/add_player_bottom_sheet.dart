import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class AddPlayerBottomSheet extends StatefulWidget {
  final Function(CreateTournamentAction) onAction;

  const AddPlayerBottomSheet({super.key, required this.onAction});

  @override
  State<AddPlayerBottomSheet> createState() => _AddPlayerBottomSheetState();
}

class _AddPlayerBottomSheetState extends State<AddPlayerBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  bool _isNameValid = false;
  String _selectedGroup = '전체';

  // 임시 데이터 (실제로는 DB에서 가져와야 함)
  final List<String> _groups = ['전체', '테니스 동호회', '직장 동료', '대학 친구', '가족'];
  final Map<String, List<Map<String, dynamic>>> _groupMembers = {
    '전체': [
      {'id': 1, 'name': '김철수', 'isSelected': false},
      {'id': 2, 'name': '이영희', 'isSelected': false},
      {'id': 3, 'name': '박지민', 'isSelected': false},
      {'id': 4, 'name': '최수진', 'isSelected': false},
    ],
    '테니스 동호회': [
      {'id': 1, 'name': '김철수', 'isSelected': false},
      {'id': 5, 'name': '정민석', 'isSelected': false},
    ],
    '직장 동료': [
      {'id': 2, 'name': '이영희', 'isSelected': false},
      {'id': 6, 'name': '한지훈', 'isSelected': false},
    ],
    '대학 친구': [
      {'id': 3, 'name': '박지민', 'isSelected': false},
      {'id': 7, 'name': '송태양', 'isSelected': false},
    ],
    '가족': [
      {'id': 4, 'name': '최수진', 'isSelected': false},
      {'id': 8, 'name': '강혜린', 'isSelected': false},
    ],
  };

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

    // 피드백 메시지 표시
    if (names.length > 1) {
      // 바텀시트를 닫기 전에 스낵바 표시를 위해 컨텍스트 저장
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      Navigator.pop(context); // 바텀시트 닫기

      // 추가된 선수 수 표시
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${names.length}명의 선수가 추가되었습니다.'),
          backgroundColor: CST.primary100,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      Navigator.pop(context); // 바텀시트 닫기
    }
  }

  void _togglePlayerSelection(int id) {
    setState(() {
      // 선택한 그룹의 멤버 중에서 해당 ID를 가진 플레이어의 선택 상태를 토글
      final members = _groupMembers[_selectedGroup]!;
      for (var i = 0; i < members.length; i++) {
        if (members[i]['id'] == id) {
          members[i]['isSelected'] = !members[i]['isSelected'];
        }
      }
    });
  }

  void _addSelectedPlayers() {
    final selectedPlayers =
        _groupMembers[_selectedGroup]!
            .where((player) => player['isSelected'] == true)
            .toList();

    if (selectedPlayers.isEmpty) return;

    // 선택한 플레이어들을 추가하는 로직 구현
    for (final player in selectedPlayers) {
      widget.onAction(CreateTournamentAction.addPlayer(player['name']));
    }

    // 피드백 메시지를 위해 컨텍스트 저장
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    Navigator.pop(context);

    // 추가된 선수 수 표시
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('${selectedPlayers.length}명의 선수가 추가되었습니다.'),
        backgroundColor: CST.primary100,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "선수 추가",
                style: TST.headerTextBold.copyWith(color: CST.primary100),
              ),
              IconButton(
                icon: Icon(Icons.close, color: CST.gray2),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          // 탭 선택 UI
          DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  tabs: [Tab(text: "직접 입력"), Tab(text: "저장된 선수")],
                  labelColor: CST.primary100,
                  unselectedLabelColor: CST.gray2,
                  indicatorColor: CST.primary100,
                  labelStyle: TST.normalTextBold,
                  unselectedLabelStyle: TST.normalTextRegular,
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: TabBarView(
                    children: [
                      // 1. 직접 입력 탭
                      _buildManualInputTab(),

                      // 2. 저장된 선수 탭
                      _buildSavedPlayersTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 직접 입력 탭 UI
  Widget _buildManualInputTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("선수 이름", style: TST.normalTextBold.copyWith(color: CST.gray1)),
        SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: '선수 이름을 입력해주세요',
            hintStyle: TST.mediumTextRegular.copyWith(color: CST.gray3),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: CST.gray3),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CST.gray3),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: CST.primary100, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.person, color: CST.primary100),
            filled: true,
            fillColor: Colors.white,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _addPlayer(),
        ),
        SizedBox(height: 8),
        Text(
          '공백으로 구분하여 여러 명을 한 번에 추가할 수 있습니다. (예: 영희 철수 훈이)',
          style: TST.smallTextRegular.copyWith(color: CST.gray2),
        ),
        SizedBox(height: 20),
        DefaultButton(
          text: "추가하기",
          onTap: _addPlayer,
          color: _isNameValid ? CST.primary100 : CST.gray3,
          width: double.infinity,
        ),
      ],
    );
  }

  // 저장된 선수 탭 UI
  Widget _buildSavedPlayersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 그룹 선택 드롭다운
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("그룹 선택", style: TST.normalTextBold.copyWith(color: CST.gray1)),
            _buildGroupDropdown(),
          ],
        ),
        SizedBox(height: 16),

        // 선수 목록 (스크롤 가능)
        Expanded(
          child: ListView.builder(
            itemCount: _groupMembers[_selectedGroup]!.length,
            itemBuilder: (context, index) {
              final player = _groupMembers[_selectedGroup]![index];
              return _buildPlayerItem(player);
            },
          ),
        ),

        // 선택 완료 버튼
        SizedBox(height: 16),
        DefaultButton(
          text: "선택한 선수 추가하기",
          onTap: _addSelectedPlayers,
          color: CST.primary100,
          width: double.infinity,
        ),
      ],
    );
  }

  // 그룹 드롭다운
  Widget _buildGroupDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: CST.primary100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: _selectedGroup,
        icon: Icon(Icons.arrow_drop_down, color: CST.primary100),
        iconSize: 24,
        elevation: 8,
        style: TST.normalTextRegular.copyWith(color: CST.primary100),
        underline: Container(height: 0),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedGroup = newValue;
            });
          }
        },
        items:
            _groups.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  // 선수 항목 위젯
  Widget _buildPlayerItem(Map<String, dynamic> player) {
    final bool isSelected = player['isSelected'] ?? false;

    return InkWell(
      onTap: () => _togglePlayerSelection(player['id']),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? CST.primary20 : Colors.white,
          border: Border.all(color: isSelected ? CST.primary100 : CST.gray3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 체크박스
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? CST.primary100 : CST.gray3,
                  width: 2,
                ),
                color: isSelected ? CST.primary100 : Colors.white,
              ),
              child:
                  isSelected
                      ? Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
            ),
            SizedBox(width: 16),

            // 선수 이름
            Expanded(
              child: Text(
                player['name'],
                style: TST.normalTextRegular.copyWith(
                  color: isSelected ? CST.primary100 : CST.gray1,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
