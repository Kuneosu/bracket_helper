import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class AddPlayerBottomSheet extends StatefulWidget {
  const AddPlayerBottomSheet({super.key});

  @override
  State<AddPlayerBottomSheet> createState() => _AddPlayerBottomSheetState();
}

class _AddPlayerBottomSheetState extends State<AddPlayerBottomSheet> {
  // 선택된 그룹 상태 관리
  final List<String> groups = ['그룹원 A', '그룹원 B', '그룹원 C', '그룹원 D'];
  final Map<String, bool> selectedGroups = {};

  // 테스트용 그룹 리스트
  final List<String> groupList = ['마코 클럽', '테니스 동호회', '직장 동료', '대학 친구', '가족'];

  // 현재 선택된 그룹
  String selectedGroup = '마코 클럽';

  @override
  void initState() {
    super.initState();
    // 초기 선택 상태 설정 (A와 D가 선택된 상태)
    for (var group in groups) {
      selectedGroups[group] = group == '그룹원 A' || group == '그룹원 D';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 헤더
          _buildHeader(),

          const SizedBox(height: 16),

          // 선수명 입력 필드
          _buildNameInputSection(),

          const SizedBox(height: 24),

          // 저장된 선수 불러오기 섹션
          _buildSavedPlayersSection(),

          const SizedBox(height: 20),

          // 하단 버튼
          DefaultButton(
            text: '선수 추가하기',
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // 키보드에 가려지지 않게 하단 패딩 추가
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 상단 헤더 위젯
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('선수 추가하기', style: TST.largeTextBold),
        InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              '닫기',
              style: TST.mediumTextRegular.copyWith(color: CST.gray3),
            ),
          ),
        ),
      ],
    );
  }

  // 선수명 입력 영역
  Widget _buildNameInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('띄어쓰기로 추가하기', style: TST.mediumTextBold),
        const SizedBox(height: 8),
        DefaultTextField(hintText: '선수명을 입력해세요. (성빈 승엽 준우...)'),
      ],
    );
  }

  // 저장된 선수 불러오기 영역
  Widget _buildSavedPlayersSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('저장된 선수 불러오기', style: TST.mediumTextBold),
              _buildGroupDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          // 그룹 목록
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) => _buildGroupItem(groups[index]),
            ),
          ),
        ],
      ),
    );
  }

  // 그룹 드롭다운 버튼
  Widget _buildGroupDropdown() {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (context) =>
              groupList
                  .map(
                    (group) => PopupMenuItem<String>(
                      value: group,
                      child: Text(
                        group,
                        style: TST.mediumTextRegular.copyWith(
                          color:
                              group == selectedGroup
                                  ? CST.primary100
                                  : Colors.black,
                          fontWeight:
                              group == selectedGroup
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                  .toList(),
      onSelected: (value) {
        setState(() {
          selectedGroup = value;
          // 그룹 변경 시 표시되는 선수 목록 업데이트 로직을 여기에 추가할 수 있습니다.
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: CST.gray3),
          borderRadius: BorderRadius.circular(8),
        ),
        width: 140,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                selectedGroup,
                style: TST.mediumTextRegular,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: CST.gray3),
          ],
        ),
      ),
    );
  }

  // 그룹 아이템 위젯
  Widget _buildGroupItem(String groupName) {
    final isSelected = selectedGroups[groupName] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          // 선택 상태 토글
          selectedGroups[groupName] = !isSelected;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? CST.primary20 : CST.gray4,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(groupName, style: TST.mediumTextRegular),
            _buildSelectionCircle(isSelected),
          ],
        ),
      ),
    );
  }

  // 선택 원형 표시
  Widget _buildSelectionCircle(bool isSelected) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? CST.primary100 : CST.gray3,
          width: 2,
        ),
      ),
      child:
          isSelected
              ? Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: CST.primary100,
                  ),
                ),
              )
              : null,
    );
  }
}
