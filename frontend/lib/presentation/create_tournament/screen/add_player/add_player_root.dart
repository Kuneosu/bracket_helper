import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/screen/add_player/add_player_screen.dart';
import 'package:flutter/widgets.dart';

class AddPlayerRoot extends StatelessWidget {
  final CreateTournamentViewModel viewModel;
  const AddPlayerRoot({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        debugPrint('AddPlayerRoot - 화면 빌드: 선수 ${viewModel.state.players.length}명');
        if (viewModel.state.players.isNotEmpty) {
          debugPrint('AddPlayerRoot - 선수 목록: ${viewModel.state.players.map((p) => "${p.id}:${p.name}").join(', ')}');
        }
        return AddPlayerScreen(
          tournament: viewModel.state.tournament,
          players: viewModel.state.players,
          onAction: (action) {
            debugPrint('AddPlayerRoot - 액션 전달: $action');
            viewModel.onAction(action);
          },
        );
      },
    );
  }
} 