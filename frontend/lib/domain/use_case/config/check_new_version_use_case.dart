import 'package:bracket_helper/domain/error/app_error.dart';
import 'package:bracket_helper/domain/error/result.dart';
import 'package:bracket_helper/data/repository/config_repository.dart';

class CheckNewVersionUseCase {
  final ConfigRepository _configRepository;

  CheckNewVersionUseCase(this._configRepository);

  Future<Result<bool>> execute() async {
    try {
      final hasNewVersion = await _configRepository.hasNewVersion();
      return Result.success(hasNewVersion);
    } catch (e) {
      return Result.failure(ConfigError.networkError(cause: e));
    }
  }
} 