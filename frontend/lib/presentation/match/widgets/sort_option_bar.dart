import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';

class SortOptionBar extends StatelessWidget {
  final String selectedOption;
  final Function(String) onSortOptionSelected;

  const SortOptionBar({
    super.key,
    required this.selectedOption,
    required this.onSortOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CST.primary20,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(AppStrings.sortBy, style: TST.smallTextBold),
          _buildSortOption(AppStrings.name, 'name'),
          _buildSortOption(AppStrings.points, 'points'),
          _buildSortOption(AppStrings.goalDifference, 'difference'),
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = value == selectedOption;
    return InkWell(
      onTap: () => onSortOptionSelected(value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CST.primary80 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TST.smallTextBold.copyWith(
            color: isSelected ? CST.white : CST.gray1,
          ),
        ),
      ),
    );
  }
} 