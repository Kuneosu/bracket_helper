// singles_bracket_scheduler.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';

class SinglesBracketScheduler {
  /// 단식 라운드 로빈 방식으로 대진표 생성
  /// [players]  : 참가 선수 (4 ~ 32)
  /// [courts]   : 동시에 뛸 코트 수 (1 ~ ⌊N / 2⌋)
  /// [seed]     : 결과 재현용 시드 (null ⇒ 난수)
  static List<MatchModel> generate(
    List<PlayerModel> players, {
    required int courts,
    int? gamesPer, // 더 이상 사용하지 않지만 호환성을 위해 남겨둠
    int? seed,
    int restart = 3000,
  }) {
    if (players.length < 4 || players.length > 32) {
      throw ArgumentError('인원수는 4~32 명만 지원합니다.');
    }
    final maxCourt = players.length ~/ 2; // 단식이므로 2로 나눔
    if (courts < 1 || courts > maxCourt) {
      throw ArgumentError('코트 수는 1~$maxCourt 사이여야 합니다.');
    }

    // 라운드 로빈 방식 - 모든 플레이어가 서로 한 번씩 만나는 방식
    // 필요한 총 경기 수: n * (n-1) / 2
    final n = players.length;
    final totalMatches = (n * (n - 1)) ~/ 2;
    
    debugPrint('단식 라운드 로빈 대진표 생성 시작 - 선수: ${players.length}명, 필요 매치: $totalMatches개');
    
    // 라운드 로빈 스케줄 생성
    return _generateRoundRobin(players, courts, seed);
  }

  /// 라운드 로빈 방식 대진표 생성
  /// 모든 플레이어가 다른 모든 플레이어와 1번씩 경기
  static List<MatchModel> _generateRoundRobin(
    List<PlayerModel> players,
    int courts,
    int? seed,
  ) {
    // seed가 null이면 시드 없이 Random 생성, 아니면 시드 사용
    final random = seed != null ? Random(seed) : Random();
    final playerNames = players.map((p) => p.name).toList();
    
    // 선수 목록을 섞어서 대진표의 다양성 확보
    playerNames.shuffle(random);
    
    final n = playerNames.length;
    final matches = <MatchModel>[];
    int matchId = 1;
    
    // 모든 가능한 조합을 생성하는 알고리즘
    final combinations = <List<String>>[];
    
    for (int i = 0; i < n; i++) {
      for (int j = i + 1; j < n; j++) {
        combinations.add([playerNames[i], playerNames[j]]);
      }
    }
    
    // 생성된 조합 로그 출력
    debugPrint('라운드 로빈 조합 총 ${combinations.length}개 생성됨');
    
    // 조합을 섞어서 무작위 대진 생성
    combinations.shuffle(random);
    
    // 라운드별로 조합 분류 (한 선수가 한 라운드에서 여러 번 경기하지 않도록)
    final rounds = <List<List<String>>>[];
    final remainingCombos = List<List<String>>.from(combinations);
    
    while (remainingCombos.isNotEmpty) {
      final roundMatches = <List<String>>[];
      final usedPlayers = <String>{};
      
      // 이번 라운드에서 가능한 만큼 매치 선택
      for (int i = 0; i < remainingCombos.length; i++) {
        final combo = remainingCombos[i];
        if (!usedPlayers.contains(combo[0]) && !usedPlayers.contains(combo[1])) {
          roundMatches.add(combo);
          usedPlayers.add(combo[0]);
          usedPlayers.add(combo[1]);
          remainingCombos.removeAt(i);
          i--; // 요소를 제거했으므로 인덱스 조정
        }
      }
      
      if (roundMatches.isNotEmpty) {
        rounds.add(roundMatches);
      } else {
        // 더 이상 이번 라운드에 넣을 수 있는 매치가 없으면 다음 라운드로
        break;
      }
    }
    
    // 남은 조합이 있다면 추가 라운드로 처리
    while (remainingCombos.isNotEmpty) {
      final additionalRound = <List<String>>[];
      final usedPlayers = <String>{};
      
      for (int i = 0; i < remainingCombos.length; i++) {
        final combo = remainingCombos[i];
        // 이미 이번 라운드에 선택된 선수는 피하기
        if (!usedPlayers.contains(combo[0]) && !usedPlayers.contains(combo[1])) {
          additionalRound.add(combo);
          usedPlayers.add(combo[0]);
          usedPlayers.add(combo[1]);
          remainingCombos.removeAt(i);
          i--; // 요소를 제거했으므로 인덱스 조정
        }
      }
      
      if (additionalRound.isNotEmpty) {
        rounds.add(additionalRound);
      } else {
        // 더 이상 추가할 수 없는 경우 (이론적으로는 여기 도달하지 않아야 함)
        if (remainingCombos.isNotEmpty) {
          debugPrint('경고: 일부 조합을 라운드에 배치할 수 없었습니다. 남은 조합: ${remainingCombos.length}개');
          // 남은 조합을 마지막 라운드에 강제로 추가
          rounds.add(remainingCombos);
          break;
        }
      }
    }
    
    // 각 라운드의 경기 수 출력
    for (int i = 0; i < rounds.length; i++) {
      debugPrint('라운드 ${i + 1}: ${rounds[i].length}개 매치');
    }
    
    // MatchModel로 변환
    for (int roundIdx = 0; roundIdx < rounds.length; roundIdx++) {
      final roundMatches = rounds[roundIdx];
      
      for (final pair in roundMatches) {
        matches.add(MatchModel(
          id: matchId++,
          ord: roundIdx + 1, // 라운드 번호
          playerA: pair[0],
          playerB: pair[1],
          playerC: null, // 단식이므로 null
          playerD: null, // 단식이므로 null
        ));
      }
    }
    
    // 결과 분석 및 출력
    _analyzeMatches(matches);
    
    return matches;
  }
  
  /// 대진표 분석 및 결과 출력
  static void _analyzeMatches(List<MatchModel> matches) {
    // 각 선수별 경기 수 확인
    final playerGames = <String, int>{};
    
    // 각 선수별 상대 선수 확인 (각 상대와 몇 번 만나는지)
    final playerOpponents = <String, Map<String, int>>{};
    
    for (final match in matches) {
      final playerA = match.playerA!;
      final playerB = match.playerB!;
      
      // 각 선수의 경기 수 카운트
      playerGames[playerA] = (playerGames[playerA] ?? 0) + 1;
      playerGames[playerB] = (playerGames[playerB] ?? 0) + 1;
      
      // 상대방 기록
      playerOpponents.putIfAbsent(playerA, () => {});
      playerOpponents.putIfAbsent(playerB, () => {});
      
      playerOpponents[playerA]![playerB] = (playerOpponents[playerA]![playerB] ?? 0) + 1;
      playerOpponents[playerB]![playerA] = (playerOpponents[playerB]![playerA] ?? 0) + 1;
    }
    
    // 결과 출력
    debugPrint('===== 대진표 분석 결과 =====');
    debugPrint('총 경기 수: ${matches.length}개');
    
    // 각 선수별 경기 수
    debugPrint('각 선수별 경기 수:');
    playerGames.forEach((player, gameCount) {
      debugPrint('  $player: $gameCount경기');
    });
    
    // 각 선수별 상대방 확인
    debugPrint('각 선수별 상대방 만난 횟수:');
    playerOpponents.forEach((player, opponents) {
      final details = opponents.entries
          .map((e) => '${e.key}(${e.value}회)')
          .join(', ');
      
      debugPrint('  $player -> $details');
    });
    
    // 라운드별 경기 수
    final roundCounts = <int, int>{};
    for (final match in matches) {
      final ord = match.ord ?? 0; // null일 경우 기본값 0 사용
      roundCounts[ord] = (roundCounts[ord] ?? 0) + 1;
    }
    
    debugPrint('라운드별 경기 수:');
    roundCounts.forEach((round, count) {
      debugPrint('  라운드 $round: $count경기');
    });
  }
}
