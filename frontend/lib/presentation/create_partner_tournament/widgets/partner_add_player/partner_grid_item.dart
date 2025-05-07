import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

/// 파트너 선택 그리드에서 사용되는 개별 선수 아이템 위젯
class PartnerGridItem extends StatelessWidget {
  final PlayerModel player;
  final bool isSelected;
  final bool hasPartner;
  final int index;
  final Function(PlayerModel) onTap;

  const PartnerGridItem({
    super.key,
    required this.player,
    required this.isSelected,
    required this.hasPartner,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: hasPartner ? null : () => onTap(player),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hasPartner
                ? CST.gray4.withValues(alpha: 0.2)
                : isSelected
                    ? CST.primary60.withValues(alpha: 0.2)
                    : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasPartner
                  ? CST.gray3
                  : isSelected
                      ? CST.primary100
                      : CST.gray4,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: CST.primary100.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: hasPartner
                      ? CST.gray3
                      : isSelected
                          ? CST.primary100
                          : CST.primary40,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    "${index}",
                    style: TST.smallTextBold.copyWith(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  player.name,
                  style: TST.normalTextBold.copyWith(
                    color: hasPartner
                        ? CST.gray3
                        : isSelected
                            ? CST.primary100
                            : CST.gray1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: CST.primary100, size: 20),
              if (hasPartner) Icon(Icons.link, color: CST.gray3, size: 20),
            ],
          ),
        ),
      ),
    );
  }
} 