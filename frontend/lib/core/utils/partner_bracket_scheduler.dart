// bracket_scheduler.dart
//
// ──────────────────────────────────────────────────────────────
//  🎾 4-인 복식 대진표 생성기 - “고정 파트너 + 최대 중복 ≤ 2 최적화” 버전
//
//  • courts(코트 수) : 자동 ⌊players.length / 4⌋
//  • 고정 파트너로 지정된 쌍은 모든 경기에서 반드시 같은 팀
//  • 나머지 선수는 ‘같은 팀 중복’이 최대 2회를 넘지 않도록
//    TEAM_WEIGHT / OPP_WEIGHT 가중치 기반 탐색 + 최적 스케줄 선정
// ──────────────────────────────────────────────────────────────

import 'dart:math';

import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/team_model.dart';

class PartnerBracketScheduler {
  /// ▫️ players      : 참가 선수 (4 ~ 32명). `PlayerModel.name` 값이 유니크해야 합니다.
  /// ▫️ fixedPairs   : 고정 파트너 쌍 → `[ ['P1','P2'], ['P5','P6'] ]`
  /// ▫️ optimize     : true → `restart` 회 전부 탐색하여
  ///                   `(maxDup, avgDup)`가 가장 낮은 스케줄 선택
  ///                   (maxDup ≤ 2 에 도달하면 즉시 종료)
  /// ▫️ gamesPer     : 1인당 경기 수. 기본 4
  /// ▫️ teamWeight   : 같은 팀 중복 가중치 (기본 10)
  /// ▫️ oppWeight    : 상대 팀 중복 가중치 (기본 1)
  /// ▫️ restart      : 탐색(재시도) 횟수. 기본 8 000
  /// ▫️ lowerBound   : 조기 종료 목표값(최대 중복). 기본 2
  /// ▫️ seed         : 난수 시드 (null → 랜덤)
  static List<MatchModel> generate(
    List<PlayerModel> players, {
    List<List<String>> fixedPairs = const [],
    bool optimize = true,
    int gamesPer = 4,
    int teamWeight = 10,
    int oppWeight = 1,
    int restart = 8000,
    int lowerBound = 2,
    int? seed,
  }) {
    final n = players.length;
    if (n < 4 || n > 32) {
      throw ArgumentError('인원수는 4~32 명만 지원합니다.');
    }
    final courts = n ~/ 4;
    if (courts == 0) {
      throw StateError('코트 수를 계산할 수 없습니다 (인원 4명 미만)');
    }

    // ── 고정 파트너 맵 생성 & 검증 ──────────────────────────────
    final partnerOf = <String, String>{};
    for (final pair in fixedPairs) {
      if (pair.length != 2) {
        throw ArgumentError('fixedPairs 형식 오류: $pair');
      }
      partnerOf[pair[0]] = pair[1];
      partnerOf[pair[1]] = pair[0];
    }

    final nameSet = players.map((e) => e.name).toSet();
    for (final p in partnerOf.keys) {
      if (!nameSet.contains(p)) {
        throw ArgumentError('고정 파트너 $p 가 참가 명단에 없습니다.');
      }
    }

    // ── 탐색 루프 ───────────────────────────────────────────────
    final outerRand = Random(seed);
    _ScheduleResult? best;
    for (var i = 0; i < restart; i++) {
      final res = _buildOnce(
        players: players,
        courts: courts,
        gamesPer: gamesPer,
        partnerOf: partnerOf,
        teamWeight: teamWeight,
        oppWeight: oppWeight,
        rand: Random(outerRand.nextInt(1 << 30)),
      );
      if (res == null) continue; // 실패

      if (!optimize) {
        return _toMatchModel(res.schedule, res.slots, players);
      }

      if (best == null ||
          res.maxDup < best.maxDup ||
          (res.maxDup == best.maxDup && res.avgDup < best.avgDup)) {
        best = res;
        if (best.maxDup <= lowerBound) break; // 목표 달성 → 조기 종료
      }
    }

    if (best == null) {
      throw StateError('조건을 만족하는 대진표를 찾지 못했습니다.');
    }
    return _toMatchModel(best.schedule, best.slots, players);
  }

  // ──────────────────────────── internal ────────────────────────────

  static _ScheduleResult? _buildOnce({
    required List<PlayerModel> players,
    required int courts,
    required int gamesPer,
    required Map<String, String> partnerOf,
    required int teamWeight,
    required int oppWeight,
    required Random rand,
  }) {
    final names = players.map((e) => e.name).toList();
    final remain = {for (var n in names) n: gamesPer};
    final pairCnt = <String, Map<String, int>>{};
    final schedule = <_MatchInternal>[];
    final slots = <List<_MatchInternal>>[];

    bool isFixed(String a, String b) => partnerOf[a] == b;

    int overlapScore(List<String> t1, List<String> t2) {
      var s = 0;
      // 같은 팀 중복
      for (final a in t1) {
        for (final b in t1) {
          if (a != b && !isFixed(a, b)) {
            s += teamWeight * (pairCnt[a]?[b] ?? 0);
          }
        }
      }
      for (final a in t2) {
        for (final b in t2) {
          if (a != b && !isFixed(a, b)) {
            s += teamWeight * (pairCnt[a]?[b] ?? 0);
          }
        }
      }
      // 상대 팀 중복
      for (final a in t1) {
        for (final b in t2) {
          if (!isFixed(a, b)) {
            s += oppWeight * (pairCnt[a]?[b] ?? 0);
          }
        }
      }
      return s;
    }

    List<List<String>>? validSplit(List<String> g) {
      // g.length == 4
      for (var i = 0; i < 3; i++) {
        final t1 = [g[0], g[i + 1]];
        final t2 = g.where((p) => !t1.contains(p)).toList();
        bool ok = true;
        for (final team in [t1, t2]) {
          for (final p in team) {
            if (partnerOf.containsKey(p) && !team.contains(partnerOf[p])) {
              ok = false;
              break;
            }
          }
          if (!ok) break;
        }
        if (ok) return [t1, t2];
      }
      return null;
    }

    while (remain.values.any((v) => v > 0)) {
      final used = <String>{};
      final slot = <_MatchInternal>[];

      while (slot.length < courts) {
        final cand =
            names.where((n) => remain[n]! > 0 && !used.contains(n)).toList();
        if (cand.length < 4) break;

        cand.shuffle(rand);
        List<String>? bestT1, bestT2;
        int? bestScore;
        int? bestNeed;

        // 4명 조합 탐색
        for (var a = 0; a < cand.length - 3; a++) {
          for (var b = a + 1; b < cand.length - 2; b++) {
            for (var c = b + 1; c < cand.length - 1; c++) {
              for (var d = c + 1; d < cand.length; d++) {
                final g = [cand[a], cand[b], cand[c], cand[d]];
                final split = validSplit(g);
                if (split == null) continue;

                final t1 = split[0];
                final t2 = split[1];
                final score = overlapScore(t1, t2);
                final need = -(remain[t1[0]]! +
                    remain[t1[1]]! +
                    remain[t2[0]]! +
                    remain[t2[1]]!);
                if (bestScore == null ||
                    score < bestScore ||
                    (score == bestScore && need < bestNeed!)) {
                  bestScore = score;
                  bestNeed = need;
                  bestT1 = t1;
                  bestT2 = t2;
                  if (bestScore == 0) break;
                }
              }
              if (bestScore == 0) break;
            }
            if (bestScore == 0) break;
          }
          if (bestScore == 0) break;
        }

        if (bestT1 == null || bestT2 == null) break;

        bestT1.shuffle(rand);
        bestT2.shuffle(rand);
        if (rand.nextBool()) {
          final tmp = bestT1;
          bestT1 = bestT2;
          bestT2 = tmp;
        }

        final teamA = TeamModel(
          _find(players, bestT1[0]),
          _find(players, bestT1[1]),
        );
        final teamB = TeamModel(
          _find(players, bestT2[0]),
          _find(players, bestT2[1]),
        );
        final match = _MatchInternal(teamA, teamB);
        slot.add(match);

        // 상태 갱신
        for (final p in [...bestT1, ...bestT2]) {
          used.add(p);
          remain[p] = remain[p]! - 1;
        }
        for (final x in [...bestT1, ...bestT2]) {
          for (final y in [...bestT1, ...bestT2]) {
            if (x == y || isFixed(x, y)) continue;
            pairCnt.putIfAbsent(x, () => {})[y] =
                (pairCnt[x]?[y] ?? 0) + 1;
          }
        }
      }

      final needGames = min(courts, remain.values.reduce((a, b) => a + b) ~/ 4);
      if (slot.length < needGames) return null;

      slots.add(slot);
      schedule.addAll(slot);
    }

    // ── 중복 통계 계산 ────────────────────────────────────────
    final flatVals = [
      for (final m in pairCnt.values) ...m.values,
    ];
    final maxDup = flatVals.isEmpty ? 0 : flatVals.reduce(max);
    final avgDup =
        flatVals.isEmpty ? 0.0 : flatVals.reduce((a, b) => a + b) / flatVals.length;

    return _ScheduleResult(schedule, slots, maxDup, avgDup);
  }

  static PlayerModel _find(List<PlayerModel> list, String name) =>
      list.firstWhere((p) => p.name == name);

  static List<MatchModel> _toMatchModel(
    List<_MatchInternal> schedule,
    List<List<_MatchInternal>> slots,
    List<PlayerModel> players,
  ) {
    var idSeq = 1;
    final result = <MatchModel>[];
    for (var ord = 0; ord < slots.length; ord++) {
      for (final m in slots[ord]) {
        result.add(
          MatchModel(
            id: idSeq++,
            ord: ord + 1,
            playerA: m.teamA.p1.name,
            playerC: m.teamA.p2?.name,
            playerB: m.teamB.p1.name,
            playerD: m.teamB.p2?.name,
          ),
        );
      }
    }
    return result;
  }
}

// ──────────────────────────────────────────────────────────────
//  internal helper classes
// ──────────────────────────────────────────────────────────────
class _MatchInternal {
  final TeamModel teamA;
  final TeamModel teamB;
  const _MatchInternal(this.teamA, this.teamB);
}

class _ScheduleResult {
  final List<_MatchInternal> schedule;
  final List<List<_MatchInternal>> slots;
  final int maxDup;
  final double avgDup;
  const _ScheduleResult(this.schedule, this.slots, this.maxDup, this.avgDup);
}
