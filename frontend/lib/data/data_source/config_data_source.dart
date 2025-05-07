import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bracket_helper/data/models/app_config.dart';

abstract class ConfigDataSource {
  Future<AppConfig> getAppConfig();
}

class GithubConfigDataSource implements ConfigDataSource {
  final String repositoryUrl = 'https://raw.githubusercontent.com/Kuneosu/bracket_helper/main/app_config.json';

  @override
  Future<AppConfig> getAppConfig() async {
    try {
      final response = await http.get(Uri.parse(repositoryUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return AppConfig.fromJson(data);
      } else {
        throw Exception('GitHub 서버에서 데이터를 불러오는데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('인터넷 연결을 확인해주세요.');
    }
  }
} 