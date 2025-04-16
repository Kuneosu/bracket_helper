import 'package:bracket_helper/ui/color_st.dart';
import 'package:flutter/material.dart';

class SquareIconMenu extends StatelessWidget {
  const SquareIconMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: CST.gray4,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: Icon(Icons.edit, color: CST.black)),
    );
  }
}
