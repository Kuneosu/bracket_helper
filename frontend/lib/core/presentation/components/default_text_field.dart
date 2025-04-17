import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class DefaultTextField extends StatefulWidget {
  final String hintText;
  final TextAlign? textAlign;
  final String? initialValue;
  final Function(String)? onChanged;

  const DefaultTextField({
    super.key,
    required this.hintText,
    this.textAlign = TextAlign.start,
    this.initialValue,
    this.onChanged,
  });

  @override
  State<DefaultTextField> createState() => _DefaultTextFieldState();
}

class _DefaultTextFieldState extends State<DefaultTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textAlign: widget.textAlign!,
      textAlignVertical: TextAlignVertical.center,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
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
