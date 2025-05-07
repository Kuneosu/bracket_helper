import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/core/di/di_setup.dart';
import 'package:bracket_helper/domain/model/tournament_model.dart';
import 'package:bracket_helper/domain/use_case/match/get_all_matches_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/delete_tournament_use_case.dart';
import 'package:bracket_helper/domain/use_case/tournament/get_all_tournaments_use_case.dart';
import 'package:bracket_helper/domain/use_case/config/check_new_version_use_case.dart';
import 'package:bracket_helper/presentation/create_partner_tournament/create_partner_tournament_view_model.dart';
import 'package:bracket_helper/presentation/create_tournament/create_tournament_view_model.dart';
import 'package:bracket_helper/presentation/home/home_action.dart';
import 'package:bracket_helper/presentation/home/home_state.dart';
import 'package:bracket_helper/presentation/home/widgets/help_dialog.dart';
import 'package:bracket_helper/presentation/home/widgets/tournament_delete_dialog.dart';
import 'package:bracket_helper/presentation/home/widgets/update_available_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bracket_helper/core/routing/route_paths.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeViewModel with ChangeNotifier {
  final List<TournamentModel> _tournaments = [];
  HomeState _state = HomeState();
  HomeState get state => _state;
  final GetAllTournamentsUseCase _getAllTournamentsUseCase;
  final DeleteTournamentUseCase _deleteTournamentUseCase;
  final GetAllMatchesUseCase _getAllMatchesUseCase;
  final CheckNewVersionUseCase _checkNewVersionUseCase;

  List<TournamentModel> get tournaments => _tournaments;

  HomeViewModel({
    required GetAllTournamentsUseCase getAllTournamentsUseCase,
    required DeleteTournamentUseCase deleteTournamentUseCase,
    required GetAllMatchesUseCase getAllMatchesUseCase,
    required CheckNewVersionUseCase checkNewVersionUseCase,
  }) : _getAllTournamentsUseCase = getAllTournamentsUseCase,
       _deleteTournamentUseCase = deleteTournamentUseCase,
       _getAllMatchesUseCase = getAllMatchesUseCase,
       _checkNewVersionUseCase = checkNewVersionUseCase {
    _fetchTournaments();
  }

  Future<void> _fetchTournaments() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final result = await _getAllTournamentsUseCase.execute();

      if (result.isSuccess) {
        final tournaments = result.value;
        _tournaments.clear();
        _tournaments.addAll(tournaments);
        _state = _state.copyWith(tournaments: tournaments, isLoading: false);
      } else {
        _state = _state.copyWith(
          errorMessage: result.error.message,
          isLoading: false,
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: '토너먼트 목록을 불러오는 중 오류가 발생했습니다: $e',
        isLoading: false,
      );
    }

    notifyListeners();
  }

  Future<void> deleteTournament(int tournamentId) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();
    final result = await _deleteTournamentUseCase.execute(tournamentId);
    if (result.isSuccess) {
      _tournaments.removeWhere((tournament) => tournament.id == tournamentId);
      notifyListeners();
    } else {
      // 오류 처리 - 필요에 따라 추가 구현
    }
    _state = _state.copyWith(isLoading: false);
    notifyListeners();
  }

  Future<void> printAllMatches() async {
    try {
      final result = await _getAllMatchesUseCase.execute();
      if (result.isSuccess) {
        if (kDebugMode) {
          print('모든 매치 정보:');
          for (var match in result.value) {
            print(
              '매치 ID: ${match.id}, 순서: ${match.ord}, 토너먼트ID: ${match.tournamentId}',
            );
            print('플레이어A: ${match.playerA}, 플레이어B: ${match.playerB}');
            print('점수A: ${match.scoreA}, 점수B: ${match.scoreB}');
            if (match.playerC != null || match.playerD != null) {
              print(
                '더블스 매치 - 플레이어C: ${match.playerC}, 플레이어D: ${match.playerD}',
              );
            }
            print('-------------------');
          }
          print('총 ${result.value.length}개의 매치가 있습니다.');
        }
      } else {
        if (kDebugMode) {
          print('매치 정보 불러오기 실패: ${result.error.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('매치 정보 조회 중 오류 발생: $e');
      }
    }
  }

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final result = await _checkNewVersionUseCase.execute();
      
      if (result.isSuccess && result.value) {
        if (context.mounted) {
          final shouldGoToUpdate = await UpdateAvailableDialog.show(context: context);
          if (shouldGoToUpdate && context.mounted) {
            _handleCheckUpdate(context);
          }
        }
      }
    } catch (e) {
      debugPrint('업데이트 확인 중 오류 발생: $e');
    }
  }

  void onAction(HomeAction action, BuildContext context) {
    debugPrint('HomeViewModel - 액션: $action');

    switch (action) {
      case OnTapCreateTournament():
        _handleCreateTournament(context);
      case OnTapDeleteTournament():
        _handleDeleteTournament(action.tournamentId, context);
      case OnRefresh():
        debugPrint('HomeViewModel - 새로고침 요청');
        _fetchTournaments();
      case OnTapHelp():
        _handleHelp(context);
      case OnCheckUpdate():
        checkForUpdate(context);
      case OnTapAllTournament():
        return;
      case OnTapPlayerManagement():
        return;
      case OnTapGroupManagement():
        return;
      case OnTapStatistics():
        return;
      case OnTapMatchCard():
        return;
      case OnTapPartnerTournament():
        _handlePartnerTournament(context);
    }
  }

  void _handleCreateTournament(BuildContext context) {
    try {
      debugPrint('HomeViewModel - 대진표 생성 화면으로 이동');

      final hasViewModel = getIt.isRegistered<CreateTournamentViewModel>();

      if (hasViewModel) {
        debugPrint('CreateTournamentViewModel 인스턴스 초기화');

        try {
          getIt.unregister<CreateTournamentViewModel>();
          debugPrint('기존 CreateTournamentViewModel 인스턴스 제거 성공');
        } catch (e) {
          debugPrint('CreateTournamentViewModel 제거 중 오류: $e');
        }
      }

      context.go(RoutePaths.createTournament, extra: {'shouldReset': true});
    } catch (e) {
      debugPrint('HomeViewModel - 대진표 생성 화면 이동 중 예외 발생: $e');
    }
  }

  void _handlePartnerTournament(BuildContext context) {
    try {
      debugPrint('HomeViewModel - 대진표 생성 화면으로 이동');

      final hasViewModel =
          getIt.isRegistered<CreatePartnerTournamentViewModel>();

      if (hasViewModel) {
        debugPrint('CreatePartnerTournamentViewModel 인스턴스 초기화');

        try {
          getIt.unregister<CreatePartnerTournamentViewModel>();
          debugPrint('기존 CreatePartnerTournamentViewModel 인스턴스 제거 성공');
        } catch (e) {
          debugPrint('CreatePartnerTournamentViewModel 제거 중 오류: $e');
        }
      }

      context.go(
        RoutePaths.createPartnerTournament,
        extra: {'shouldReset': true},
      );
    } catch (e) {
      debugPrint('HomeViewModel - 대진표 생성 화면 이동 중 예외 발생: $e');
    }
  }

  Future<void> _handleDeleteTournament(int id, BuildContext context) async {
    debugPrint('HomeViewModel - 토너먼트 삭제 요청: ID $id');

    try {
      final shouldDelete = await TournamentDeleteDialog.show(context: context);
      if (shouldDelete != true) {
        debugPrint('HomeViewModel - 사용자가 삭제를 취소함');
        return;
      }

      _state = _state.copyWith(isLoading: true);
      notifyListeners();

      final result = await _deleteTournamentUseCase.execute(id);

      if (result.isSuccess) {
        debugPrint('HomeViewModel - 토너먼트 삭제 성공: ID $id');
        _fetchTournaments();
      } else {
        debugPrint('HomeViewModel - 토너먼트 삭제 실패: ${result.error.message}');
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: AppStrings.tournamentDeleteError,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('HomeViewModel - 토너먼트 삭제 중 예외 발생: $e');
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: AppStrings.tournamentDeleteError,
      );
      notifyListeners();
    }
  }

  void _handleHelp(BuildContext context) {
    debugPrint('HomeViewModel - 도움말 화면 표시');
    HelpDialog.show(context: context);
  }
  
  void _handleCheckUpdate(BuildContext context) {
    try {
      final Uri url = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.kuneosu.bracket_helper'
      );
      
      _launchAppStore(context, url);
    } catch (e) {
      debugPrint('스토어 URL 열기 실패: $e');
    }
  }
  
  void _launchAppStore(BuildContext context, Uri url) async {
    try {
      final canLaunch = await canLaunchUrl(url);
      if (canLaunch) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.storeOpenError)),
          );
        }
      }
    } catch (e) {
      debugPrint('스토어 URL 열기 실패: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.storeOpenError)),
        );
      }
    }
  }
}
