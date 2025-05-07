import 'package:bracket_helper/presentation/create_partner_tournament/create_partner_tournament_action.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/create_partner_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/screens/partner_edit_match/partner_edit_match_screen.dart';
import 'package:flutter/material.dart';

class PartnerEditMatchRoot extends StatefulWidget {
  final CreatePartnerTournamentViewModel viewModel;
  const PartnerEditMatchRoot({super.key, required this.viewModel});

  @override
  State<PartnerEditMatchRoot> createState() => _PartnerEditMatchRootState();
}

class _PartnerEditMatchRootState extends State<PartnerEditMatchRoot> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // 매치가 없는 경우 자동 생성
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.viewModel.state.matches.isEmpty &&
          widget.viewModel.state.players.isNotEmpty) {
        _generateMatches();
      }
    });
  }

  // 매치 자동 생성
  void _generateMatches() {
    debugPrint('EditMatchRoot: _generateMatches() 함수 호출');

    setState(() {
      _isLoading = true;
    });

    try {
      // 기본 코트 수 설정
      final defaultCourts = widget.viewModel.state.players.isEmpty 
          ? 1 
          : widget.viewModel.state.players.length ~/ 4;
          
      // 파트너 쌍 정보를 활용하여 매치 생성
      final tournament = widget.viewModel.state.tournament;
      
      debugPrint('파트너 쌍 정보를 활용하여 매치 생성 (파트너 쌍: ${tournament.partnerPairs.length}개)');
      final generateAction = CreatePartnerTournamentAction.generateMatchesWithPartners(
        defaultCourts,
        tournament.partnerPairs,
      );
      debugPrint('파트너 쌍을 활용한 매치 생성 액션 생성됨: $generateAction');
      widget.viewModel.onAction(generateAction);
    } catch (e) {
      debugPrint('매치 생성 액션 실행 중 오류: $e');
    }

    // 잠시 후 로딩 상태 해제
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return PartnerEditMatchScreen(
          tournament: widget.viewModel.state.tournament,
          players: widget.viewModel.state.players,
          matches: widget.viewModel.state.matches,
          isLoading: _isLoading,
          isEditMode: widget.viewModel.state.isEditMode,
          onAction: (action) {
            debugPrint('EditMatchRoot - 액션 전달: $action');

            // 매치 생성 액션을 별도 처리
            if (action.toString().contains('generateMatches') ||
                action.toString().contains('GenerateMatches')) {
              debugPrint('매치 생성 액션을 특별 처리합니다');
              _generateMatches();
            } else {
              // 다른 모든 액션 전달
              widget.viewModel.onAction(action);
            }
          },
        );
      },
    );
  }
}
