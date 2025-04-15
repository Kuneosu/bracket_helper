# Bracket helper 테스트 가이드

이 문서는 브라켓 헬퍼 어플리케이션의 테스트 구조와 방법에 대한 가이드를 제공합니다.

## 1. 테스트 구조

프로젝트의 테스트는 다음과 같은 구조로 구성되어 있습니다:

```
frontend/test/
├── data/                  # 데이터 레이어 테스트
│   ├── database/          # 데이터베이스 테스트
│   │   └── app_database_test.dart
│   └── repository/        # 리포지토리 구현체 테스트
│       ├── group_repository_impl_test.dart
│       ├── team_repository_impl_test.dart
│       ├── player_repository_impl_test.dart
│       └── match_repository_impl_test.dart
└── mock_dao/              # 모의(Mock) DAO 객체
    ├── test_mock_tournament_dao.dart
    ├── test_mock_player_dao.dart
    ├── test_mock_group_dao.dart
    ├── test_mock_match_dao.dart
    ├── test_mock_team_dao.dart
    └── test_mock_app_database.dart
```

## 2. 테스트 종류

### 2.1 데이터베이스 테스트

`app_database_test.dart`는 Drift 기반 데이터베이스의 기본 기능을 검증합니다:

1. **스키마 테스트**: 데이터베이스가 올바르게 초기화되고 스키마 버전이 맞는지 확인
2. **CRUD 테스트**: 각 테이블(토너먼트, 선수 등)에 대한 생성/조회/수정/삭제 작업 검증
3. **외래 키 제약 조건 테스트**: 테이블 간 관계가 올바르게 적용되는지 확인
4. **트랜잭션 테스트**: 여러 작업이 트랜잭션으로 올바르게 처리되는지 확인
5. **고유 제약 조건 테스트**: 중복 데이터 방지 기능이 올바르게 작동하는지 확인

### 2.2 리포지토리 테스트

리포지토리 구현체 테스트는 DAO를 모킹(mocking)하여 데이터 접근 로직을 검증합니다:

1. **성공 케이스**: 각 메서드가 성공적으로 실행될 때의 동작 검증
2. **실패 케이스**: 예외 발생 시 적절한 오류 처리가 이루어지는지 검증
3. **에러 래핑**: 데이터베이스 에러가 도메인 에러로 적절히 변환되는지 확인

## 3. 테스트 실행 방법

### 3.1 개별 테스트 실행

특정 테스트 파일만 실행하려면:

```bash
flutter test frontend/test/data/database/app_database_test.dart
```

### 3.2 전체 테스트 실행

모든 테스트를 실행하려면:

```bash
flutter test
```

## 4. 테스트 작성 가이드

### 4.1 데이터베이스 테스트 작성

데이터베이스 테스트는 메모리 내 데이터베이스를 사용하여 구현합니다:

```dart
// 테스트용 메모리 데이터베이스 생성
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory(
    setup: (rawDb) {
      rawDb.execute('PRAGMA foreign_keys = ON');
    },
  ));
}
```

주요 테스트 패턴:
1. 데이터 생성
2. 기대값과 실제값 비교
3. 정리 (tearDown 사용)

### 4.2 리포지토리 테스트 작성

리포지토리 테스트는 Mockito를 사용하여 DAO를 모킹합니다:

```dart
// Mockito 설정
mockPlayerDao = MockPlayerDao();
repository = PlayerRepositoryImpl(mockPlayerDao);

// 모의 동작 설정
when(mockPlayerDao.fetchAllPlayers()).thenAnswer((_) async => players);

// 결과 검증
expect(result.isSuccess, isTrue);
verify(mockPlayerDao.fetchAllPlayers()).called(1);
```

### 4.3 모의 객체 생성

새로운 DAO에 대한 모의 객체를 생성하려면:

1. `test_mock_xxx_dao.dart` 파일 생성
2. `@GenerateMocks` 어노테이션 사용
3. `flutter pub run build_runner build` 실행하여 모의 객체 생성

```dart
import 'package:mockito/annotations.dart';
import 'package:bracket_helper/data/dao/xxx_dao.dart';

@GenerateMocks([XxxDao])
void main() {}
```

## 5. 테스트 모범 사례

1. **테스트 독립성**: 각 테스트는 독립적으로 실행될 수 있어야 함
2. **셋업/테어다운**: `setUp`과 `tearDown`을 사용하여 테스트 환경 관리
3. **테스트 그룹화**: `group`을 사용하여 관련 테스트 묶기
4. **명확한 명명**: 테스트 이름은 무엇을 테스트하는지 명확하게 표현
5. **AAA 패턴**: Arrange(준비), Act(실행), Assert(검증) 패턴 따르기

## 6. 트러블슈팅

### 6.1 외래 키 제약 조건 관련 문제

메모리 데이터베이스에서 외래 키 제약 조건을 활성화하려면:

```dart
NativeDatabase.memory(
  setup: (rawDb) {
    rawDb.execute('PRAGMA foreign_keys = ON');
  },
)
```

### 6.2 모킹 관련 문제

Mockito 모의 객체가 생성되지 않을 경우:

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```
