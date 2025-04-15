
/// 애플리케이션의 모든 오류 클래스의 기본 클래스
abstract class AppError {
  final String message;
  final Object? cause;

  const AppError({
    required this.message,
    this.cause,
  });

  @override
  String toString() => '${runtimeType.toString()}: $message${cause != null ? ', Cause: $cause' : ''}';
}

/// 데이터베이스 관련 오류
class DatabaseError extends AppError {
  const DatabaseError({
    required super.message,
    super.cause,
  });
  
  // 특별한 에러 케이스를 위한 팩토리 메서드들
  factory DatabaseError.duplicate({String? detail, Object? cause}) {
    return DatabaseError(
      message: detail ?? '중복된 데이터가 존재합니다.',
      cause: cause,
    );
  }
  
  factory DatabaseError.notFound({String? detail, Object? cause}) {
    return DatabaseError(
      message: detail ?? '요청한 데이터를 찾을 수 없습니다.',
      cause: cause,
    );
  }
  
  factory DatabaseError.invalidOperation({String? detail, Object? cause}) {
    return DatabaseError(
      message: detail ?? '잘못된 데이터베이스 작업입니다.',
      cause: cause,
    );
  }
}

/// 그룹 관련 오류
class GroupError extends AppError {
  const GroupError({
    required super.message,
    super.cause,
  });
  
  factory GroupError.playerAlreadyExists({String? detail, Object? cause}) {
    return GroupError(
      message: detail ?? '이미 그룹에 존재하는 선수입니다.',
      cause: cause,
    );
  }
  
  factory GroupError.playerNotFound({String? detail, Object? cause}) {
    return GroupError(
      message: detail ?? '선수를 찾을 수 없습니다.',
      cause: cause,
    );
  }
}

/// 플레이어 관련 오류
class PlayerError extends AppError {
  const PlayerError({
    required super.message,
    super.cause,
  });
}

/// 팀 관련 오류
class TeamError extends AppError {
  const TeamError({
    required super.message,
    super.cause,
  });
}

/// 토너먼트 관련 오류
class TournamentError extends AppError {
  const TournamentError({
    required super.message,
    super.cause,
  });
} 