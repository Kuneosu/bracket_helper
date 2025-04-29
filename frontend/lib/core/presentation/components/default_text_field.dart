import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class DefaultTextField extends StatefulWidget {
  final String hintText;
  final TextAlign? textAlign;
  final String? initialValue;
  final Function(String)? onChanged;
  final bool bottomBorder;
  final bool isNumberField;

  const DefaultTextField({
    super.key,
    required this.hintText,
    this.textAlign = TextAlign.start,
    this.initialValue,
    this.onChanged,
    this.bottomBorder = false,
    this.isNumberField = false,
  });

  @override
  State<DefaultTextField> createState() => _DefaultTextFieldState();
}

class _DefaultTextFieldState extends State<DefaultTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    
    _focusNode.addListener(_onFocusChange);
    
    if (widget.isNumberField && _controller.text == "0") {
      _controller.text = "";
    }
  }

  void _onFocusChange() {
    if (widget.isNumberField) {
      if (_focusNode.hasFocus) {
        if (_controller.text == "0") {
          _controller.text = "";
        }
      } else {
        if (_controller.text.isEmpty) {
          _controller.text = "0";
          if (widget.onChanged != null) {
            widget.onChanged!("0");
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: widget.textAlign!,
      textAlignVertical: TextAlignVertical.center,
      onChanged: widget.onChanged,
      style: TST.mediumTextRegular,
      keyboardType: widget.isNumberField ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TST.mediumTextRegular.copyWith(color: CST.gray3),
        border: OutlineInputBorder(borderSide: BorderSide(color: CST.gray3)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CST.gray3),
          borderRadius: widget.bottomBorder ? BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)) : BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: CST.primary100),
          borderRadius: widget.bottomBorder ? BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)) : BorderRadius.circular(8),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        isDense: true,
        isCollapsed: true,
      ),
    );
  }
}
