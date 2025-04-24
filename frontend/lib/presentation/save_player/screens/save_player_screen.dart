import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SavePlayerScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;
  final Color? appBarColor;

  const SavePlayerScreen({
    super.key,
    required this.title,
    required this.body,
    this.showBackButton = false,
    this.appBarColor,
  });

  @override
  Widget build(BuildContext context) {
    // 앱바 색상 - 전달받은 색상이 있으면 사용하고, 없으면 기본 색상 사용
    final barColor = appBarColor ?? CST.primary100;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: barColor,
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
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
