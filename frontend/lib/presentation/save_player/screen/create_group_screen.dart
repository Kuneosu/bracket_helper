import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/presentation/save_player/components/group_avatar_picker.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),
              Image.asset('assets/image/persons.png', width: 165, height: 105),
              SizedBox(height: 20),
              Text(
                '선수를 저장하려면 먼저\n그룹을 생성해주세요',
                style: TST.mediumTextBold,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              DefaultTextField(hintText: '그룹명을 입력해주세요'),
              SizedBox(height: 30),
              Text(
                '그룹을 대표하는\n사진 또는 색상을 선택해주세요',
                style: TST.mediumTextBold,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              GroupAvatarPicker(onTap: () {}),
              SizedBox(height: 40),
              DefaultButton(text: '그룹 생성하기', onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
