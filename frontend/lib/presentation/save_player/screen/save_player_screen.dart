import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class SavePlayerScreen extends StatelessWidget {
  final String title;
  final Widget body;
  const SavePlayerScreen({super.key, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CST.primary100,
        title: Text(
          title,
          style: TST.mediumTextBold.copyWith(color: CST.white),
        ),
      ),
      body: body,
    );
  }
}
