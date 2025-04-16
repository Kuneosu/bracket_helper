import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [Text('그룹 목록', style: TST.mediumTextBold)],
      ),
    );
  }
}
