import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class DefaultTextField extends StatelessWidget {
  final String hintText;
  const DefaultTextField({super.key, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TST.mediumTextRegular.copyWith(color: CST.gray3),
        border: OutlineInputBorder(borderSide: BorderSide(color: CST.gray3)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CST.gray3),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CST.primary100),
        ),
      ),
    );
  }
}
