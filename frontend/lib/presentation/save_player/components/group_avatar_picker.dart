import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

class GroupAvatarPicker extends StatelessWidget {
  final void Function() onTap;
  const GroupAvatarPicker({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: CST.gray4,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(child: Icon(Icons.edit, color: CST.black)),
      ),
    );
  }
}
