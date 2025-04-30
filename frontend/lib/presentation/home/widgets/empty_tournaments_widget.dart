import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';

class EmptyTournamentsWidget extends StatelessWidget {
  const EmptyTournamentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: CST.gray4,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CST.gray3.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_tennis, size: 40, color: CST.gray3),
          const SizedBox(height: 12),
          Text(
            AppStrings.noTournaments,
            style: TST.normalTextRegular.copyWith(color: CST.gray2),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.createNewTournament,
            style: TST.smallTextRegular.copyWith(color: CST.gray2),
          ),
        ],
      ),
    );
  }
} 