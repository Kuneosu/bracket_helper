# 브라켓 헬퍼 애플리케이션 데이터 가이드

이 문서는 브라켓 헬퍼 애플리케이션의 데이터 구조와 사용 방법에 대한 가이드입니다. 각 도메인별 데이터 처리 방식과 유스케이스 사용법을 설명합니다.

## 목차

1. [도메인 구조](#도메인-구조)
2. [선수(Player) 관리](#선수-관리)
3. [그룹(Group) 관리](#그룹-관리)
4. [팀(Team) 관리](#팀-관리)
5. [토너먼트(Tournament) 관리](#토너먼트-관리)
6. [매치(Match) 관리](#매치-관리)
7. [데이터 흐름](#데이터-흐름)

## 도메인 구조

애플리케이션은 Clean Architecture 원칙에 따라 다음과 같은 계층 구조를 가집니다:

- **Domain Layer**: 비즈니스 로직과 엔티티를 포함
  - `domain/model`: 각 도메인의 모델 클래스
  - `domain/repository`: 리포지토리 인터페이스
  - `domain/use_case`: 유스케이스 구현체
  - `domain/error`: 에러 처리 관련 클래스

- **Data Layer**: 데이터 접근 및 저장 로직
  - `data/repository`: 리포지토리 구현체
  - `data/database`: 데이터베이스 관련 코드 및 DAO

- **Presentation Layer**: UI 및 사용자 상호작용
  - `presentation`: 화면 및 UI 컴포넌트

## 선수(Player) 관리

### 데이터 모델
```dart
class Player {
  final int id;
  final String name;
  
  Player({required this.id, required this.name});
}
```

### 주요 유스케이스

1. **모든 선수 조회**: `GetAllPlayersUseCase`
   - 반환 값: `Result<List<Player>>`
   - 사용 예:
   ```dart
   final getAllPlayersUseCase = getIt<GetAllPlayersUseCase>();
   final result = await getAllPlayersUseCase.execute();
   if (result.isSuccess) {
     final players = result.value;
     // 선수 목록 처리
   }
   ```

2. **선수 추가**: `AddPlayerUseCase`
   - 입력 값: 선수 이름 (String)
   - 반환 값: `Result<int>` (생성된 선수 ID)
   - 사용 예:
   ```dart
   final addPlayerUseCase = getIt<AddPlayerUseCase>();
   final result = await addPlayerUseCase.execute("홍길동");
   if (result.isSuccess) {
     final playerId = result.value;
     // 생성된 선수 ID 활용
   }
   ```

3. **선수 삭제**: `DeletePlayerUseCase`
   - 입력 값: 선수 ID (int)
   - 반환 값: `Result<Unit>` (성공/실패)
   - 사용 예:
   ```dart
   final deletePlayerUseCase = getIt<DeletePlayerUseCase>();
   final result = await deletePlayerUseCase.execute(playerId);
   if (result.isSuccess) {
     // 삭제 성공 처리
   }
   ```

## 그룹(Group) 관리

### 데이터 모델
```dart
class Group {
  final int id;
  final String name;
  
  Group({required this.id, required this.name});
}

class GroupWithPlayers {
  final Group group;
  final List<Player> players;
  
  GroupWithPlayers({required this.group, required this.players});
}
```

### 주요 유스케이스

1. **모든 그룹 조회**: `GetAllGroupsUseCase`
   - 반환 값: `Result<List<Group>>`
   - 사용 예:
   ```dart
   final getAllGroupsUseCase = getIt<GetAllGroupsUseCase>();
   final result = await getAllGroupsUseCase.execute();
   if (result.isSuccess) {
     final groups = result.value;
     // 그룹 목록 처리
   }
   ```

2. **그룹 추가**: `AddGroupUseCase`
   - 입력 값: 그룹 이름 (String)
   - 반환 값: `Result<int>` (생성된 그룹 ID)
   - 사용 예:
   ```dart
   final addGroupUseCase = getIt<AddGroupUseCase>();
   final result = await addGroupUseCase.execute("A조");
   if (result.isSuccess) {
     final groupId = result.value;
     // 생성된 그룹 ID 활용
   }
   ```

3. **특정 그룹 정보 조회**: `GetGroupUseCase`
   - 입력 값: 그룹 ID (int)
   - 반환 값: `Result<GroupWithPlayers>` (그룹 및 소속 선수 정보)
   - 사용 예:
   ```dart
   final getGroupUseCase = getIt<GetGroupUseCase>();
   final result = await getGroupUseCase.execute(groupId);
   if (result.isSuccess) {
     final groupWithPlayers = result.value;
     final group = groupWithPlayers.group;
     final players = groupWithPlayers.players;
     // 그룹 및 선수 정보 처리
   }
   ```

4. **그룹에 선수 추가**: `AddPlayerToGroupUseCase`
   - 입력 값: `AddPlayerToGroupParams` (그룹 ID, 선수 이름)
   - 반환 값: 성공 시 선수 ID, 실패 시 오류 메시지
   - 사용 예:
   ```dart
   final addPlayerToGroupUseCase = getIt<AddPlayerToGroupUseCase>();
   final result = await addPlayerToGroupUseCase.execute(
     AddPlayerToGroupParams(
       groupId: groupId,
       playerName: "김철수",
     ),
   );
   // 결과 처리
   ```

5. **그룹에서 선수 제거**: `RemovePlayerFromGroupUseCase`
   - 입력 값: 선수 ID (int), 그룹 ID (int)
   - 반환 값: `Result<int>` (영향받은 행 수)
   - 사용 예:
   ```dart
   final removePlayerFromGroupUseCase = getIt<RemovePlayerFromGroupUseCase>();
   final result = await removePlayerFromGroupUseCase.execute(playerId, groupId);
   if (result.isSuccess) {
     // 선수 제거 성공 처리
   }
   ```

6. **그룹 삭제**: `DeleteGroupUseCase`
   - 입력 값: 그룹 ID (int)
   - 반환 값: `Result<Unit>` (성공/실패)
   - 사용 예:
   ```dart
   final deleteGroupUseCase = getIt<DeleteGroupUseCase>();
   final result = await deleteGroupUseCase.execute(groupId);
   if (result.isSuccess) {
     // 삭제 성공 처리
   }
   ```

## 팀(Team) 관리

### 데이터 모델
```dart
class Team {
  final int id;
  final int? player1Id;
  final int? player2Id;
  
  Team({required this.id, this.player1Id, this.player2Id});
}

class TeamWithPlayers {
  final Team team;
  final List<Player> players;
  final String teamName; // 선수들의 이름으로 구성된 팀 이름
  
  TeamWithPlayers({required this.team, required this.players, required this.teamName});
}
```

### 주요 유스케이스

1. **모든 팀 조회**: `GetAllTeamsUseCase`
   - 반환 값: `Result<List<TeamWithPlayers>>`
   - 사용 예:
   ```dart
   final getAllTeamsUseCase = getIt<GetAllTeamsUseCase>();
   final result = await getAllTeamsUseCase.execute();
   if (result.isSuccess) {
     final teams = result.value as List<TeamWithPlayers>;
     // 팀 목록 처리
   }
   ```

2. **팀 생성**: `CreateTeamUseCase`
   - 입력 값: `CreateTeamParams` (player1Id, player2Id - 선택적)
   - 반환 값: `Result<int>` (생성된 팀 ID)
   - 사용 예:
   ```dart
   final createTeamUseCase = getIt<CreateTeamUseCase>();
   final result = await createTeamUseCase.execute(
     CreateTeamParams(
       player1Id: player1Id,
       player2Id: player2Id, // 단식인 경우 null 가능
     ),
   );
   if (result.isSuccess) {
     final teamId = result.value;
     // 생성된 팀 ID 활용
   }
   ```

3. **팀 삭제**: `DeleteTeamUseCase`
   - 입력 값: 팀 ID (int)
   - 반환 값: `Result<Unit>` (성공/실패)
   - 사용 예:
   ```dart
   final deleteTeamUseCase = getIt<DeleteTeamUseCase>();
   final result = await deleteTeamUseCase.execute(teamId);
   if (result.isSuccess) {
     // 삭제 성공 처리
   }
   ```

## 토너먼트(Tournament) 관리

### 데이터 모델
```dart
class Tournament {
  final int id;
  final String title;
  final DateTime date;
  final int winPoint;
  final int drawPoint;
  final int losePoint;
  final int gamesPerPlayer;
  final bool isDoubles;
  
  Tournament({
    required this.id,
    required this.title,
    required this.date,
    this.winPoint = 1,
    this.drawPoint = 0,
    this.losePoint = 0,
    this.gamesPerPlayer = 4,
    this.isDoubles = true,
  });
}
```

### 주요 유스케이스

1. **모든 토너먼트 조회**: `GetAllTournamentsUseCase`
   - 반환 값: `Result<List<Tournament>>`
   - 사용 예:
   ```dart
   final getAllTournamentsUseCase = getIt<GetAllTournamentsUseCase>();
   final result = await getAllTournamentsUseCase.execute();
   if (result.isSuccess) {
     final tournaments = result.value;
     // 토너먼트 목록 처리
   }
   ```

2. **토너먼트 생성**: `CreateTournamentUseCase`
   - 입력 값: `CreateTournamentParams` (title, date)
   - 반환 값: `Result<int>` (생성된 토너먼트 ID)
   - 사용 예:
   ```dart
   final createTournamentUseCase = getIt<CreateTournamentUseCase>();
   final result = await createTournamentUseCase.execute(
     CreateTournamentParams(
       title: "2023 여름 대회",
       date: DateTime.now(),
     ),
   );
   if (result.isSuccess) {
     final tournamentId = result.value;
     // 생성된 토너먼트 ID 활용
   }
   ```

3. **토너먼트 삭제**: `DeleteTournamentUseCase`
   - 입력 값: 토너먼트 ID (int)
   - 반환 값: `Result<Unit>` (성공/실패)
   - 사용 예:
   ```dart
   final deleteTournamentUseCase = getIt<DeleteTournamentUseCase>();
   final result = await deleteTournamentUseCase.execute(tournamentId);
   if (result.isSuccess) {
     // 삭제 성공 처리
   }
   ```

## 매치(Match) 관리

### 데이터 모델
```dart
class Match {
  final int id;
  final int tournamentId;
  final int? teamAId;
  final int? teamBId;
  final String? teamAName;
  final String? teamBName;
  final int? scoreA;
  final int? scoreB;
  final int? order;
  
  Match({
    required this.id,
    required this.tournamentId,
    this.teamAId,
    this.teamBId,
    this.teamAName,
    this.teamBName,
    this.scoreA,
    this.scoreB,
    this.order,
  });
}
```

### 주요 유스케이스

1. **토너먼트 내 매치 조회**: `GetMatchesInTournamentUseCase`
   - 입력 값: 토너먼트 ID (int)
   - 반환 값: `Result<List<Match>>`
   - 사용 예:
   ```dart
   final getMatchesInTournamentUseCase = getIt<GetMatchesInTournamentUseCase>();
   final result = await getMatchesInTournamentUseCase.execute(tournamentId);
   if (result.isSuccess) {
     final matches = result.value;
     // 매치 목록 처리
   }
   ```

2. **매치 생성**: `CreateMatchUseCase`
   - 입력 값: `CreateMatchParams` (tournamentId, teamAId, teamBId, ...)
   - 반환 값: `Result<Match>` (생성된 매치 정보)
   - 사용 예:
   ```dart
   final createMatchUseCase = getIt<CreateMatchUseCase>();
   final result = await createMatchUseCase.execute(
     CreateMatchParams(
       tournamentId: tournamentId,
       teamAId: teamAId,
       teamBId: teamBId,
       teamAName: teamAName,
       teamBName: teamBName,
     ),
   );
   if (result.isSuccess) {
     final match = result.value;
     // 생성된 매치 활용
   }
   ```

3. **매치 삭제**: `DeleteMatchUseCase`
   - 입력 값: 매치 ID (int)
   - 반환 값: `Result<Unit>` (성공/실패)
   - 사용 예:
   ```dart
   final deleteMatchUseCase = getIt<DeleteMatchUseCase>();
   final result = await deleteMatchUseCase.execute(matchId);
   if (result.isSuccess) {
     // 삭제 성공 처리
   }
   ```

## 데이터 흐름

애플리케이션의 데이터 흐름은 다음과 같습니다:

1. **UI 계층(Presentation Layer)**: 사용자 요청이 시작됩니다.
2. **유스케이스(Use Case)**: 비즈니스 로직을 처리합니다.
3. **리포지토리(Repository)**: 데이터 접근 계층으로 데이터 저장/조회를 담당합니다.
4. **데이터 소스(DAO)**: 실제 데이터베이스와 상호작용합니다.

### 에러 처리

모든 유스케이스는 `Result<T>` 타입으로 결과를 반환하며, 다음과 같이 처리합니다:

- **성공 시**: `Result.success(value)` 형태로 반환합니다.
- **실패 시**: `Result.failure(error)` 형태로 에러 객체를 포함하여 반환합니다.

```dart
// 성공 케이스 처리
if (result.isSuccess) {
  final value = result.value;
  // 성공 로직
} else {
  // 에러 케이스 처리
  final error = result.error;
  // 오류 메시지 표시
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error.message),
      backgroundColor: Colors.red,
    ),
  );
}
```

### 예시 작업 흐름

**선수를 그룹에 추가하는 과정**:

1. UI에서 선수 이름과 그룹 ID를 입력받습니다.
2. `AddPlayerToGroupUseCase`를 호출합니다.
3. 유스케이스는 먼저 `PlayerRepository`를 통해 선수를 생성합니다.
4. 생성된 선수 ID를 활용하여 `GroupRepository`의 `addPlayerToGroup` 메서드를 호출합니다.
5. 결과를 UI에 반환합니다.
6. UI는 결과에 따라 성공/실패 메시지를 표시합니다.

이러한 패턴으로 모든 데이터 작업이 처리됩니다.
