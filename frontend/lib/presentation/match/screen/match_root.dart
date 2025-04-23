import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/presentation/match/match_view_model.dart';
import 'package:bracket_helper/presentation/match/screen/match_screen.dart';
import 'package:flutter/material.dart';

class MatchRoot extends StatelessWidget {
  final String? tournamentIdStr;
  
  const MatchRoot({
    super.key, 
    this.tournamentIdStr,
  });

  @override
  Widget build(BuildContext context) {
    // tournamentId 변환 (기본값 1)
    final int tournamentId = int.tryParse(tournamentIdStr ?? '') ?? 1;
    
    // 파라미터를 사용하여 ViewModel 생성
    final viewModel = getIt<MatchViewModel>(param1: tournamentId);
    
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return MatchScreen(
          tournament: viewModel.state.tournament,
          matches: viewModel.state.matches,
          players: viewModel.state.players,
          isLoading: viewModel.state.isLoading,
        );
      },
    );
  }
}