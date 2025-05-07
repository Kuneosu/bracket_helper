import 'package:bracket_helper/data/models/contributor.dart';
import 'package:bracket_helper/data/services/contributor_service.dart';

class ContributorRepository {
  final ContributorService _service;

  ContributorRepository(this._service);

  Future<List<Contributor>> getContributors() async {
    try {
      return await _service.getContributors();
    } catch (e) {
      throw Exception(e.toString());
    }
  }
} 