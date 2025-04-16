import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class GroupListItem extends StatelessWidget {
  final Group group;
  final void Function() onTap;
  final void Function() onRemoveTap;
  final bool isEditMode;
  const GroupListItem({
    super.key,
    required this.group,
    required this.onTap,
    required this.onRemoveTap,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          color: CST.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: CST.black.withValues(alpha: 0.1),
              blurRadius: 6,
              spreadRadius: 1,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset('assets/image/maco.png', width: 80, height: 80),
            SizedBox(width: 20),
            isEditMode
                ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: CST.primary60),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(group.name, style: TST.mediumTextBold),
                )
                : Text(group.name, style: TST.mediumTextBold),
            Spacer(),

            isEditMode
                ? DefaultButton(
                  text: '제거',
                  onTap: onRemoveTap,
                  color: CST.error,
                  width: 50,
                  height: 30,
                  textStyle: TST.smallTextBold,
                )
                : Row(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 24,
                      color: CST.gray2,
                    ),
                    SizedBox(width: 10),
                    Text(
                      '10',
                      style: TST.mediumTextBold.copyWith(color: CST.gray2),
                    ),
                  ],
                ),
            SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}
