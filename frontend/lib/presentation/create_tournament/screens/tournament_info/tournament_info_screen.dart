import 'package:bracket_helper/core/presentation/components/default_date_picker.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:bracket_helper/presentation/create_tournament/widgets/index.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TournamentInfoScreen extends StatefulWidget {
  final TournamentModel tournament;
  final Function(CreateTournamentAction) onAction;
  const TournamentInfoScreen({
    super.key,
    required this.tournament,
    required this.onAction,
  });

  @override
  State<TournamentInfoScreen> createState() => _TournamentInfoScreenState();
}

class _TournamentInfoScreenState extends State<TournamentInfoScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.tournament.title);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _titleFocusNode.addListener(_onFocusChange);
    debugPrint('TournamentInfoScreen - initState 호출');
  }

  void _onFocusChange() {
    if (!_titleFocusNode.hasFocus) {
      // 포커스가 빠져나갈 때만 상태 업데이트
      widget.onAction(
        CreateTournamentAction.onTitleChanged(_titleController.text),
      );
    }
  }

  @override
  void didUpdateWidget(TournamentInfoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('TournamentInfoScreen - didUpdateWidget 호출');

    if (oldWidget.tournament.title != widget.tournament.title) {
      _titleController.text = widget.tournament.title;
      debugPrint('TournamentInfoScreen - 타이틀 변경됨: ${widget.tournament.title}');
    }

    if (oldWidget.tournament.date != widget.tournament.date) {
      debugPrint('TournamentInfoScreen - 날짜 변경됨: ${widget.tournament.date}');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _animationController.dispose();
    _titleFocusNode.removeListener(_onFocusChange);
    _titleFocusNode.dispose();
    debugPrint('TournamentInfoScreen - dispose 호출');
    super.dispose();
  }

  // BuildContext 저장 변수 추가
  BuildContext? _safeContext;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 현재 유효한 BuildContext를 저장
    _safeContext = context;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('TournamentInfoScreen - build 호출: 날짜 ${widget.tournament.date}');

    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: CST.primary20,
        child: Column(
          children: [
            // 콘텐츠 영역 (스크롤 가능)
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            AppStrings.tournamentInfoInput,
                            style: TST.headerTextBold.copyWith(
                              color: CST.primary100,
                              fontSize: 22,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: CST.primary100,
                            ),
                            tooltip: AppStrings.reset,
                            onPressed: () {
                              _showResetConfirmationDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTitleSection(),
                      const SizedBox(height: 16),
                      _buildDateSection(),
                      const SizedBox(height: 16),
                      _buildScoreSection(),
                      const SizedBox(height: 16),
                      _buildGameSettingsSection(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 고정 버튼 영역
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return SectionCardWidget(
      title: AppStrings.tournamentName,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            focusNode: _titleFocusNode,
            decoration: InputDecoration(
              hintText: AppStrings.enterTournamentName,
              hintStyle: TST.mediumTextRegular.copyWith(color: CST.gray3),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: CST.gray3),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CST.gray3),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CST.primary100, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.emoji_events, color: CST.primary100),
              filled: true,
              fillColor: Colors.white,
            ),
            enableIMEPersonalizedLearning: true,
            enableInteractiveSelection: true,
            enableSuggestions: true,
            keyboardType: TextInputType.text,
            onSubmitted: (value) {
              widget.onAction(CreateTournamentAction.onTitleChanged(value));
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: CST.gray2),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  AppStrings.tournamentNameAutoSetInfo,
                  style: TST.smallerTextRegular.copyWith(color: CST.gray2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return SectionCardWidget(
      title: AppStrings.tournamentDate,
      content: DefaultDatePicker(
        initialDate: widget.tournament.date,
        onDateSelected: (date) {
          debugPrint('날짜 선택됨: $date');
          widget.onAction(CreateTournamentAction.onDateChanged(date));
        },
      ),
    );
  }

  Widget _buildScoreSection() {
    return SectionCardWidget(
      title: AppStrings.scoreInput,
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ScoreInputWidget(
            label: AppStrings.win,
            color: CST.success,
            initialValue: widget.tournament.winPoint.toString(),
            onChanged:
                (value) => widget.onAction(
                  CreateTournamentAction.onScoreChanged(value, '승'),
                ),
          ),
          ScoreInputWidget(
            label: AppStrings.draw,
            color: CST.gray2,
            initialValue: widget.tournament.drawPoint.toString(),
            onChanged:
                (value) => widget.onAction(
                  CreateTournamentAction.onScoreChanged(value, '무'),
                ),
          ),
          ScoreInputWidget(
            label: AppStrings.lose,
            color: CST.error,
            initialValue: widget.tournament.losePoint.toString(),
            onChanged:
                (value) => widget.onAction(
                  CreateTournamentAction.onScoreChanged(value, '패'),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameSettingsSection() {
    return SectionCardWidget(
      title: AppStrings.gameSettings,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // 복식/단식 토글 버튼
          Container(
            decoration: BoxDecoration(
              color: CST.gray4,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                // 복식 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!widget.tournament.isDoubles) {
                        widget.onAction(
                          CreateTournamentAction.onIsDoublesChanged(true),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            widget.tournament.isDoubles
                                ? CST.primary100
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow:
                            widget.tournament.isDoubles
                                ? [
                                  BoxShadow(
                                    color: CST.primary100.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people,
                            size: 18,
                            color:
                                widget.tournament.isDoubles
                                    ? CST.white
                                    : CST.gray1,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.doubles,
                            style: TST.normalTextBold.copyWith(
                              color:
                                  widget.tournament.isDoubles
                                      ? CST.white
                                      : CST.gray1,
                            ).copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // 단식 버튼
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.tournament.isDoubles) {
                        widget.onAction(
                          CreateTournamentAction.onIsDoublesChanged(false),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            !widget.tournament.isDoubles
                                ? CST.primary100
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow:
                            !widget.tournament.isDoubles
                                ? [
                                  BoxShadow(
                                    color: CST.primary100.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                                : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.person,
                            size: 18,
                            color:
                                !widget.tournament.isDoubles
                                    ? CST.white
                                    : CST.gray1,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.singles,
                            style: TST.normalTextBold.copyWith(
                              color:
                                  !widget.tournament.isDoubles
                                      ? CST.white
                                      : CST.gray1,
                            ).copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return NavigationButtonsWidget(
      previousText: AppStrings.exit,
      onPrevious: () async {
        // 안전한 컨텍스트 사용
        final ctx = _safeContext ?? context;

        // 종료 전 확인 다이얼로그 표시
        final shouldExit = await _showExitConfirmationDialog(ctx);
        if (shouldExit) {
          if (mounted && ctx.mounted) {
            ctx.go(RoutePaths.home);
            widget.onAction(CreateTournamentAction.onDiscard());
          }
        }
      },
      onNext: () {
        // 안전한 컨텍스트 사용
        final ctx = _safeContext ?? context;
        if (!mounted || !ctx.mounted) return;

        // 현재 TextField에 포커스가 있다면 강제로 포커스 해제하여 텍스트 업데이트
        if (_titleFocusNode.hasFocus) {
          FocusScope.of(context).unfocus();
        }

        // 프로세스 진행 상태만 업데이트
        debugPrint('TournamentInfoScreen - 다음 버튼 클릭');
        widget.onAction(CreateTournamentAction.updateProcess(1));
        ctx.go('${RoutePaths.createTournament}${RoutePaths.addPlayer}');
      },
    );
  }

  // 종료 확인 다이얼로그
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: CST.primary100,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.exitTournamentCreation,
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.exitTournamentConfirm,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.unsavedChangesWarning,
                  style: TST.smallTextRegular.copyWith(color: CST.gray2),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: CST.white,
                  backgroundColor: CST.gray3,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppStrings.cancel, style: TST.smallTextBold),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CST.primary100,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  AppStrings.exitTournament,
                  style: TST.smallTextBold,
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            buttonPadding: EdgeInsets.zero,
          ),
    );

    return result ?? false;
  }

  // 초기화 확인 다이얼로그
  Future<void> _showResetConfirmationDialog(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Row(
              children: [
                const Icon(Icons.refresh, color: CST.primary100, size: 28),
                const SizedBox(width: 12),
                Text(
                  AppStrings.resetInput,
                  style: TST.normalTextBold.copyWith(color: CST.primary100),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.resetConfirm,
                  style: TST.normalTextBold.copyWith(color: CST.gray1),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.resetWarning,
                  style: TST.smallTextRegular.copyWith(color: CST.gray2),
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: CST.white,
                  backgroundColor: CST.gray3,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppStrings.cancel, style: TST.smallTextBold),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CST.primary100,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  widget.onAction(CreateTournamentAction.resetState());
                  Navigator.of(context).pop(true);
                },
                child: Text(AppStrings.resetButton, style: TST.smallTextBold),
              ),
            ],
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            buttonPadding: EdgeInsets.zero,
          ),
    );
  }
}
