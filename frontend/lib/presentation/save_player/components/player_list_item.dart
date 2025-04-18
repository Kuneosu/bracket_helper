import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class PlayerListItem extends StatelessWidget {
  final PlayerModel player;
  final int index;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PlayerListItem({
    super.key,
    required this.player,
    required this.index,
    this.isFirst = false,
    this.isLast = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: CST.gray4, width: 1);
    final firstBorder = Border.all(color: CST.gray4, width: 1);
    final lastBorder = Border(bottom: border, left: border, right: border);
    final middleBorder = Border(left: border, right: border,bottom: border);
    
    final firstBorderRadius = const BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    );
    final lastBorderRadius = const BorderRadius.only(
      bottomLeft: Radius.circular(10),
      bottomRight: Radius.circular(10),
    );
    final middleBorderRadius = BorderRadius.zero;

    final nowBorder =
        isFirst
            ? firstBorder
            : isLast
            ? lastBorder
            : middleBorder;
    final nowBorderRadius =
        isFirst
            ? firstBorderRadius
            : isLast
            ? lastBorderRadius
            : middleBorderRadius;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: CST.white,
          borderRadius: nowBorderRadius,
          border: nowBorder,
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            
            // 순서 번호
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: CST.gray4,
                shape: BoxShape.circle,
              ),
              child: Text(
                index.toString(), 
                style: TST.smallTextBold.copyWith(
                  color: Colors.black87
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 선수 이름
            Expanded(
              child: Text(
                player.name,
                style: TST.mediumTextRegular,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // 메뉴 버튼
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: CST.gray3),
                onSelected: (value) {
                  if (value == 'edit' && onEdit != null) {
                    onEdit!();
                  } else if (value == 'delete' && onDelete != null) {
                    onDelete!();
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('수정'),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('삭제'),
                    ),
                ],
              )
            else
              const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
