import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/domain/model/match.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Player> players = [
      Player(id: 1, name: '홍길동'),
      Player(id: 2, name: '이순신'),
      Player(id: 3, name: '임꺽정'),
      Player(id: 4, name: '김유신'),
    ];
    final List<Match> matchList = [
      Match(id: 1),
      Match(id: 2),
      Match(id: 3),
      Match(id: 4),
      Match(id: 5),
      Match(id: 6),
      Match(id: 7),
      Match(id: 8),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '2025-04-14(월) 대회',
            style: TST.mediumTextBold.copyWith(color: CST.white),
          ),
          backgroundColor: CST.primary100,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.info_outline, color: CST.white),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildHeaderSection(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                children: [
                  // 대진표 탭 내용
                  _buildBracketTab(context, matchList, players),
                  // 현재 순위 탭 내용
                  Center(
                    child: Text(
                      '현재 순위 내용이 여기에 표시됩니다',
                      style: TST.normalTextRegular,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 대진표 탭 내용을 구성하는 위젯
  Widget _buildBracketTab(
    BuildContext context,
    List<Match> matchList,
    List<Player> players,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: matchList.length,
            itemBuilder: (context, index) {
              return _buildMatchList(index, players);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 40,
            top: 20,
          ),
          child: Row(
            children: [
              DefaultButton(
                text: "섞어서 다시 돌리기",
                onTap: () {
                  context.pop();
                },
                width: 150,
              ),
              Spacer(),
              DefaultButton(text: "경기 종료", onTap: () {}, width: 150),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      indicatorColor: CST.primary100,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: CST.primary100,
      unselectedLabelColor: CST.gray3,
      labelStyle: TST.normalTextBold,
      unselectedLabelStyle: TST.normalTextRegular,
      tabs: const [Tab(text: '대진표'), Tab(text: '현재 순위')],
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: CST.gray3)),
      ),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("참가 인원 수 : N 명", style: TST.normalTextRegular),
              Text("경기 수 : N 경기", style: TST.normalTextRegular),
            ],
          ),
          Spacer(),
          DefaultButton(
            text: "대진 수정",
            onTap: () {},
            width: 100,
            height: 44,
            textStyle: TST.normalTextBold,
          ),
          SizedBox(width: 10),
          DefaultButton(
            text: "대진 공유",
            onTap: () {},
            width: 100,
            height: 44,
            textStyle: TST.normalTextBold,
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(int index, List<Player> playerList) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: CST.gray4)),
      ),
      child: Row(
        children: [
          Text("${index + 1}", style: TST.largeTextRegular),
          Spacer(),
          Column(
            children: [
              Text(playerList[0].name, style: TST.mediumTextRegular),
              Container(
                width: 50,
                height: 1,
                color: CST.gray4,
                margin: EdgeInsets.symmetric(vertical: 2),
              ),
              Text(playerList[1].name, style: TST.mediumTextRegular),
            ],
          ),
          Spacer(),
          SizedBox(
            width: 50,
            height: 50,
            child: DefaultTextField(textAlign: TextAlign.center, hintText: '0'),
          ),
          Spacer(),
          Text(":", style: TST.smallTextBold),
          Spacer(),
          SizedBox(
            width: 50,
            height: 50,
            child: DefaultTextField(textAlign: TextAlign.center, hintText: '0'),
          ),
          Spacer(),
          Column(
            children: [
              Text(playerList[2].name, style: TST.mediumTextRegular),
              Container(
                width: 50,
                height: 1,
                color: CST.gray4,
                margin: EdgeInsets.symmetric(vertical: 2),
              ),
              Text(playerList[3].name, style: TST.mediumTextRegular),
            ],
          ),
        ],
      ),
    );
  }
}
