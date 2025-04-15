import 'package:bracket_helper/domain/error/app_error.dart';

// void 대신 사용할 Unit 클래스
class Unit {
  const Unit._();
  static const Unit unit = Unit._();
}

/// 작업의 성공 또는 실패를 나타내는 Result 클래스
class Result<T> {
  final T? _value;
  final AppError? _error;

  const Result._({T? value, AppError? error})
      : _value = value,
        _error = error,
        assert(
          (value != null && error == null) || (value == null && error != null),
          '값이나 에러 둘 중 하나만 존재해야 합니다',
        );

  /// 성공 결과 생성
  factory Result.success(T value) => Result._(value: value);

  /// void 타입을 위한 성공 결과 생성
  static Result<Unit> get successVoid => Result<Unit>._(value: Unit.unit);

  /// 실패 결과 생성
  factory Result.failure(AppError error) => Result._(error: error);

  /// 결과가 성공인지 여부
  bool get isSuccess => _error == null;

  /// 결과가 실패인지 여부
  bool get isFailure => _error != null;

  /// 성공 결과의 값 가져오기
  T get value {
    if (isFailure) {
      throw StateError('실패한 Result에서 값을 가져올 수 없습니다. 먼저 isSuccess를 확인하세요.');
    }
    return _value as T;
  }

  /// 실패 결과의 에러 가져오기
  AppError get error {
    if (isSuccess) {
      throw StateError('성공한 Result에서 에러를 가져올 수 없습니다. 먼저 isFailure를 확인하세요.');
    }
    return _error!;
  }

  /// 성공 시 콜백 함수 실행
  void fold({
    required Function(T value) onSuccess,
    required Function(AppError error) onFailure,
  }) {
    if (isSuccess) {
      onSuccess(value);
    } else {
      onFailure(error);
    }
  }

  /// 성공 시 변환 함수 적용하여 새 Result 반환
  Result<R> map<R>(R Function(T value) transform) {
    return isSuccess
        ? Result.success(transform(value))
        : Result.failure(error);
  }
  
  /// 성공 결과를 비동기 작업으로 flat-map
  Future<Result<R>> asyncFlatMap<R>(Future<Result<R>> Function(T value) transform) async {
    if (isSuccess) {
      return await transform(value);
    } else {
      return Result.failure(error);
    }
  }
} 