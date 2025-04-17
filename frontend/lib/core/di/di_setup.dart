import 'package:bracket_helper/data/database/app_database.dart';
import 'package:bracket_helper/data/dao/group_dao.dart';
import 'package:bracket_helper/data/dao/match_dao.dart';
import 'package:bracket_helper/data/dao/player_dao.dart';
import 'package:bracket_helper/data/dao/team_dao.dart';
import 'package:bracket_helper/data/dao/tournament_dao.dart';
import 'package:bracket_helper/data/repository/group_repository_impl.dart';
import 'package:bracket_helper/data/repository/match_repository_impl.dart';
import 'package:bracket_helper/data/repository/player_repository_impl.dart';
import 'package:bracket_helper/data/repository/team_repository_impl.dart';
import 'package:bracket_helper/data/repository/tournament_repository_impl.dart';
import 'package:bracket_helper/domain/repository/group_repository.dart';
import 'package:bracket_helper/domain/repository/match_repository.dart';
import 'package:bracket_helper/domain/repository/player_repository.dart';
import 'package:bracket_helper/domain/repository/team_repository.dart';
import 'package:bracket_helper/domain/repository/tournament_repository.dart';
import 'package:bracket_helper/domain/use_case/group/add_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/add_player_to_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/player/add_player_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/create_match_use_case.dart';
import 'package:bracket_helper/domain/use_case/team/create_team_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/create_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/delete_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/delete_match_use_case.dart';
import 'package:bracket_helper/domain/use_case/player/delete_player_use_case.dart';
import 'package:bracket_helper/domain/use_case/team/delete_team_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/delete_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_all_groups_use_case.dart';
import 'package:bracket_helper/domain/use_case/player/get_all_players_use_case.dart';
import 'package:bracket_helper/domain/use_case/team/get_all_teams_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_all_tournaments_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/get_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/get_matches_in_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/group/remove_player_from_group_use_case.dart';
import 'package:bracket_helper/presentation/home/home_view_model.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

/// 앱 시작 시 호출되어 의존성을 등록하는 함수
Future<void> setupDependencies() async {
  // 데이터베이스 인스턴스 등록 (싱글톤)
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // DAO 등록 (데이터베이스에 의존)
  getIt.registerLazySingleton<PlayerDao>(() => PlayerDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<GroupDao>(() => GroupDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<TeamDao>(() => TeamDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<MatchDao>(() => MatchDao(getIt<AppDatabase>()));
  getIt.registerLazySingleton<TournamentDao>(
    () => TournamentDao(getIt<AppDatabase>()),
  );

  // 레포지토리 등록
  getIt.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(getIt<GroupDao>()),
  );
  getIt.registerLazySingleton<PlayerRepository>(
    () => PlayerRepositoryImpl(getIt<PlayerDao>()),
  );
  getIt.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(getIt<TeamDao>()),
  );
  getIt.registerLazySingleton<MatchRepository>(
    () => MatchRepositoryImpl(getIt<MatchDao>()),
  );
  getIt.registerLazySingleton<TournamentRepository>(
    () => TournamentRepositoryImpl(
      getIt<TournamentDao>(),
      getIt<MatchDao>(),
      getIt<AppDatabase>(),
    ),
  );

  // 유스케이스 등록
  getIt.registerLazySingleton<AddPlayerToGroupUseCase>(
    () => AddPlayerToGroupUseCase(
      getIt<GroupRepository>(),
      getIt<PlayerRepository>(),
    ),
  );
  getIt.registerLazySingleton<AddGroupUseCase>(
    () => AddGroupUseCase(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<AddPlayerUseCase>(
    () => AddPlayerUseCase(getIt<PlayerRepository>()),
  );
  getIt.registerLazySingleton<CreateTeamUseCase>(
    () => CreateTeamUseCase(getIt<TeamRepository>(), getIt<PlayerRepository>()),
  );
  getIt.registerLazySingleton<CreateMatchUseCase>(
    () => CreateMatchUseCase(getIt<MatchRepository>(), getIt<TeamRepository>()),
  );
  getIt.registerLazySingleton<CreateTournamentUseCase>(
    () => CreateTournamentUseCase(getIt<TournamentRepository>()),
  );
  getIt.registerLazySingleton<DeleteGroupUseCase>(
    () => DeleteGroupUseCase(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<DeletePlayerUseCase>(
    () => DeletePlayerUseCase(getIt<PlayerRepository>()),
  );
  getIt.registerLazySingleton<DeleteMatchUseCase>(
    () => DeleteMatchUseCase(getIt<MatchRepository>()),
  );
  getIt.registerLazySingleton<DeleteTeamUseCase>(
    () => DeleteTeamUseCase(getIt<TeamRepository>()),
  );
  getIt.registerLazySingleton<DeleteTournamentUseCase>(
    () => DeleteTournamentUseCase(getIt<TournamentRepository>()),
  );
  getIt.registerLazySingleton<GetGroupUseCase>(
    () => GetGroupUseCase(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<GetAllPlayersUseCase>(
    () => GetAllPlayersUseCase(getIt<PlayerRepository>()),
  );
  getIt.registerLazySingleton<GetAllGroupsUseCase>(
    () => GetAllGroupsUseCase(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<GetAllTeamsUseCase>(
    () => GetAllTeamsUseCase(getIt<TeamRepository>()),
  );
  getIt.registerLazySingleton<GetAllTournamentsUseCase>(
    () => GetAllTournamentsUseCase(getIt<TournamentRepository>()),
  );
  getIt.registerLazySingleton<GetMatchesInTournamentUseCase>(
    () => GetMatchesInTournamentUseCase(getIt<TournamentRepository>()),
  );
  getIt.registerLazySingleton<RemovePlayerFromGroupUseCase>(
    () => RemovePlayerFromGroupUseCase(getIt<GroupRepository>()),
  );

  // 뷰모델 등록
  getIt.registerFactory<HomeViewModel>(
    () => HomeViewModel(
      getAllTournamentsUseCase: getIt<GetAllTournamentsUseCase>(),
      deleteTournamentUseCase: getIt<DeleteTournamentUseCase>(),
    ),
  );
}
