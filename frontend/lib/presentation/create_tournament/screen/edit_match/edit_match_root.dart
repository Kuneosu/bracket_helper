import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/edit_match/edit_match_screen.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_action.dart';
import 'package:flutter/material.dart';

class EditMatchRoot extends StatefulWidget {
  final CreateTournamentViewModel viewModel;
  const EditMatchRoot({super.key, required this.viewModel});

  @override
  State<EditMatchRoot> createState() => _EditMatchRootState();
}

class _EditMatchRootState extends State<EditMatchRoot> {
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
      // 새 매치 전달
      debugPrint('화면에서 매치 생성 버튼 클릭됨');
      final generateAction = const CreateTournamentAction.generateMatches();
      debugPrint('매치 생성 액션 생성됨: $generateAction');
      widget.viewModel.onAction(generateAction);
    } catch (e) {
      debugPrint('매치 생성 액션 실행 중 오류: $e');
    }
    
    // 잠시 후 로딩 상태 해제
    Future.delayed(const Duration(milliseconds: 300), () {
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
        return EditMatchScreen(
          tournament: widget.viewModel.state.tournament,
          players: widget.viewModel.state.players,
          matches: widget.viewModel.state.matches,
          isLoading: _isLoading,
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
