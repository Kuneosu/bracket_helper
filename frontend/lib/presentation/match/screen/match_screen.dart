import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MatchScreen extends StatelessWidget {
  final TournamentModel tournament;
  final List<MatchModel> matches;
  final List<PlayerModel> players;
  final bool isLoading;

  const MatchScreen({
    super.key, 
    required this.tournament,
    required this.matches,
    required this.players,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('로딩 중...', style: TST.mediumTextBold.copyWith(color: CST.white)),
          backgroundColor: CST.primary100,
        ),
        body: Center(
          child: CircularProgressIndicator(color: CST.primary100),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            tournament.title,
            style: TST.mediumTextBold.copyWith(color: CST.white),
          ),
          backgroundColor: CST.primary100,
          centerTitle: true,
          automaticallyImplyLeading: true,
          scrolledUnderElevation: 0,
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
                  _buildBracketTab(context, matches, players),
                  // 현재 순위 탭 내용
                  _buildRankTab(players),
                ],
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
        ),
      ),
    );
  }

  Widget _buildRankTab(List<PlayerModel> players) {
    final List<String> sortOptions = ["이름", "승점", "득실"];

    return Column(
      children: [
        // 정렬 옵션 라디오 버튼
        Row(
          children: [
            Spacer(),
            RadioMenuButton(
              value: "name",
              onChanged: (value) {},
              groupValue: "sort",
              child: Text(sortOptions[0]),
            ),
            RadioMenuButton(
              value: "points",
              onChanged: (value) {},
              groupValue: "sort",
              child: Text(sortOptions[1]),
            ),
            RadioMenuButton(
              value: "difference",
              onChanged: (value) {},
              groupValue: "sort",
              child: Text(sortOptions[2]),
            ),
          ],
        ),
        // 랭킹 테이블 섹션
        Expanded(
          child: Row(
            children: [
              // 테이블 컬럼 생성
              Expanded(
                child: Column(
                  children: [
                    // 테이블 헤더
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: CST.gray3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 1, child: _buildRankItem('순위', 0)),
                          Expanded(flex: 2, child: _buildRankItem('이름', 0)),
                          Expanded(flex: 1, child: _buildRankItem('승', 0)),
                          Expanded(flex: 1, child: _buildRankItem('무', 0)),
                          Expanded(flex: 1, child: _buildRankItem('패', 0)),
                          Expanded(flex: 1, child: _buildRankItem('승점', 0)),
                          Expanded(flex: 1, child: _buildRankItem('득실', 0)),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // 선수 목록
                    Expanded(
                      child: ListView.builder(
                        itemCount: players.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: CST.gray4),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(flex: 1, child: _buildRankItem('${index + 1}', 0)),
                                  Expanded(flex: 2, child: _buildRankItem(players[index].name, 0)),
                                  Expanded(flex: 1, child: _buildRankItem('1', 0)),
                                  Expanded(flex: 1, child: _buildRankItem('1', 0)),
                                  Expanded(flex: 1, child: _buildRankItem('1', 0)),
                                  Expanded(flex: 1, child: _buildRankItem('1', 0)),
                                  Expanded(flex: 1, child: _buildRankItem('3', 0)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Container _buildRankItem(String text, double width) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TST.smallTextRegular,
        textAlign: TextAlign.center,
      ),
    );
  }

  // 대진표 탭 내용을 구성하는 위젯
  Widget _buildBracketTab(
    BuildContext context,
    List<MatchModel> matchList,
    List<PlayerModel> playerList,
  ) {
    return Column(
      children: [
        // 매치 리스트
        Expanded(
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: matchList.length,
            itemBuilder: (context, index) {
              return _buildMatchList(index, playerList);
            },
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

  Widget _buildMatchList(int index, List<PlayerModel> playerList) {
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
