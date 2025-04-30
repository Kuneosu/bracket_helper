import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter/foundation.dart';

import 'tables.dart';
import '../dao/tournament_dao.dart';
import '../dao/player_dao.dart';
import '../dao/group_dao.dart';
import '../dao/match_dao.dart';
import '../dao/team_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Tournaments,
    Groups,
    Players,
    PlayerGroups,
    Participants,
    Teams,
    Matches,
  ],
  daos: [TournamentDao, PlayerDao, GroupDao, MatchDao, TeamDao],
)
class AppDatabase extends _$AppDatabase {
  // 일반 생성자
  AppDatabase() : super(_openConnection());

  // 테스트용 생성자
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) {
      return m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // 버전 1에서 버전 2로 업데이트: Groups 테이블에 color 컬럼 추가
        await m.addColumn(groups, groups.color);
      }
      if (from < 3) {
        // 버전 2에서 버전 3으로 업데이트: Tournaments 테이블에 process 컬럼 추가
        await m.addColumn(tournaments, tournaments.process);
      }
      if (from < 4) {
        // 버전 3에서 버전 4로 업데이트: Matches 테이블 구조 업데이트
        debugPrint('Matches 테이블 마이그레이션 시작 (버전 3 -> 4)');

        // 안전한 마이그레이션을 위해 트랜잭션 사용
        await transaction(() async {
          // 기존 matches 테이블이 있으면 이름 변경
          try {
            await customStatement('ALTER TABLE matches RENAME TO matches_old');
            debugPrint('기존 matches 테이블 이름 변경 성공');
          } catch (e) {
            debugPrint('기존 matches 테이블 이름 변경 실패: $e');
            // 테이블이 없을 경우 계속 진행
          }

          // 새 matches 테이블 생성
          await m.createTable(matches);
          debugPrint('새 matches 테이블 생성 성공');

          // 가능하다면 기존 데이터 마이그레이션 (간단한 컬럼만)
          try {
            final oldTableExists =
                await customSelect(
                  "SELECT name FROM sqlite_master WHERE type='table' AND name='matches_old'",
                ).get();

            if (oldTableExists.isNotEmpty) {
              await customStatement('''
                INSERT INTO matches (id, tournament_id, "ord", score_a, score_b)
                SELECT id, tournament_id, "order", score_a, score_b
                FROM matches_old
              ''');
              debugPrint('기존 데이터 마이그레이션 성공');

              // 기존 테이블 삭제
              await customStatement('DROP TABLE matches_old');
              debugPrint('기존 matches_old 테이블 삭제 성공');
            }
          } catch (e) {
            // 마이그레이션 실패 처리 (로그만 남김)
            debugPrint('기존 데이터 마이그레이션 실패: $e');
          }
        });

        debugPrint('Matches 테이블 마이그레이션 완료');
      }
      if (from < 5) {
        // 버전 4에서 버전 5로 업데이트: order 필드 이름 변경 문제 해결
        debugPrint('Matches 테이블 order 필드 문제 해결 (버전 4 -> 5)');
        
        // 안전한 마이그레이션을 위해 트랜잭션 사용
        await transaction(() async {
          try {
            // 기존 테이블 백업
            await customStatement('ALTER TABLE matches RENAME TO matches_temp');
            debugPrint('기존 matches 테이블 이름 변경 성공 (matches_temp)');
            
            // 새 테이블 생성 (match_order 컬럼으로 변경됨)
            await m.createTable(matches);
            debugPrint('새 matches 테이블 생성 성공 (match_order 컬럼 포함)');
            
            // 데이터 마이그레이션 시도
            try {
              // "order"는 SQLite 예약어이므로 쌍따옴표로 묶어야 함
              await customStatement('''
                INSERT INTO matches (id, tournament_id, match_order, player_a, player_b, player_c, player_d, score_a, score_b)
                SELECT id, tournament_id, "order", player_a, player_b, player_c, player_d, score_a, score_b
                FROM matches_temp
              ''');
              debugPrint('matches_temp에서 새 테이블로 데이터 복사 성공');
            } catch (e) {
              debugPrint('데이터 복사 중 오류 발생: $e');
              // 기본 마이그레이션 실패 시 대체 전략: 새 테이블만 생성하고 데이터는 무시
            }
            
            // 임시 테이블 삭제
            await customStatement('DROP TABLE matches_temp');
            debugPrint('임시 테이블 matches_temp 삭제 성공');
            
          } catch (e) {
            debugPrint('order 필드 마이그레이션 오류: $e');
          }
        });
      }
      if (from < 6) {
        // 버전 5에서 버전 6으로 업데이트: match_order 필드 이름을 order로 다시 변경
        debugPrint('Matches 테이블 match_order 필드 이름을 order로 변경 (버전 5 -> 6)');
        
        try {
          // 기존 테이블 백업
          await customStatement('ALTER TABLE matches RENAME TO matches_old');
          debugPrint('기존 matches 테이블 이름 변경 성공 (matches_old)');
          
          // 새 테이블 생성 (order 컬럼 사용)
          await m.createTable(matches);
          debugPrint('새 matches 테이블 생성 성공 (order 컬럼 사용)');
          
          // 데이터 마이그레이션
          try {
            await customStatement('''
              INSERT INTO matches (id, tournament_id, "order", player_a, player_b, player_c, player_d, score_a, score_b)
              SELECT id, tournament_id, match_order, player_a, player_b, player_c, player_d, score_a, score_b
              FROM matches_old
            ''');
            debugPrint('matches_old에서 새 테이블로 데이터 복사 성공');
          } catch (e) {
            debugPrint('데이터 마이그레이션 중 오류: $e');
            
            // match_order 컬럼이 없는 경우 대체 마이그레이션
            try {
              await customStatement('''
                INSERT INTO matches (id, tournament_id, "order", player_a, player_b, player_c, player_d, score_a, score_b)
                SELECT id, tournament_id, id, player_a, player_b, player_c, player_d, score_a, score_b
                FROM matches_old
              ''');
              debugPrint('대체 마이그레이션 성공 (id를 order로 사용)');
            } catch (e) {
              debugPrint('대체 마이그레이션도 실패: $e');
            }
          }
          
          // 임시 테이블 삭제
          await customStatement('DROP TABLE matches_old');
          debugPrint('임시 테이블 matches_old 삭제 성공');
          
        } catch (e) {
          debugPrint('match_order -> order 마이그레이션 오류: $e');
        }
      }
      if (from < 7) {
        // 버전 6에서 버전 7로 업데이트: 'order' 컬럼을 'ord'로 변경
        debugPrint('Matches 테이블의 "order" 컬럼을 "ord"로 변경 (버전 6 -> 7)');
        
        try {
          // 기존 테이블 백업
          await customStatement('ALTER TABLE matches RENAME TO matches_old');
          debugPrint('기존 matches 테이블 이름 변경 성공 (matches_old)');
          
          // 새 테이블 생성 (ord 컬럼으로 변경)
          await m.createTable(matches);
          debugPrint('새 matches 테이블 생성 성공 (ord 컬럼 사용)');
          
          // 데이터 마이그레이션
          try {
            await customStatement('''
              INSERT INTO matches (id, tournament_id, ord, player_a, player_b, player_c, player_d, score_a, score_b)
              SELECT id, tournament_id, "order", player_a, player_b, player_c, player_d, score_a, score_b
              FROM matches_old
            ''');
            debugPrint('matches_old에서 새 테이블로 데이터 복사 성공 (order -> ord)');
          } catch (e) {
            debugPrint('order -> ord 마이그레이션 중 오류: $e');
            
            // order 컬럼이 없는 경우 대체 마이그레이션
            try {
              await customStatement('''
                INSERT INTO matches (id, tournament_id, ord, player_a, player_b, player_c, player_d, score_a, score_b)
                SELECT id, tournament_id, id, player_a, player_b, player_c, player_d, score_a, score_b
                FROM matches_old
              ''');
              debugPrint('대체 마이그레이션 성공 (id를 ord로 사용)');
            } catch (e) {
              debugPrint('대체 마이그레이션도 실패: $e');
            }
          }
          
          // 임시 테이블 삭제
          await customStatement('DROP TABLE matches_old');
          debugPrint('임시 테이블 matches_old 삭제 성공');
          
        } catch (e) {
          debugPrint('order -> ord 마이그레이션 오류: $e');
        }
      }
      if (from < 8) {
        // 버전 7에서 버전 8로 업데이트: Tournaments 테이블에 isPartnerMatching 및 partnerPairs 컬럼 추가
        debugPrint('Tournaments 테이블에 파트너 매칭 관련 컬럼 추가 (버전 7 -> 8)');
        
        try {
          // ALTER TABLE 문을 직접 사용합니다
          await customStatement(
            'ALTER TABLE tournaments ADD COLUMN is_partner_matching BOOLEAN NOT NULL DEFAULT 0',
          );
          await customStatement(
            "ALTER TABLE tournaments ADD COLUMN partner_pairs TEXT NOT NULL DEFAULT '[]'",
          );
          debugPrint('파트너 매칭 관련 컬럼 추가 완료');
        } catch (e) {
          debugPrint('파트너 매칭 관련 컬럼 추가 실패: $e');
        }
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');

      // 스키마 확인 및 로깅 (디버그 모드에서만)
      if (kDebugMode) {
        final tables =
            await customSelect(
              "SELECT name FROM sqlite_master WHERE type='table'",
            ).get();
        debugPrint(
          '현재 테이블 목록: ${tables.map((e) => e.data['name']).join(', ')}',
        );

        try {
          final columns =
              await customSelect("PRAGMA table_info(matches)").get();
          debugPrint(
            'matches 테이블 컬럼: ${columns.map((e) => e.data['name']).join(', ')}',
          );
        } catch (e) {
          debugPrint('matches 테이블 정보 조회 실패: $e');
        }
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // 안드로이드에서 SQLite 라이브러리 초기화
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

      // 임시 디렉토리 설정
      final tempDir = await getTemporaryDirectory();
      sqlite3.tempDirectory = tempDir.path;
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'bracket_helper.sqlite'));

    // 디버그 모드에서는 SQLite를 더 상세하게 설정
    if (kDebugMode) {
      return NativeDatabase.createInBackground(
        file,
        setup: (rawDb) {
          // 외래 키 제약 조건 활성화
          rawDb.execute('PRAGMA foreign_keys = ON');
        },
      );
    }

    return NativeDatabase.createInBackground(file);
  });
}
