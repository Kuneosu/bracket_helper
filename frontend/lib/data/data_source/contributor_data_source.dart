import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bracket_helper/data/models/contributor.dart';

abstract class ContributorDataSource {
  Future<List<Contributor>> getContributors();
}

class GithubContributorDataSource implements ContributorDataSource {
  final String repositoryUrl = 'https://raw.githubusercontent.com/Kuneosu/bracket_helper/BH-44/app_config.json';

  @override
  Future<List<Contributor>> getContributors() async {
    try {
      final response = await http.get(Uri.parse(repositoryUrl));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> contributorsJson = data['contributors'] as List<dynamic>;
        
        return contributorsJson
            .map((json) => Contributor.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('데이터를 불러오는데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('인터넷 연결을 확인해주세요.');
    }
  }
}

class LocalContributorDataSource implements ContributorDataSource {
  @override
  Future<List<Contributor>> getContributors() async {
    // 앱 내에 하드코딩된 기본 데이터 반환
    return [
      Contributor(
        name: '최은윤',
        role: '무조건적인 지지',
        color: '0xFFe8e0ff',
      ),
      Contributor(
        name: '하은이아빠',
        role: '소중한 의견과 격려',
      ),
      Contributor(
        name: '최은미',
        role: '소중한 의견과 격려',
      ),
      Contributor(
        name: '송치혁',
        role: '소중한 의견과 격려',
      ),
      Contributor(
        name: '김봉준',
        role: '소중한 의견과 격려',
      ),
      Contributor(
        name: '조소희',
        role: '소중한 의견과 격려',
      ),
      Contributor(
        name: '김정수',
        role: '소중한 의견과 격려',
      ),
      Contributor(
        name: '전수옥',
        role: '언젠가 A조',
      ),
      Contributor(
        name: '김지연',
        role: '개발자 벗, iOS 출시 비용 지원',
        color: '0xFFB388FF',
      ),
      Contributor(
        name: '박유정',
        role: '마코여신',
        color: '0xFFFF80AB',
      ),
      Contributor(
        name: '마코클럽',
        role: '실제 사용 및 피드백 제공',
        color: '0xFF129575',
      ),
    ];
  }
} 