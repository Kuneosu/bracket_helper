import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/core/presentation/components/default_button.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/create_partner_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/index.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class PartnerEditMatchScreen extends StatefulWidget {
  final TournamentModel tournament;
  final List<PlayerModel> players;
  final List<MatchModel> matches;
  final bool isLoading;
  final bool isEditMode;
  final Function(CreatePartnerTournamentAction) onAction;

  const PartnerEditMatchScreen({
    super.key,
    required this.tournament,
    required this.players,
    required this.matches,
    this.isLoading = false,
    required this.onAction,
    required this.isEditMode,
  });

  @override
  State<PartnerEditMatchScreen> createState() => _PartnerEditMatchScreenState();
}

class _PartnerEditMatchScreenState extends State<PartnerEditMatchScreen> {
  late TextEditingController _courtsController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 기본값으로 전체 인원수를 4로 나눈 몫 설정
    final defaultCourts =
        widget.players.isEmpty ? 1 : widget.players.length ~/ 4;
    _courtsController = TextEditingController(text: defaultCourts.toString());
  }

  @override
  void dispose() {
    _courtsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerCount = widget.players.isEmpty ? 4 : widget.players.length;
    final matchCount = widget.matches.isEmpty ? 0 : widget.matches.length;

    return Expanded(
      child: Column(
        children: [
          _buildHeader(playerCount, matchCount),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child:
                  widget.isLoading
                      ? _buildLoadingIndicator()
                      : widget.matches.isEmpty
                      ? _buildEmptyMatchList()
                      : ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: widget.matches.length,
                        itemBuilder: (context, index) {
                          return _buildMatchItem(index, widget.matches[index]);
                        },
                      ),
            ),
          ),
          NavigationButtonsWidget(
            onPrevious: () {
              // 현재 파트너 쌍 정보를 명시적으로 업데이트하여 보존
              debugPrint(
                'EditMatchScreen - 이전 버튼 클릭: 파트너 쌍 정보 보존 확인 (${widget.tournament.partnerPairs.length}개)',
              );
              
              // 파트너 매칭 모드 유지
              widget.onAction(
                CreatePartnerTournamentAction.updateIsPartnerMatching(true),
              );
              
              context.go(
                '${RoutePaths.createPartnerTournament}${RoutePaths.partnerAddPlayer}',
              );
            },
            onNext: () async {
              if (_isSaving) {
                debugPrint('이미 저장 중입니다.');
                return;
              }

              setState(() {
                _isSaving = true;
              });

              debugPrint('다음 단계로 진행 - 매치 저장 시작');

              try {
                // 파트너 쌍 정보 디버깅 - 저장 전 확인
                debugPrint('저장 전 파트너 쌍 정보: ${widget.tournament.partnerPairs.length}개');
                for (var i = 0; i < widget.tournament.partnerPairs.length; i++) {
                  final pair = widget.tournament.partnerPairs[i];
                  debugPrint('  파트너 쌍 ${i+1}: ${pair[0]} & ${pair[1]}');
                }
              
                // 파트너 매칭 모드 유지
                await widget.onAction(
                  CreatePartnerTournamentAction.updateIsPartnerMatching(true),
                );
                
                // 데이터 저장
                await widget.onAction(
                  CreatePartnerTournamentAction.saveTournamentOrUpdateMatches(),
                );

                // 저장 완료 후 데이터 반영을 위한 딜레이
                await Future.delayed(const Duration(milliseconds: 1000));
                await widget.onAction(CreatePartnerTournamentAction.onDiscard());

                if (context.mounted) {
                  final tournamentId = widget.tournament.id;
                  debugPrint('매치 저장 완료 - 매치 화면으로 이동 (ID: $tournamentId)');

                  setState(() {
                    _isSaving = false;
                  });

                  // shouldRefresh=true 쿼리 파라미터 추가 - 새로고침 확실히 실행
                  context.go(
                    '${RoutePaths.match}?tournamentId=$tournamentId&shouldRefresh=true',
                  );
                }
              } catch (e) {
                debugPrint('매치 저장 중 오류 발생: $e');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('매치 저장 중 오류가 발생했습니다: $e')),
                  );

                  setState(() {
                    _isSaving = false;
                  });
                }
              }
            },
            nextText:
                widget.isEditMode
                    ? (_isSaving ? '저장 중...' : '저장 후 돌아가기')
                    : (_isSaving ? '저장 중...' : '저장 후 완료'),
            isNextDisabled: _isSaving,
          ),
        ],
      ),
    );
  }

  // 로딩 표시 위젯
  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  // 빈 매치 목록 위젯
  Widget _buildEmptyMatchList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppStrings.noMatches, style: TST.mediumTextRegular),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCourtInputField(large: true),
              const SizedBox(width: 16),
              DefaultButton(
                text: AppStrings.autoGenerateMatch,
                onTap: () {
                  debugPrint('매치 자동 생성 버튼 클릭');
                  _generateMatches();
                },
                width: 150,
                height: 48,
                color: CST.primary100,
                textStyle: TST.normalTextBold.copyWith(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 코트 수 입력 필드 위젯
  Widget _buildCourtInputField({bool large = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CST.primary40.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CST.primary60.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sports_tennis_outlined,
                color: CST.primary100,
                size: large ? 18 : 16,
              ),
              const SizedBox(width: 4),
              Text(
                AppStrings.courtCount,
                style:
                    large
                        ? TST.normalTextBold.copyWith(color: CST.primary100)
                        : TST.smallTextBold.copyWith(color: CST.primary100),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: large ? 90 : 70,
            height: large ? 42 : 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CST.primary60.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _courtsController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
                hintText:
                    '1-${widget.players.isEmpty ? 1 : widget.players.length ~/ 4}',
                hintStyle: TST.smallTextRegular.copyWith(color: CST.gray4),
                border: InputBorder.none,
              ),
              style: large ? TST.normalTextBold : TST.smallTextBold,
            ),
          ),
        ],
      ),
    );
  }

  // 상단 헤더 위젯
  Widget _buildHeader(int playerCount, int matchCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: CST.gray3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, color: CST.primary100, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.participantsCount.replaceAll(
                      '%d',
                      playerCount.toString(),
                    ),
                    style: TST.normalTextRegular.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.sports_handball_outlined,
                    color: CST.primary100,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.matchesCount.replaceAll(
                      '%d',
                      matchCount.toString(),
                    ),
                    style: TST.normalTextRegular.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildCourtControlGroup(),
        ],
      ),
    );
  }

  // 코트 수 입력 및 초기화 버튼 그룹
  Widget _buildCourtControlGroup() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CST.primary40.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CST.primary60.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_tennis_outlined,
                    color: CST.primary100,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    AppStrings.courtCount,
                    style: TST.smallTextBold.copyWith(color: CST.primary100),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                width: 70,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: CST.primary60.withValues(alpha: 0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _courtsController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText:
                        '1-${widget.players.isEmpty ? 1 : widget.players.length ~/ 4}',
                    hintStyle: TST.smallTextRegular.copyWith(color: CST.gray4),
                    border: InputBorder.none,
                  ),
                  style: TST.smallTextBold,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 10),
            height: 36,
            width: 1,
            color: CST.primary60.withValues(alpha: 0.2),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                debugPrint('매치 초기화 버튼 클릭');
                _generateMatches();
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: CST.primary100,
                      size: 18,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.reGenerate,
                      style: TST.smallTextBold.copyWith(color: CST.primary100),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 매치 생성 함수
  void _generateMatches() {
    // 코트 수를 입력값에서 가져옴
    int courts;
    try {
      courts = int.parse(_courtsController.text);
      final maxCourts = widget.players.length ~/ 4;

      // 코트 수가 0이하거나 선수 수/4보다 크면 제한
      if (courts <= 0 || courts > maxCourts) {
        // UI 피드백 제공
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.courtNumberLimitError)),
        );
        // 기본값으로 설정
        courts = maxCourts;
        _courtsController.text = courts.toString();
      }
    } catch (e) {
      // 숫자 변환 실패 시 기본값 사용
      courts = widget.players.length ~/ 4;
      _courtsController.text = courts.toString();
    }

    // 액션 실행
    debugPrint('매치 생성 - 코트 수: $courts');
    
    // 현재 파트너 쌍 정보 로깅
    debugPrint('현재 파트너 쌍 정보: ${widget.tournament.partnerPairs.length}개');
    for (var pair in widget.tournament.partnerPairs) {
      debugPrint('  - ${pair[0]} & ${pair[1]}');
    }
    
    // 파트너 쌍 정보를 활용하여 매치 생성
    debugPrint('파트너 쌍 정보를 활용하여 매치 생성 (파트너 쌍: ${widget.tournament.partnerPairs.length}개)');
    final action = CreatePartnerTournamentAction.generateMatchesWithPartners(
      courts, 
      widget.tournament.partnerPairs
    );
    debugPrint('생성된 액션: $action');
    widget.onAction(action);
    
    // 매치 생성 후 파트너 매칭 모드 유지
    widget.onAction(
      CreatePartnerTournamentAction.updateIsPartnerMatching(true),
    );
  }

  // 매치 아이템 위젯
  Widget _buildMatchItem(int index, MatchModel match) {
    final isDoubles = widget.tournament.isDoubles;

    // MatchModel의 playerA, playerB, playerC, playerD 필드를 사용
    final teamAName =
        isDoubles && match.playerC != null
            ? "${match.playerA ?? ''} / ${match.playerC ?? ''}"
            : match.playerA ?? AppStrings.noPlayer;

    final teamBName =
        isDoubles && match.playerD != null
            ? "${match.playerB ?? ''} / ${match.playerD ?? ''}"
            : match.playerB ?? AppStrings.noPlayer;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CST.gray3.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: CST.primary100,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: TST.smallTextBold.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 8), // 간격 더 축소
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround, // 균등 분배
                children: [
                  Flexible(
                    flex: 2, // 비율 할당
                    child: Center(child: _buildTeam(teamAName, isDoubles)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: CST.primary40.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CST.primary60.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      AppStrings.versus,
                      style: TST.smallTextBold.copyWith(color: CST.primary100),
                    ),
                  ),
                  Flexible(
                    flex: 2, // 비율 할당
                    child: Center(child: _buildTeam(teamBName, isDoubles)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 플레이어 이름 위젯
  Widget _buildPlayerName(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      // 고정 너비 제거하고 필요한 만큼만 차지하도록 설정
      constraints: const BoxConstraints(
        minWidth: 40, // 최소 너비 설정
        maxWidth: 100, // 최대 너비 설정
      ),
      decoration: BoxDecoration(
        color: CST.primary40.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: CST.primary60.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Text(
        name,
        style: TST.smallTextBold,
        overflow: TextOverflow.ellipsis, // 이름이 길면 말줄임표로 처리
        maxLines: 1, // 한 줄로 제한
        textAlign: TextAlign.center, // 텍스트 중앙 정렬
      ),
    );
  }

  // 팀 위젯
  Widget _buildTeam(String teamName, bool isDoubles) {
    // 복식인 경우 '/'로 구분된 이름을 분리
    final names = isDoubles ? teamName.split('/') : [teamName];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // 중앙 정렬
      children: [...names.map((name) => _buildPlayerName(name.trim()))],
    );
  }
}
