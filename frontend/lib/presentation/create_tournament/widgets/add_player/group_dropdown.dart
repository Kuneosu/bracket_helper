import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/domain/model/group_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

/// 그룹 선택 드롭다운 위젯
class GroupDropdown extends StatelessWidget {
  final List<GroupModel> groups;
  final int? selectedGroupId;
  final Function(int?) onGroupSelected;
  final int allGroupsConstant;

  const GroupDropdown({
    super.key,
    required this.groups,
    required this.selectedGroupId,
    required this.onGroupSelected,
    this.allGroupsConstant = -999,
  });

  @override
  Widget build(BuildContext context) {
    final hasGroups = groups.isNotEmpty;

    return Expanded(
      child:
          hasGroups
              ? DropdownButtonFormField<int?>(
                value: selectedGroupId,
                hint: Row(
                  children: [
                    Icon(Icons.group_outlined, size: 16, color: CST.gray2),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.selectGroup,
                      style: TextStyle(color: CST.gray2),
                    ),
                  ],
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CST.gray4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CST.gray4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: CST.primary100, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                iconSize: 30,
                icon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.arrow_drop_down, color: CST.primary100),
                ),
                dropdownColor: Colors.white,
                elevation: 3,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                items: [
                  // 전체 그룹 옵션
                  DropdownMenuItem<int?>(
                    value: allGroupsConstant,
                    child: Row(
                      children: [
                        Icon(Icons.group_outlined, size: 16, color: CST.gray2),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.allGroups,
                          style: TextStyle(color: CST.gray2),
                        ),
                      ],
                    ),
                  ),
                  // 각 그룹별 옵션
                  ...groups.map(
                    (group) => DropdownMenuItem<int?>(
                      value: group.id,
                      child: Row(
                        children: [
                          Icon(Icons.group, size: 16, color: CST.primary100),
                          const SizedBox(width: 8),
                          Text(
                            group.name,
                            style: TextStyle(
                              color: CST.gray1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                onChanged: onGroupSelected,
              )
              : Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: CST.gray4),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.group_off, size: 16, color: CST.gray3),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.noSavedGroups,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CST.gray2),
                    ),
                  ],
                ),
              ),
    );
  }
}
