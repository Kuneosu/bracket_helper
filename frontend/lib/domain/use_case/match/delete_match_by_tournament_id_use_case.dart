import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/domain/repository/match_repository.dart';

class DeleteMatchByTournamentIdUseCase {
  final MatchRepository _matchRepository;

  DeleteMatchByTournamentIdUseCase(this._matchRepository);

  Future<Result<void>> execute(int tournamentId) async {
    try {
      await _matchRepository.deleteMatchesByTournamentId(tournamentId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        DatabaseError(message: '매치 삭제에 실패했습니다.', cause: e),
      );
    }
  }
}
