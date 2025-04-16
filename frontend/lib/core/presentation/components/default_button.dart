import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  final double? width;
  final double? height;
  final String text;
  final TextStyle? textStyle;
  final void Function() onTap;
  final Color? color;
  const DefaultButton({
    super.key,
    required this.text,
    required this.onTap,
    this.width = double.infinity,
    this.height = 50,
    this.color = CST.primary100,
    this.textStyle = TST.normalTextBold,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(text, style: textStyle!.copyWith(color: CST.white)),
        ),
      ),
    );
  }
}
