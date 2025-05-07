import 'package:bracket_helper/data/models/app_config.dart';
import 'package:bracket_helper/data/services/config_service.dart';

class ConfigRepository {
  final ConfigService _service;

  ConfigRepository(this._service);

  Future<AppConfig> getAppConfig() async {
    try {
      return await _service.getAppConfig();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
  
  Future<bool> hasNewVersion() async {
    try {
      return await _service.hasNewVersion();
    } catch (e) {
      return false;
    }
  }
} 