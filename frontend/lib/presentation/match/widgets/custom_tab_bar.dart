import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/core/services/language_manager.dart';
import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: CST.primary20,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        indicator: BoxDecoration(
          color: CST.primary100,
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: CST.white,
        unselectedLabelColor: CST.gray2,
        labelStyle: TST.normalTextBold.copyWith(
          fontSize: LanguageManager.isKorean() ? null : 13,
        ),
        unselectedLabelStyle: TST.normalTextRegular.copyWith(
          fontSize: LanguageManager.isKorean() ? null : 13,
        ),
        dividerColor: Colors.transparent,
        tabs: [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: LanguageManager.isKorean() ? 8 : 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.sports_kabaddi, size: 16),
                  SizedBox(width: LanguageManager.isKorean() ? 8 : 4),
                  Flexible(
                    child: Text(
                      AppStrings.bracketTab,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: LanguageManager.isKorean() ? 8 : 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.leaderboard, size: 16),
                  SizedBox(width: LanguageManager.isKorean() ? 8 : 4),
                  Flexible(
                    child: Text(
                      AppStrings.currentRankingTab,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 