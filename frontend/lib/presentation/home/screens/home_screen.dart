import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/home/home_action.dart';
import 'package:bracket_helper/presentation/home/widgets/recent_tournament_card.dart';
import 'package:bracket_helper/presentation/home/widgets/feature_card.dart';
import 'package:bracket_helper/presentation/home/widgets/empty_tournaments_widget.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';

class HomeScreen extends StatefulWidget {
  final List<TournamentModel> tournaments;
  final void Function(HomeAction) onAction;
  final VoidCallback onHelpPressed;

  const HomeScreen({
    super.key,
    required this.tournaments,
    required this.onAction,
    required this.onHelpPressed,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    
    // GitHub에서 앱 설정 정보 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAppVersion();
    });
  }
  
  Future<void> _checkAppVersion() async {
    // GitHub 저장소에서 버전 정보 확인
    widget.onAction(const OnCheckUpdate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.appTitle,
          style: TST.largeTextBold.copyWith(color: CST.white),
        ),
        centerTitle: false,
        backgroundColor: CST.primary100,
        foregroundColor: CST.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: widget.onHelpPressed,
            child: Text(
              AppStrings.help,
              style: TST.normalTextBold.copyWith(color: CST.white),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          widget.onAction(const OnRefresh());
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
                  Text(AppStrings.recentMatches, style: TST.mediumTextBold),
                  // if (tournaments.isNotEmpty)
                  //   Text(AppStrings.viewAll, style: TST.smallTextRegular),
                ],
              ),
            ),

            widget.tournaments.isEmpty
                ? const EmptyTournamentsWidget()
                : SizedBox(
                  height: 120,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.tournaments.length,
                    itemBuilder: (context, index) {
                      final reversedIndex =
                          widget.tournaments.length - 1 - index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: RecentTournamentCard(
                          tournament: widget.tournaments[reversedIndex],
                          onTapCard: () {
                            context.push(
                              '${RoutePaths.match}?tournamentId=${widget.tournaments[reversedIndex].id}',
                            );
                          },
                          onTapDelete: () {
                            widget.onAction(
                              OnTapDeleteTournament(
                                widget.tournaments[reversedIndex].id,
                              ),
                            );
                          },
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
                  Text(AppStrings.services, style: TST.mediumTextBold),
                  const SizedBox(height: 16),

                  FeatureCard(
                    title: AppStrings.createBracket,
                    subtitle: AppStrings.createBracketDesc,
                    iconData: Icons.sports_tennis,
                    onTap: () => widget.onAction(const OnTapCreateTournament()),
                    gradient: LinearGradient(
                      colors: [CST.primary100, CST.primary100.withGreen(150)],
                    ),
                  ),

                  const SizedBox(height: 16),

                  FeatureCard(
                    title: AppStrings.designatedPartnerMatching,
                    subtitle: AppStrings.designatedPartnerMatchingDesc,
                    iconData: Icons.groups,
                    onTap:
                        () => widget.onAction(const OnTapPartnerTournament()),
                    gradient: LinearGradient(
                      colors: [Color(0xFFE67E22), Color(0xFFF39C12)],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: FeatureCard(
                          title: AppStrings.groupManagement,
                          subtitle: AppStrings.groupManagementDesc,
                          iconData: Icons.people_alt,
                          onTap: () {
                            // 메인 탭 네비게이션의 그룹 관리 탭(인덱스 1)으로 이동
                            context.go(RoutePaths.savePlayer);
                          },
                          gradient: LinearGradient(
                            colors: [Color(0xFF546E7A), Color(0xFF78909C)],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            SizedBox(height: 24),
            // 저작권자 표시
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              alignment: Alignment.center,
              child: Text(
                AppStrings.copyright,
                style: TST.smallTextRegular.copyWith(
                  color: CST.gray2,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
