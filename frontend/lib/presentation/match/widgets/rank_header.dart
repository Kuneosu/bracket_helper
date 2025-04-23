import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class RankHeader extends StatelessWidget {
  const RankHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: CST.primary40,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 1, child: _buildRankHeader('순위')),
          Expanded(flex: 2, child: _buildRankHeader('이름')),
          Expanded(flex: 1, child: _buildRankHeader('승')),
          Expanded(flex: 1, child: _buildRankHeader('무')),
          Expanded(flex: 1, child: _buildRankHeader('패')),
          Expanded(flex: 1, child: _buildRankHeader('승점')),
          Expanded(flex: 1, child: _buildRankHeader('득실')),
        ],
      ),
    );
  }

  Widget _buildRankHeader(String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TST.smallTextBold.copyWith(color: CST.gray1),
        textAlign: TextAlign.center,
      ),
    );
  }
} 