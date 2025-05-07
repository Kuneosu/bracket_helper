import 'dart:async';
import 'package:bracket_helper/data/data_source/config_data_source.dart';
import 'package:bracket_helper/data/models/app_config.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';

class ConfigService {
  final ConfigDataSource _dataSource;

  ConfigService(this._dataSource);

  Future<AppConfig> getAppConfig() async {
    try {
      return await _dataSource.getAppConfig();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> hasNewVersion() async {
    try {
      final remoteConfig = await getAppConfig();
      final currentVersion = AppStrings.currentVersion;
      
      // 버전 비교 (단순 문자열 비교)
      return remoteConfig.version != currentVersion;
    } catch (e) {
      // 인터넷 연결 문제 등으로 확인 불가능할 경우 false 반환
      return false;
    }
  }
} 