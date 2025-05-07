import 'package:flutter/material.dart';
import 'package:bracket_helper/ui/color_st.dart';
import 'package:bracket_helper/ui/text_st.dart';
import 'package:bracket_helper/core/constants/app_strings.dart';
import 'package:bracket_helper/presentation/setting/widgets/contributor_item.dart';
import 'package:bracket_helper/data/repository/contributor_repository.dart';
import 'package:bracket_helper/data/models/contributor.dart';
import 'package:bracket_helper/data/services/contributor_service.dart';
import 'package:bracket_helper/data/data_source/contributor_data_source.dart';

class ContributorsDialog extends StatefulWidget {
  const ContributorsDialog({super.key});

  @override
  State<ContributorsDialog> createState() => _ContributorsDialogState();
  
  // 다이얼로그를 표시하는 정적 메소드
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ContributorsDialog(),
    );
  }
}

class _ContributorsDialogState extends State<ContributorsDialog> {
  late final ContributorRepository _repository;
  bool _isLoading = true;
  String? _error;
  List<Contributor> _contributors = [];

  @override
  void initState() {
    super.initState();
    // 간단한 의존성 주입
    final primaryDataSource = GithubContributorDataSource();
    final fallbackDataSource = LocalContributorDataSource();
    final service = ContributorService(primaryDataSource, fallbackDataSource);
    _repository = ContributorRepository(service);
    
    _loadContributors();
  }

  Future<void> _loadContributors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final contributors = await _repository.getContributors();
      
      setState(() {
        _contributors = contributors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  Widget contentBox(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더 부분
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: CST.primary100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                AppStrings.thanksFor,
                style: TST.mediumTextBold.copyWith(color: CST.white),
              ),
            ),
          ),

          // 컨텐츠 부분 - 스크롤 가능하도록 수정
          Flexible(
            child: _buildContent(),
          ),

          // 버튼 부분
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: CST.gray4, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: CST.primary20,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      AppStrings.close,
                      style: TST.normalTextBold.copyWith(color: CST.primary100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              AppStrings.loadingContributors,
              style: TST.normalTextBold,
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.loadingError,
                style: TST.normalTextBold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TST.normalTextBold.copyWith(fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadContributors,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_contributors.isEmpty) {
      // 비어있는 경우 LocalContributorDataSource의 데이터를 불러옵니다
      try {
        final localDataSource = LocalContributorDataSource();
        localDataSource.getContributors().then((localContributors) {
          if (mounted) {
            setState(() {
              _contributors = localContributors;
            });
          }
        });
      } catch (e) {
        // 로컬 데이터 로드 실패 시 처리
      }
      
      // 로딩 표시
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
        child: Column(
          children: _contributors.map((contributor) {
            Color? color;
            
            if (contributor.color != "default") {
              try {
                color = Color(int.parse(contributor.color));
              } catch (e) {
                // 색상 변환 실패 시 기본값 사용
                color = null;
              }
            }
            
            return ContributorItem(
              name: contributor.name,
              role: contributor.role,
              color: color,
            );
          }).toList(),
        ),
      ),
    );
  }
}
