import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/home/home_action.dart';
import 'package:bracket_helper/presentation/home/widgets/recent_tournament_card.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';

class HomeScreen extends StatelessWidget {
  final List<TournamentModel> tournaments;
  final void Function(HomeAction) onAction;
  final VoidCallback onHelpPressed;
  const HomeScreen({
    super.key,
    required this.tournaments,
    required this.onAction,
    required this.onHelpPressed,
  });

  // 업데이트 예정 스낵바를 표시하는 메서드
  void _showComingSoonMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.comingSoonMessage),
        duration: Duration(seconds: 2),
      ),
    );
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
            onPressed: onHelpPressed,
            child: Text(
              AppStrings.help,
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
                  Text(AppStrings.recentMatches, style: TST.mediumTextBold),
                  // if (tournaments.isNotEmpty)
                  //   Text(AppStrings.viewAll, style: TST.smallTextRegular),
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
                      final reversedIndex = tournaments.length - 1 - index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: RecentTournamentCard(
                          tournament: tournaments[reversedIndex],
                          onTapCard: () {
                            context.push(
                              '${RoutePaths.match}?tournamentId=${tournaments[reversedIndex].id}',
                            );
                          },
                          onTapDelete: () {
                            onAction(
                              OnTapDeleteTournament(tournaments[reversedIndex].id),
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

                  _buildFeatureCard(
                    title: AppStrings.createBracket,
                    subtitle: AppStrings.createBracketDesc,
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
                          title: AppStrings.playerManagement,
                          subtitle: AppStrings.playerManagementDesc,
                          iconData: Icons.people,
                          onTap: () => _showComingSoonMessage(context),
                          gradient: LinearGradient(
                            colors: [
                              Colors.orange.shade700,
                              Colors.orange.shade400,
                            ],
                          ),
                          isComingSoon: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSmallFeatureCard(
                          title: AppStrings.groupManagement,
                          subtitle: AppStrings.groupManagementDesc,
                          iconData: Icons.group_work,
                          onTap: () => context.go(RoutePaths.savePlayer),
                          gradient: LinearGradient(
                            colors: [
                              Colors.purple.shade700,
                              Colors.purple.shade400,
                            ],
                          ),
                          isComingSoon: false,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildFeatureCard(
                    title: AppStrings.viewStatistics,
                    subtitle: AppStrings.viewStatisticsDesc,
                    iconData: Icons.bar_chart,
                    onTap: () => _showComingSoonMessage(context),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade400],
                    ),
                    isComingSoon: true,
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
            AppStrings.noTournaments,
            style: TST.normalTextRegular.copyWith(color: CST.gray2),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.createNewTournament,
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
    bool isComingSoon = false,
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
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isComingSoon)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.3),
                        ),
                      ),
                      child: Text(
                        AppStrings.comingSoon,
                        style: TST.normalTextBold.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
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
    bool isComingSoon = false,
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
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isComingSoon)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha:0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha:0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha:0.3),
                        ),
                      ),
                      child: Text(
                        AppStrings.comingSoon,
                        style: TST.smallTextBold.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
