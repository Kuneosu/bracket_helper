import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SavePlayerScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;

  const SavePlayerScreen({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CST.primary100,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: CST.white),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          title,
          style: TST.mediumTextBold.copyWith(color: CST.white),
        ),
      ),
      body: body,
    );
  }
}
