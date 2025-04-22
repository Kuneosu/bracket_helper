// bracket_scheduler.dart
import 'dart:math';
import 'package:bracket_helper/domain/model/match_model.dart';
import 'package:bracket_helper/domain/model/player_model.dart';
import 'package:bracket_helper/domain/model/team_model.dart';

/// 4인 1경기 × 1인당 4경기.
/// - 코트 수(courts) 만큼 '동시 진행'
/// - 같은 사람과의 만남은 인원수별 한도(4·3·2회, 필요 시 3회로 완화)
/// - 슬롯을 가득 채우지 못하면 다른 시드로 재시도
class BracketScheduler {
  /// [players]  : 참가 선수 (4~32)
  /// [courts]   : 동시에 뛸 코트 수 (1~⌊N/4⌋)
  /// [gamesPer] : 1인당 경기 수 (기본 4)
  /// [seed]     : 결과 재현용 시드 (null ⇒ 난수)
  /// [restart]  : 실패 시 시드 재시도 횟수
  static List<MatchModel> generate(
    List<PlayerModel> players, {
    required int courts,            // NEW
    int gamesPer = 4,
    int? seed,
    int restart = 3000,             // NEW
  }) {
    if (players.length < 4 || players.length > 32) {
      throw ArgumentError('인원수는 4~32 명만 지원합니다.');
    }
    final maxCourt = players.length ~/ 4;
    if (courts < 1 || courts > maxCourt) {
      throw ArgumentError('코트 수는 1~$maxCourt 사이여야 합니다.');
    }

    final outerRand = Random(seed);
    final baseLimit = _pairLimitByN(players.length);
    final retries   = restart + max(0, players.length - 8) * 200; // NEW

    // ① baseLimit 으로 재시도
    for (var i = 0; i < retries; i++) {
      final res = _buildOnce(
        players,
        courts,
        gamesPer,
        baseLimit,
        Random(outerRand.nextInt(1 << 30)),
      );
      if (res != null) return res;
    }

    // ② 8명↑ & baseLimit == 2 → 한도 3으로 완화
    if (baseLimit == 2) {
      for (var i = 0; i < retries; i++) {
        final res = _buildOnce(
          players,
          courts,
          gamesPer,
          3,
          Random(outerRand.nextInt(1 << 30)),
        );
        if (res != null) return res;
      }
    }

    throw StateError(
      '조건을 만족하는 대진표를 $retries 회 시도했지만 찾지 못했습니다.\n'
      '재시도 횟수를 늘리거나 중복 허용 한도를 높여 보세요.',
    );
  }

  // ───────────────────────────────────────── helper ─────────────────────────
  /// 인원수 → 기본 중복 한도
  static int _pairLimitByN(int n) => n == 4 ? 4 : n <= 7 ? 3 : 2;

  /// 시드 한 번으로 스케줄 생성, 실패 시 null
  static List<MatchModel>? _buildOnce(
    List<PlayerModel> players,
    int courts,
    int gamesPer,
    int pairLimit,
    Random rand,
  ) {
    final names   = players.map((e) => e.name).toList();
    final remain  = {for (var n in names) n: gamesPer};
    final pairCnt = <String, Map<String, int>>{};
    int pair(String a, String b) => pairCnt[a]?[b] ?? 0;

    final schedule = <_MatchInternal>[];
    final slots    = <List<_MatchInternal>>[];

    bool okGroup(List<String> g) {
      for (var a in g) {
        for (var b in g) {
          if (a == b) continue;
          if (pair(a, b) >= pairLimit) return false;
        }
      }
      return true;
    }

    int overlapScore(List<String> g) {
      var s = 0;
      for (var a in g) {
        for (var b in g) {
          if (a == b) continue;
          s += pair(a, b);
        }
      }
      return s;
    }

    // ── 슬롯‑우선 생성 ───────────────────────────────────────────────
    while (remain.values.any((v) => v > 0)) {
      final used   = <String>{};
      final slot   = <_MatchInternal>[];

      while (slot.length < courts) {
        final cands = names
            .where((n) => remain[n]! > 0 && !used.contains(n))
            .toList();
        if (cands.length < 4) break;

        cands.shuffle(rand);
        List<String>? best;
        var bestKey = (1 << 30);

        for (final g in _combinations(cands, 4)) {
          if (!okGroup(g)) continue;
          final key = overlapScore(g) * 1000 -
              g.fold<int>(0, (s, p) => s + remain[p]!); // 작은 overlap, 큰 remain
          if (key < bestKey) {
            best = g;
            bestKey = key;
            if (overlapScore(g) == 0) break;
          }
        }
        if (best == null) break;

        best.shuffle(rand);
        final teamA = TeamModel(
          _findPlayer(players, best[0]),
          _findPlayer(players, best[1]),
        );
        final teamB = TeamModel(
          _findPlayer(players, best[2]),
          _findPlayer(players, best[3]),
        );
        slot.add(_MatchInternal(teamA, teamB));

        for (var a in best) {
          for (var b in best) {
            if (a == b) continue;
            pairCnt.putIfAbsent(a, () => {})[b] = pair(a, b) + 1;
          }
          remain[a] = remain[a]! - 1;
          used.add(a);
        }
      }

      // 슬롯 충족 검사 (마지막 슬롯 제외)
      final gamesLeft = remain.values.reduce((a, b) => a + b) ~/ 4;
      final needGames = gamesLeft >= courts ? courts : gamesLeft;
      if (slot.length < needGames && gamesLeft > 0) return null;

      slots.add(slot);
      schedule.addAll(slot);
    }

    // ── MatchModel 변환 ──────────────────────────────────────────────
    var idSeq = 1;
    final result = <MatchModel>[];
    for (var orderIdx = 0; orderIdx < slots.length; orderIdx++) {
      for (final m in slots[orderIdx]) {
        result.add(
          MatchModel(
            id: idSeq++,
            order: orderIdx + 1,
            teamAName: m.aName,
            teamBName: m.bName,
          ),
        );
      }
    }
    return result;
  }

  // 빠른 PlayerModel 찾기
  static PlayerModel _findPlayer(List<PlayerModel> list, String name) =>
      list.firstWhere((p) => p.name == name);

  // combinations 생성기
  static Iterable<List<T>> _combinations<T>(List<T> items, int r) sync* {
    if (r > items.length) return;
    if (r == 0) {
      yield [];
      return;
    }
    for (var i = 0; i <= items.length - r; i++) {
      final head = items[i];
      for (final tail in _combinations(items.sublist(i + 1), r - 1)) {
        yield [head, ...tail];
      }
    }
  }
}

/// 내부 전용 매치
class _MatchInternal {
  final TeamModel teamA;
  final TeamModel teamB;
  const _MatchInternal(this.teamA, this.teamB);

  String get aName {
    if (teamA.p2 != null) {
      return '${teamA.p1.name},${teamA.p2!.name}';
    } else {
      return teamA.p1.name;
    }
  }
  
  String get bName {
    if (teamB.p2 != null) {
      return '${teamB.p1.name},${teamB.p2!.name}';
    } else {
      return teamB.p1.name;
    }
  }
}
