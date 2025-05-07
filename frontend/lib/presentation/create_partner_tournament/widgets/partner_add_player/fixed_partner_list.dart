import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

/// 고정 파트너 쌍 목록을 표시하는 위젯
class FixedPartnerList extends StatelessWidget {
  final List<List<String>> fixedPairs;
  final Function(int) onRemove;

  const FixedPartnerList({
    super.key,
    required this.fixedPairs,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: CST.primary20.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CST.primary60.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 섹션 헤더
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CST.primary100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.link, color: Colors.white, size: 14),
              ),
              SizedBox(width: 8),
              Text(
                '고정 파트너 쌍',
                style: TST.smallTextBold.copyWith(color: CST.primary100),
              ),
              Spacer(),
              Text(
                '${fixedPairs.length}쌍',
                style: TST.smallTextRegular.copyWith(color: CST.primary100),
              ),
            ],
          ),
          SizedBox(height: 4),
          
          // 파트너 쌍 목록
          Expanded(
            child: fixedPairs.isEmpty
              ? Center(
                  child: Text(
                    '아직 지정된 파트너가 없습니다',
                    textAlign: TextAlign.center,
                    style: TST.smallTextRegular.copyWith(color: CST.gray3),
                  ),
                )
              : ListView.builder(
                  itemCount: fixedPairs.length,
                  itemBuilder: (context, index) => _buildPartnerPairItem(index),
                ),
          ),
        ],
      ),
    );
  }

  // 파트너 쌍 아이템 위젯
  Widget _buildPartnerPairItem(int index) {
    final pair = fixedPairs[index];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CST.primary60.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [CST.primary80, CST.primary100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                "${index + 1}",
                style: TST.smallTextBold.copyWith(color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: CST.primary60.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pair[0],
                      style: TST.smallTextBold.copyWith(color: CST.primary100),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(Icons.link, color: CST.primary100, size: 16),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: CST.primary60.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pair[1],
                      style: TST.smallTextBold.copyWith(color: CST.primary100),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: CST.error, size: 20),
            onPressed: () => onRemove(index),
            tooltip: "삭제",
            constraints: BoxConstraints(minWidth: 36, minHeight: 36),
            padding: EdgeInsets.zero,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
} 