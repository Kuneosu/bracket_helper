import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/home/home_action.dart';
import 'package:bracket_helper/presentation/home/widget/recent_tournament_card.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  final List<TournamentModel> tournaments;
  final void Function(HomeAction) onAction;
  const HomeScreen({
    super.key,
    required this.tournaments,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "대진 도우미",
          style: TST.largeTextBold.copyWith(color: CST.white),
        ),
        centerTitle: false,
        backgroundColor: CST.primary100,
        foregroundColor: CST.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "도움말",
              style: TST.normalTextBold.copyWith(color: CST.white),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          onAction(const OnRefresh());
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CST.primary100.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("최근 경기", style: TST.mediumTextBold),
                  if (tournaments.isNotEmpty)
                    Text("모두 보기 >", style: TST.smallTextRegular),
                ],
              ),
            ),

            tournaments.isEmpty
                ? _buildEmptyTournaments()
                : SizedBox(
                  height: 120,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: tournaments.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: RecentTournamentCard(
                          tournament: tournaments[index],
                          onTapCard: () {
                            context.push(RoutePaths.match);
                          },
                          onTapDelete: () {},
                        ),
                      );
                    },
                  ),
                ),

            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("서비스", style: TST.mediumTextBold),
                  const SizedBox(height: 16),

                  _buildFeatureCard(
                    title: "대진표 생성하기",
                    subtitle: "복식/단식 매칭을 쉽게 관리하세요",
                    iconData: Icons.sports_tennis,
                    onTap: () => onAction(const OnTapCreateTournament()),
                    gradient: LinearGradient(
                      colors: [CST.primary100, CST.primary100.withGreen(150)],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSmallFeatureCard(
                          title: "선수 관리",
                          subtitle: "선수 정보를 등록하고 관리하세요",
                          iconData: Icons.people,
                          onTap: () {},
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade700,
                              Colors.orange.shade400,
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSmallFeatureCard(
                          title: "그룹 관리",
                          subtitle: "그룹을 만들고 선수를 추가하세요",
                          iconData: Icons.group_work,
                          onTap: () {},
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade700,
                              Colors.purple.shade400,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildFeatureCard(
                    title: "통계 보기",
                    subtitle: "경기 결과와 플레이어 성적을 분석하세요",
                    iconData: Icons.bar_chart,
                    onTap: () {},
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade400],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTournaments() {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: CST.gray4,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CST.gray3.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_tennis, size: 40, color: CST.gray3),
          const SizedBox(height: 12),
          Text(
            "아직 진행한 경기가 없습니다",
            style: TST.normalTextRegular.copyWith(color: CST.gray2),
          ),
          const SizedBox(height: 8),
          Text(
            "새 대진표를 생성해보세요!",
            style: TST.smallTextRegular.copyWith(color: CST.gray2),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required VoidCallback onTap,
    required Gradient gradient,
    double height = 160,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                iconData,
                size: 120,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(iconData, color: Colors.white, size: 32),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TST.mediumTextBold.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TST.smallTextRegular.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallFeatureCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -15,
              bottom: -15,
              child: Icon(
                iconData,
                size: 80,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(iconData, color: Colors.white, size: 24),
                  const Spacer(),
                  Text(
                    title,
                    style: TST.smallTextBold.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TST.smallTextRegular.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
