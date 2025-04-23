import 'package:bracket_helper/core/presentation/components/default_text_field.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
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
          title: Text(
            '로딩 중...',
            style: TST.mediumTextBold.copyWith(color: CST.white),
          ),
          backgroundColor: CST.primary100,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: CST.primary100),
              const SizedBox(height: 16),
              Text(
                '대진표를 불러오고 있습니다...',
                style: TST.smallTextRegular.copyWith(color: CST.gray2),
              ),
            ],
          ),
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
              onPressed: () {
                // 토너먼트 정보 다이얼로그 표시
                _showTournamentInfoDialog(context);
              },
              icon: Icon(Icons.info_outline, color: CST.white),
              tooltip: '토너먼트 정보',
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
            _buildBottomActionButtons(context),
          ],
        ),
      ),
    );
  }

  void _showTournamentInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('토너먼트 정보', style: TST.mediumTextBold),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('제목: ${tournament.title}', style: TST.normalTextRegular),
                const SizedBox(height: 8),
                Text('참가자 수: ${players.length}명', style: TST.normalTextRegular),
                const SizedBox(height: 8),
                Text('경기 수: ${matches.length}경기', style: TST.normalTextRegular),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  '닫기',
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
    );
  }

  Widget _buildRankTab(List<PlayerModel> players) {
    return Column(
      children: [
        // 정렬 옵션 선택 UI 개선
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: CST.primary20,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('정렬:', style: TST.smallTextBold),
              _buildSortOption('이름', 'name', 'sort'),
              _buildSortOption('승점', 'points', 'points'),
              _buildSortOption('득실', 'difference', 'sort'),
            ],
          ),
        ),
        // 랭킹 테이블 섹션
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CST.gray4),
            ),
            child: Column(
              children: [
                // 테이블 헤더
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: CST.primary40,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(flex: 1, child: _buildRankHeader('순위')),
                      Expanded(flex: 2, child: _buildRankHeader('이름')),
                      Expanded(flex: 1, child: _buildRankHeader('승')),
                      Expanded(flex: 1, child: _buildRankHeader('무')),
                      Expanded(flex: 1, child: _buildRankHeader('패')),
                      Expanded(flex: 1, child: _buildRankHeader('승점')),
                      Expanded(flex: 1, child: _buildRankHeader('득실')),
                    ],
                  ),
                ),
                // 선수 목록
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final isEven = index % 2 == 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isEven ? Colors.white : CST.primary20,
                          border: Border(
                            bottom:
                                index < players.length - 1
                                    ? BorderSide(color: CST.gray4)
                                    : BorderSide.none,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildRankItem('${index + 1}', 0),
                            ),
                            Expanded(
                              flex: 2,
                              child: _buildRankItem(players[index].name, 0),
                            ),
                            Expanded(flex: 1, child: _buildRankItem('1', 0)),
                            Expanded(flex: 1, child: _buildRankItem('1', 0)),
                            Expanded(flex: 1, child: _buildRankItem('1', 0)),
                            Expanded(flex: 1, child: _buildRankItem('1', 0)),
                            Expanded(flex: 1, child: _buildRankItem('3', 0)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSortOption(String label, String value, String groupValue) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CST.primary80 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TST.smallTextBold.copyWith(
            color: isSelected ? CST.white : CST.gray1,
          ),
        ),
      ),
    );
  }

  Widget _buildRankHeader(String text) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TST.smallTextBold.copyWith(color: CST.gray1),
        textAlign: TextAlign.center,
      ),
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: matchList.length,
            itemBuilder: (context, index) {
              return _buildMatchList(index, matchList[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: CST.primary20,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        indicator: BoxDecoration(
          color: CST.primary100,
          borderRadius: BorderRadius.circular(30),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: CST.white,
        unselectedLabelColor: CST.gray2,
        labelStyle: TST.normalTextBold,
        unselectedLabelStyle: TST.normalTextRegular,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sports_kabaddi, size: 18),
                  SizedBox(width: 8),
                  Text('대진표'),
                ],
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard, size: 18),
                  SizedBox(width: 8),
                  Text('현재 순위'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      decoration: BoxDecoration(
        color: CST.primary20,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: CST.primary100),
                  const SizedBox(width: 8),
                  Text(
                    "참가 인원: ${players.length}명",
                    style: TST.normalTextBold.copyWith(color: CST.gray1),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.emoji_events, size: 16, color: CST.primary100),
                  const SizedBox(width: 8),
                  Text(
                    "경기 수: ${matches.length}경기",
                    style: TST.normalTextBold.copyWith(color: CST.gray1),
                  ),
                ],
              ),
            ],
          ),
          Spacer(),
          _buildActionButton(icon: Icons.edit, label: "대진 수정", onTap: () {}),
          const SizedBox(width: 10),
          _buildActionButton(icon: Icons.share, label: "대진 공유", onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: CST.primary100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CST.primary100.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: CST.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TST.smallTextBold.copyWith(color: CST.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: CST.primary100,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shuffle, color: CST.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "섞어서 다시 돌리기",
                    style: TST.normalTextBold.copyWith(color: CST.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                context.go(RoutePaths.home);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CST.primary100,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all, color: CST.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "경기 종료",
                    style: TST.normalTextBold.copyWith(color: CST.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchList(int index, MatchModel match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: CST.gray4, width: 1),
      ),
      child: Row(
        children: [
          // 매치 번호
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: CST.primary20,
              shape: BoxShape.circle,
            ),
            child: Text(
              "${index + 1}",
              style: TST.smallTextBold.copyWith(color: CST.primary100),
            ),
          ),
          const SizedBox(width: 10),
          // 왼쪽 팀
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  match.playerA!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                  textAlign: TextAlign.right,
                ),
                Container(
                  width: 40,
                  height: 1,
                  color: CST.gray4,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
                Text(
                  match.playerC!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // 왼쪽 점수
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: CST.primary20,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CST.primary60, width: 1),
            ),
            child: DefaultTextField(textAlign: TextAlign.center, hintText: '0'),
          ),
          // VS 표시
          Container(
            width: 24,
            alignment: Alignment.center,
            child: Text(
              ":",
              style: TST.smallTextBold.copyWith(color: CST.primary100),
            ),
          ),
          // 오른쪽 점수
          Container(
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: CST.primary20,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CST.primary60, width: 1),
            ),
            child: DefaultTextField(textAlign: TextAlign.center, hintText: '0'),
          ),
          const SizedBox(width: 24),
          // 오른쪽 팀
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.playerB!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
                Container(
                  width: 40,
                  height: 1,
                  color: CST.gray4,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
                Text(
                  match.playerD!,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
