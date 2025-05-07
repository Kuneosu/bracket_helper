import 'package:bracket_helper/presentation/create_partner_tournament/create_partner_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/screens/partner_tournament_info/partner_tournament_info_screen.dart';
import 'package:flutter/widgets.dart';

class PartnerTournamentInfoRoot extends StatelessWidget {
  final CreatePartnerTournamentViewModel viewModel;
  const PartnerTournamentInfoRoot({super.key, required this.viewModel});

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
        return PartnerTournamentInfoScreen(
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
