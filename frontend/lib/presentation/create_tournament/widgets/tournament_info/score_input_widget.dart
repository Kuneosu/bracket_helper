import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class ScoreInputWidget extends StatelessWidget {
  final String label;
  final Color color;
  final String initialValue;
  final Function(String) onChanged;

  const ScoreInputWidget({
    super.key,
    required this.label,
    required this.color,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Text(
            label,
            style: TST.largeTextRegular.copyWith(color: Colors.white),
          ),
        ),
        Container(
          width: 60,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: DefaultTextField(
            hintText: '0',
            textAlign: TextAlign.center,
            initialValue: initialValue,
            onChanged: onChanged,
            bottomBorder: true,
          ),
        ),
      ],
    );
  }
} 