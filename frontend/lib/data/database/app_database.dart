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
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
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
