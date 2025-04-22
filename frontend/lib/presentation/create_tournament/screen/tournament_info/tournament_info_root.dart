import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/tournament_info/tournament_info_screen.dart';
import 'package:flutter/widgets.dart';

class TournamentInfoRoot extends StatelessWidget {
  final CreateTournamentViewModel viewModel;
  const TournamentInfoRoot({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        debugPrint('TournamentInfoRoot - build: 날짜 ${viewModel.state.tournament.date}');
        debugPrint('TournamentInfoRoot - 현재 선수 목록 수: ${viewModel.state.players.length}');
        if (viewModel.state.players.isNotEmpty) {
          debugPrint('TournamentInfoRoot - 선수 목록: ${viewModel.state.players.map((p) => "${p.id}:${p.name}").join(', ')}');
        }
        return TournamentInfoScreen(
          tournament: viewModel.state.tournament,
          onAction: (action) {
            debugPrint('TournamentInfoRoot - 액션 전달: $action');
            viewModel.onAction(action);
          },
        );
      },
    );
  }
}
