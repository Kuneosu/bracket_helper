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
import 'package:bracket_helper/domain/use_case/match/delete_match_by_tournament_id_use_case.dart';
import 'package:bracket_helper/domain/use_case/match/get_all_matches_use_case.dart';
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
import 'package:bracket_helper/domain/use_case/group/update_group_use_case.dart';
import 'package:bracket_helper/domain/use_case/player/update_player_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_tournament_by_id_use_case.dart';
import 'package:bracket_helper/presentation/home/home_view_model.dart';
import 'package:bracket_helper/presentation/match/match_view_model.dart';
import 'package:bracket_helper/presentation/save_player/save_player_view_model.dart';
import 'package:get_it/get_it.dart';
import 'package:bracket_helper/domain/use_case/group/count_players_in_group_use_case.dart';
import 'package:bracket_helper/data/data_source/config_data_source.dart';
import 'package:bracket_helper/data/repository/config_repository.dart';
import 'package:bracket_helper/data/services/config_service.dart';
import 'package:bracket_helper/domain/use_case/config/check_new_version_use_case.dart';

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

  // 앱 설정 관련 의존성 등록
  getIt.registerLazySingleton<ConfigDataSource>(() => GithubConfigDataSource());
  getIt.registerLazySingleton<ConfigService>(
    () => ConfigService(getIt<ConfigDataSource>()),
  );
  getIt.registerLazySingleton<ConfigRepository>(
    () => ConfigRepository(getIt<ConfigService>()),
  );
  getIt.registerLazySingleton<CheckNewVersionUseCase>(
    () => CheckNewVersionUseCase(getIt<ConfigRepository>()),
  );

  // 레포지토리 등록
  getIt.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(getIt<GroupDao>()),
  );
  getIt.registerLazySingleton<PlayerRepository>(
    () => PlayerRepositoryImpl(getIt<PlayerDao>()),
  );
  getIt.registerLazySingleton<TeamRepository>(
    () => TeamRepositoryImpl(getIt<TeamDao>(), getIt<PlayerDao>()),
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
    () => CreateMatchUseCase(getIt<MatchRepository>()),
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
  getIt.registerLazySingleton<UpdateGroupUseCase>(
    () => UpdateGroupUseCase(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<UpdatePlayerUseCase>(
    () => UpdatePlayerUseCase(getIt<PlayerRepository>()),
  );
  getIt.registerLazySingleton(
    () => CountPlayersInGroupUseCase(getIt<GroupRepository>()),
  );
  getIt.registerLazySingleton<GetAllMatchesUseCase>(
    () => GetAllMatchesUseCase(getIt<MatchRepository>()),
  );
  getIt.registerLazySingleton<GetTournamentByIdUseCase>(
    () => GetTournamentByIdUseCase(getIt<TournamentRepository>()),
  );
  getIt.registerLazySingleton<DeleteMatchByTournamentIdUseCase>(
    () => DeleteMatchByTournamentIdUseCase(getIt<MatchRepository>()),
  );

  // 뷰모델 등록
  getIt.registerFactory<HomeViewModel>(
    () => HomeViewModel(
      getAllTournamentsUseCase: getIt<GetAllTournamentsUseCase>(),
      deleteTournamentUseCase: getIt<DeleteTournamentUseCase>(),
      getAllMatchesUseCase: getIt<GetAllMatchesUseCase>(),
      checkNewVersionUseCase: getIt<CheckNewVersionUseCase>(),
    ),
  );
  
  // SavePlayerViewModel을 싱글톤으로 등록하여 항상 동일한 인스턴스 사용
  getIt.registerLazySingleton<SavePlayerViewModel>(
    () => SavePlayerViewModel(
      getAllGroupsUseCase: getIt<GetAllGroupsUseCase>(),
      addGroupUseCase: getIt<AddGroupUseCase>(),
      countPlayersInGroupUseCase: getIt<CountPlayersInGroupUseCase>(),
      deleteGroupUseCase: getIt<DeleteGroupUseCase>(),
      updateGroupUseCase: getIt<UpdateGroupUseCase>(),
      getGroupUseCase: getIt<GetGroupUseCase>(),
      addPlayerToGroupUseCase: getIt<AddPlayerToGroupUseCase>(),
      removePlayerFromGroupUseCase: getIt<RemovePlayerFromGroupUseCase>(),
      deletePlayerUseCase: getIt<DeletePlayerUseCase>(),
      updatePlayerUseCase: getIt<UpdatePlayerUseCase>(),
    ),
  );

  // MatchViewModel 등록 개선 - 팩토리로 등록하여 매번 새 인스턴스 생성
  getIt.registerFactoryParam<MatchViewModel, int, void>(
    (tournamentId, _) => MatchViewModel(
      tournamentId: tournamentId,
      getTournamentByIdUseCase: getIt<GetTournamentByIdUseCase>(),
      getMatchesInTournamentUseCase: getIt<GetMatchesInTournamentUseCase>(),
      deleteMatchUseCase: getIt<DeleteMatchUseCase>(),
      createMatchUseCase: getIt<CreateMatchUseCase>(),
      matchRepository: getIt<MatchRepository>(),
    ),
  );
}
