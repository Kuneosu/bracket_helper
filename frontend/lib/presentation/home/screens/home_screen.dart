import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/home/home_action.dart';
import 'package:bracket_helper/presentation/home/widgets/recent_tournament_card.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:new_version_plus/new_version_plus.dart';

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
    // 앱이 시작될 때 업데이트 확인
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    final newVersion = NewVersionPlus(
      iOSId: 'id6745153734', // iOS 앱스토어 ID
      androidId: 'com.kuneosu.bracket_helper', // 안드로이드 패키지명
      // 사용자의 국가 코드를 지정하여 앱스토어 검색 정확도 향상
      androidPlayStoreCountry: 'kr',
      iOSAppStoreCountry: 'kr',
    );

    try {
      final status = await newVersion.getVersionStatus();
      debugPrint('status: $status');
      
      if (status == null) {
        debugPrint('업데이트 상태를 확인할 수 없습니다. 네트워크 연결 및 앱 ID를 확인하세요.');
        return;
      }
      
      if (status.canUpdate) {
        if (mounted) {
          newVersion.showUpdateDialog(
            context: context,
            versionStatus: status,
            dialogTitle: '업데이트 가능',
            dialogText: '새 버전(${status.storeVersion})이 출시되었습니다. 지금 업데이트하시겠습니까?',
            updateButtonText: '업데이트',
            dismissButtonText: '나중에',
            dismissAction: () => Navigator.pop(context),
          );
        }
      }
    } catch (e) {
      // 오류 유형별 구체적인 처리
      if (e.toString().contains('404')) {
        debugPrint('앱스토어에서 앱을 찾을 수 없습니다. 앱 ID가 올바른지 확인하세요:');
        debugPrint('iOS ID: id6745153734');
        debugPrint('Android ID: com.kuneosu.bracket_helper');
        // 개발 모드에서는 오류를 무시합니다.
        debugPrint('개발 중인 경우 이 오류는 정상입니다. 앱이 아직 스토어에 등록되지 않았을 수 있습니다.');
      } else if (e.toString().contains('Unable to parse version')) {
        debugPrint('버전 정보를 파싱할 수 없습니다. 앱스토어 응답 형식이 변경되었을 수 있습니다.');
      } else {
        // 그 외 다른 오류 처리
        debugPrint('업데이트 확인 실패: $e');
      }
    }
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
                ? _buildEmptyTournaments()
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
                      final reversedIndex = widget.tournaments.length - 1 - index;
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

                  _buildFeatureCard(
                    title: AppStrings.createBracket,
                    subtitle: AppStrings.createBracketDesc,
                    iconData: Icons.sports_tennis,
                    onTap: () => widget.onAction(const OnTapCreateTournament()),
                    gradient: LinearGradient(
                      colors: [CST.primary100, CST.primary100.withGreen(150)],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Expanded(
                      //   child: _buildSmallFeatureCard(
                      //     title: AppStrings.playerManagement,
                      //     subtitle: AppStrings.playerManagementDesc,
                      //     iconData: Icons.people,
                      //     onTap: () => _showComingSoonMessage(context),
                      //     gradient: LinearGradient(
                      //       colors: [
                      //         Colors.orange.shade700,
                      //         Colors.orange.shade400,
                      //       ],
                      //     ),
                      //     isComingSoon: true,
                      //   ),
                      // ),
                      // const SizedBox(width: 12),
                      Expanded(
                        child: _buildFeatureCard(
                          title: AppStrings.groupManagement,
                          subtitle: AppStrings.groupManagementDesc,
                          iconData: Icons.people_alt,
                          onTap: () {
                            // 메인 탭 네비게이션의 그룹 관리 탭(인덱스 1)으로 이동
                            context.go(RoutePaths.savePlayer);
                          },
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF546E7A),
                              Color(0xFF78909C),
                            ],
                          ),
                          isComingSoon: false,
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
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
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

  // Widget _buildSmallFeatureCard({
  //   required String title,
  //   required String subtitle,
  //   required IconData iconData,
  //   required VoidCallback onTap,
  //   required Gradient gradient,
  //   bool isComingSoon = false,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       width: double.infinity,
  //       height: 120,
  //       decoration: BoxDecoration(
  //         gradient: gradient,
  //         borderRadius: BorderRadius.circular(16),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withValues(alpha: 0.1),
  //             blurRadius: 8,
  //             offset: const Offset(0, 3),
  //           ),
  //         ],
  //       ),
  //       child: Stack(
  //         children: [
  //           Positioned(
  //             right: -15,
  //             bottom: -15,
  //             child: Icon(
  //               iconData,
  //               size: 80,
  //               color: Colors.white.withValues(alpha: 0.2),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(12),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Icon(iconData, color: Colors.white, size: 24),
  //                 const Spacer(),
  //                 Text(
  //                   title,
  //                   style: TST.smallTextBold.copyWith(color: Colors.white),
  //                 ),
  //                 const SizedBox(height: 2),
  //                 Text(
  //                   subtitle,
  //                   style: TST.smallTextRegular.copyWith(
  //                     color: Colors.white.withValues(alpha: 0.9),
  //                     fontSize: 12,
  //                   ),
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ],
  //             ),
  //           ),
  //           if (isComingSoon)
  //             Positioned.fill(
  //               child: Container(
  //                 decoration: BoxDecoration(
  //                   color: Colors.black.withValues(alpha: 0.4),
  //                   borderRadius: BorderRadius.circular(16),
  //                 ),
  //                 child: Center(
  //                   child: Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 12,
  //                       vertical: 6,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       color: Colors.black.withValues(alpha: 0.6),
  //                       borderRadius: BorderRadius.circular(16),
  //                       border: Border.all(
  //                         color: Colors.white.withValues(alpha: 0.3),
  //                       ),
  //                     ),
  //                     child: Text(
  //                       AppStrings.comingSoon,
  //                       style: TST.smallTextBold.copyWith(color: Colors.white),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
