import 'dart:async';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/data/data_source/contributor_data_source.dart';
import 'package:bracket_helper/data/models/contributor.dart';

class ContributorService {
  final ContributorDataSource _primaryDataSource;
  final ContributorDataSource _fallbackDataSource;

  ContributorService(this._primaryDataSource, [ContributorDataSource? fallbackDataSource])
      : _fallbackDataSource = fallbackDataSource ?? LocalContributorDataSource();

  Future<List<Contributor>> getContributors() async {
    try {
      return await _primaryDataSource.getContributors();
    } catch (e) {
      try {
        // 온라인 소스에서 데이터를 가져오지 못한 경우 로컬 데이터 사용
        return await _fallbackDataSource.getContributors();
      } catch (_) {
        // 모든 소스에서 데이터를 가져오지 못한 경우
        throw Exception(AppStrings.noInternetConnection);
      }
    }
  }
} 