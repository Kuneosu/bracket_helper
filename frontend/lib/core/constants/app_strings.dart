class AppStrings {

  static const String appTitle = '대진 도우미';
  static const String currentVersion = '1.2518.8';

  // 홈 화면
  static const String help = '도움말';
  static const String recentMatches = '최근 경기';
  static const String viewAll = '모두 보기 >';
  static const String services = '서비스';
  
  // 빈 상태 메시지
  static const String noTournaments = '아직 진행한 경기가 없습니다';
  static const String createNewTournament = '새 대진표를 생성해보세요!';
  
  // 기능 카드
  static const String createBracket = '대진표 생성하기';
  static const String createBracketDesc = '복식/단식 매칭을 쉽게 관리하세요';
  
  static const String playerManagement = '선수 관리';
  static const String playerManagementDesc = '선수 정보를 등록하고 관리하세요';
  
  static const String groupManagement = '그룹 관리';
  static const String groupManagementDesc = '그룹을 만들고 선수를 추가하세요';
  
  static const String designatedPartnerMatching = '지정 파트너 매칭 대진표';
  static const String designatedPartnerMatchingDesc = '파트너를 직접 지정해서 대진표를 생성해보세요';
  
  static const String viewStatistics = '통계 보기';
  static const String viewStatisticsDesc = '경기 결과와 플레이어 성적을 분석하세요';
  
  static const String comingSoon = '업데이트 예정';
  static const String comingSoonMessage = '추후 업데이트 예정입니다';
  
  // 저작권
  static const String copyright = '© 2025 Kuneosu. All rights reserved.';
  
  // 도움말 대화상자
  static const String helpDialogTitle = '도움말';
  static const String helpDialogDescription = '대진 도우미는 배드민턴·탁구·테니스 등 생활 체육 동호회나 학교·사내 친선전을 쉽고 빠르게 운영할 수 있도록 돕는 모바일 앱입니다.';
  static const String helpDialogFeaturesTitle = '주요 기능:';
  static const String helpDialogFeature1 = '복식/단식 대진표 자동 생성';
  static const String helpDialogFeature2 = '승/무/패 점수 설정';
  static const String helpDialogFeature3 = '경기 진행 현황 관리';
  static const String helpDialogFeature4 = '대진표 공유';
  static const String confirm = '확인';
  
  // 토너먼트 삭제 대화상자
  static const String tournamentDeleteTitle = '토너먼트 삭제';
  static const String tournamentDeleteQuestion = '이 토너먼트를 정말 삭제하시겠습니까?';
  static const String tournamentDeleteWarning = '이 작업은 되돌릴 수 없습니다.';
  static const String cancel = '취소';
  static const String delete = '삭제';

  // 설정 화면
  static const String settings = '설정';
  
  // 설정 섹션
  static const String displaySection = '디스플레이';
  static const String appInfoSection = '앱 정보';
  static const String customerSupportSection = '고객 지원';
  static const String otherSection = '기타';
  
  // 디스플레이 설정
  static const String themeSettings = '테마 설정';
  static const String themeOptions = '라이트 / 다크 / 시스템';
  static const String languageSettings = '언어 설정';
  static const String languageOptions = '한국어 / English';
  
  // 앱 정보 설정
  static const String appVersion = '앱 버전';
  
  static const String checkForUpdates = '업데이트 확인';
  static const String checkForUpdatesSubtitle = '최신 버전으로 업데이트하세요';
  
  // 고객 지원 설정
  static const String inquiryAndFeedback = '문의 및 피드백';
  static const String inquirySubtitle = '문제가 있거나 건의사항이 있으신가요?';
  static const String rateUs = '평가하기';
  static const String rateUsSubtitle = '앱 스토어에서 평가해주세요';
  
  // 기타 설정
  static const String developerInfo = '개발자 정보';
  static const String thanksFor = 'Thanks for';
  static const String privacyPolicy = '개인정보 처리방침';
  static const String termsOfService = '서비스 이용약관';
  
  // 컨트리뷰터 대화상자
  static const String close = '닫기';
  
  // 그룹 관리 에러 메시지
  static const String invalidPlayerId = '유효하지 않은 선수 ID입니다.';
  static const String invalidGroupId = '유효하지 않은 그룹 ID입니다.';
  static const String removePlayerError = '그룹에서 선수를 제거하는 중 오류가 발생했습니다.';
  static const String playerNotFound = '선수를 찾을 수 없습니다';
  
  // 로그 메시지
  static const String removePlayerAttempt = '그룹에서 선수 제거 시도 - 선수 ID: {0}, 그룹 ID: {1}';
  static const String removePlayerSuccess = '그룹에서 선수 제거 성공 - 영향받은 행: {0}';
  static const String removePlayerFail = '그룹에서 선수 제거 실패 - {0}';
  static const String exceptionOccurred = '예외 발생 - {0}';
  
  // 개발자 정보 바텀시트
  static const String developerInfoTitle = '개발자 정보';
  static const String developerName = '김권수(Kuneosu)';
  static const String developerDescription = '대진 도우미 앱을 개발한 개발자입니다.\n문의나 피드백은 언제든지 환영합니다.';
  static const String cannotOpenWebsite = '웹사이트를 열 수 없습니다.';
  static const String errorOccurred = '오류가 발생했습니다: {0}';
  
  // 이메일 피드백 런처
  static const String developerEmail = 'brackethelper@gmail.com';
  static const String emailSubject = '[대진 도우미] 문의 및 피드백';
  static const String emailBody = '''
안녕하세요, 대진 도우미 개발자입니다.

아래에 문의하실 내용이나 피드백을 자유롭게 작성해 주세요.
-------------------------------------------------

앱 버전: {0}
기기 정보: 

-------------------------------------------------
''';

  static const String emailAppErrorTitle = '이메일 앱 실행 불가';
  static const String emailAppErrorContent = '죄송합니다. 현재 기본 메일앱 사용이 불가능하여 앱에서 바로 메일을 전송할 수 없습니다.';
  static const String emailAppErrorContact = '아래 이메일로 연락주시면 빠르게 답변드리도록 하겠습니다.';
  
  // 언어 설정
  static const String korean = '한국어';
  static const String english = '영어';
  
  // 개인정보 처리방침 대화상자
  static const String privacyPolicyTitle = '개인정보 처리방침';
  static const String privacyPolicyDescription1 = '이 앱은 인터넷 서버와 통신하지 않으며, 사용자의 어떤 개인정보도 수집하거나 저장하지 않습니다.';
  static const String privacyPolicyDescription2 = '단, 향후 광고 기능이 추가될 경우 광고 SDK를 통해 일부 정보가 수집될 수 있으며, 이에 대한 안내는 추후 별도로 제공됩니다.';
  static const String privacyPolicyDate = '2025.04.24';

  // 설정 아이템 베타 표시
  static const String beta = '준비중';

  // 서비스 이용약관 대화상자
  static const String termsOfServiceTitle = '서비스 이용약관';
  static const String termsArticle1Title = '제 1조 (목적)';
  static const String termsArticle1Content = '이 앱은 무료로 제공되며, 모든 콘텐츠는 "있는 그대로" 제공됩니다.';
  static const String termsArticle2Title = '제 2조 (이용제한)';
  static const String termsArticle2Content = '사용자는 자유롭게 앱을 사용할 수 있으나, 불법적인 목적이나 타인의 권리를 침해하는 목적으로 사용해서는 안 됩니다.';
  static const String termsArticle3Title = '제 3조 (면책조항)';
  static const String termsArticle3Content = '개발자는 이 앱의 사용으로 인해 발생하는 어떠한 직접적, 간접적, 부수적 손해에 대해서도 책임을 지지 않습니다.';
  static const String termsDate = '2025.04.24';

  // 테마 설정
  static const String themeLight = '라이트';
  static const String themeDark = '다크';
  static const String themeSystem = '시스템';
  
  // 그룹 생성 화면
  static const String enterGroupInfo = '그룹 정보를 입력해주세요';
  static const String groupName = '그룹명';
  static const String enterGroupName = '그룹명을 입력해주세요';
  static const String maxChars = '최대 20자까지 입력 가능합니다';
  static const String groupColor = '그룹 색상';
  static const String selectGroupColor = '그룹을 대표할 색상을 선택하세요';
  static const String cancelCreation = '생성 취소';
  static const String createGroup = '그룹 생성하기';
  
  // 그룹 상세 화면
  static const String playerList = '선수 목록';
  
  // 그룹 목록 화면
  static const String groupList = '그룹 목록';
  static const String searchHint = '그룹 또는 선수 이름으로 검색...';
  static const String noSearchResults = '검색 결과가 없습니다';
  static const String searchResultsHelp = '다른 검색어를 입력하거나 그룹을 생성해보세요';
  static const String saveChanges = '변경사항 저장';
  static const String manage = '관리';
  static const String createGroupButton = '그룹 생성';
  
  // 액션 버튼
  static const String cancelButton = '취소';
  static const String confirmButton = '확인';
  
  // 선수 정보 수정 대화상자
  static const String editPlayerTitle = '선수 정보 수정';
  static const String playerNameLabel = '선수 이름';
  static const String enterNameHint = '이름을 입력하세요';
  static const String nameValidationError = '선수 이름을 입력해주세요';
  static const String saveButton = '저장';
  
  // 빈 선수 목록 위젯
  static const String noPlayersMessage = '등록된 선수가 없습니다';
  static const String addPlayerButton = '선수 추가하기';
  
  // 그룹 헤더 위젯
  static const String playerCountLabel = '소속 선수: %d명';
  static const String addPlayer = '선수 추가';

  // 그룹 목록 아이템
  static const String groupDelete = '그룹 삭제';
  static const String deleteGroupConfirm = '그룹을 삭제하시겠습니까?';
  static const String deleteGroupWarning = '이 작업은 되돌릴 수 없으며 그룹 내 모든 연결 정보가 삭제됩니다.';
  static const String remove = '제거';
  static const String changeGroupColor = '그룹 색상 변경';
  static const String change = '변경';
  static const String searchedPlayers = '검색된 선수:';

  // 선수 삭제 확인 대화상자
  static const String playerDelete = '선수 삭제';
  static const String playerDeleteConfirm = ' 선수를 정말 삭제하시겠습니까?';
  static const String playerDeleteWarning = '삭제된 선수는 복구할 수 없습니다.';

  // 선수 목록 아이템
  static const String edit = '수정';

  // 선수 검색 필드
  static const String searchPlayerByName = '선수 이름으로 검색';
  static const String searchResults = '검색 결과 (%d명)';

  // 그룹 이름 변경 대화상자
  static const String changeGroupName = '그룹 이름 변경';
  static const String changeGroupNamePrefix = '그룹 이름을 ';
  static const String changeGroupNameSuffix = '으로 변경하시겠습니까?';

  // 경기 화면
  static const String loading = '로딩 중...';
  static const String loadingBracket = '대진표를 불러오고 있습니다...';
  static const String tournamentInfo = '토너먼트 정보';
  
  // 하단 액션 버튼
  static const String reshuffleBracket = '섞어서 다시 돌리기';
  static const String finishMatch = '경기 종료';

  // 대진표 이미지 생성기
  static const String participantsAndMatches = "참가자 %d명 · 경기 %d경기";
  static const String generatedBy = "대진표 생성: 대진 도우미";
  static const String generatingBracketImage = '대진표 이미지 생성 중...';
  
  // 대진표 공유 유틸리티
  static const String generatingBracketImageMessage = '대진표 이미지를 생성 중입니다...';
  static const String imageCancelled = '이미지 생성이 취소되었습니다.';
  static const String bracketShareTitle = '%s 대진표';
  static const String bracketShareError = '대진표 공유 중 오류가 발생했습니다: %s';

  // 인터넷 연결 오류
  static const String noInternetConnection = '인터넷 연결을 확인해주세요.';
  static const String loadingContributors = '기여자 정보를 불러오는 중...';
  static const String loadingError = '정보를 불러오는데 실패했습니다.';

  // 커스텀 탭 바
  static const String bracketTab = '대진표';
  static const String currentRankingTab = '현재 순위';

  // 헤더 섹션
  static const String participantsCount = '참가 인원: %d명';
  static const String matchesCount = '경기 수: %d경기';
  static const String editBracket = '대진 수정';
  static const String shareBracket = '대진 공유';

  // 랭킹 헤더
  static const String rank = '순위';
  static const String name = '이름';
  static const String win = '승';
  static const String draw = '무';
  static const String lose = '패';
  static const String points = '승점';
  static const String goalDifference = '득실';

  // 정렬 옵션 바
  static const String sortBy = '정렬:';
  
  // 토너먼트 정보 대화상자
  static const String titleLabel = '제목';
  static const String participantsCountLabel = '참가자 수';
  static const String participantsCountValue = '%d명';
  static const String matchesCountLabel = '경기 수';
  static const String matchesCountValue = '%d경기';

  // 메인 화면
  static const String exitApp = '앱 종료';
  static const String exitConfirm = '앱을 종료하시겠습니까?';
  static const String exit = '종료';
  static const String home = '홈';

  // 대회 생성 화면
  static const String createBracketTitle = '대진표 생성';
  static const String basicInfo = '기본 정보';
  static const String addPlayers = '선수 추가';
  static const String editBracketTitle = '대진표 수정';
  static const String exitTournamentCreation = '대회 생성 종료';
  static const String exitTournamentConfirm = '대회 생성을 종료하시겠습니까?';
  static const String unsavedChangesWarning = '지금까지 입력한 모든 정보는 저장되지 않습니다.';
  static const String exitTournament = '종료하기';
  
  // 대회 정보 입력 화면
  static const String tournamentInfoInput = '대회 정보 입력';
  static const String reset = '초기화';
  static const String reGenerate = '재생성';
  static const String tournamentName = '대회명';
  static const String enterTournamentName = '대회명을 입력해주세요';
  static const String tournamentNameAutoSetInfo = "대회명을 입력하지 않으면 '[날짜] 대회'로 자동 설정됩니다.";
  static const String tournamentDate = '대회 날짜';
  static const String scoreInput = '승점 입력';
  static const String gameSettings = '경기 설정';
  static const String gamesPerPlayer = '1인당 게임수';
  static const String gamesPerPlayerInfo = '현재는 1인당 4게임만 지원됩니다. 추후 업데이트 예정입니다.';
  static const String gameFormat = '경기 형식';
  static const String doubles = '복식';
  static const String singles = '단식';
  static const String gameFormatInfo = '현재는 복식 경기만 지원됩니다. 단식은 추후 업데이트 예정입니다.';
  
  // 입력 초기화 대화상자
  static const String resetInput = '입력 초기화';
  static const String resetConfirm = '모든 입력을 초기화하시겠습니까?';
  static const String resetWarning = '입력한 모든 정보가 지워집니다.';
  static const String resetButton = '초기화';

  // AddPlayerScreen strings
  static const String savedPlayers = "저장된 선수";
  static const String currentPlayerList = "현재 선수 목록";
  static const String minPlayersRequired = "최소 4명의 선수가 필요합니다.";
  static const String maxPlayersAllowed = "최대 32명까지 등록 가능합니다.";
  static const String playersRequired = "선수는 4~32명으로 구성해야 합니다";

  // EditMatchScreen strings
  static const String noMatches = '등록된 매치가 없습니다.';
  static const String autoGenerateMatch = '매치 자동 생성';
  static const String courtCount = '코트 수';
  static const String saveAndReturn = '저장 후 돌아가기';
  static const String saveAndComplete = '저장 후 완료';
  static const String matchSaveError = '매치 저장 중 오류가 발생했습니다.';
  static const String courtNumberLimitError = '코트 수는 인원 수의 1/4 이하로만 설정할 수 있습니다.';
  static const String noPlayer = '선수 없음';
  static const String versus = 'VS';


  // AddPlayerActionButton strings
  static const String addSelectedPlayers = '선택한 선수 추가하기 (%d명)';
  static const String addNoPlayers = '선택한 선수 추가하기 (0명)';

  // EmptyPlayerListWidget strings
  static const String noAddedPlayersMessage = '아직 추가된 선수가 없습니다';
  static const String addPlayerMessage = '위 입력창에 이름을 입력하거나\n저장된 선수 탭에서 선수를 추가하세요';

  // GroupDropdown strings
  static const String selectGroup = '그룹 선택';
  static const String allGroups = '그룹 전체';
  static const String noSavedGroups = '저장된 그룹이 없습니다';

  // GroupRefreshButton strings
  static const String refreshGroups = '그룹 목록 새로고침';

  // InlineEditablePlayerItem strings
  static const String playerNameInputHint = '선수 이름 입력';
  static const String save = '저장';
  static const String tapToEdit = '탭하여 이름 수정';
  static const String toggleEdit = '편집';
  
  // NoGroupsMessage strings
  static const String noGroupsMessage = '저장된 그룹이 없습니다.\n그룹을 먼저 생성하거나 새로고침하세요.';

  // PlayerInputField strings
  static const String playerNameInputLabel = '선수 이름';
  static const String addPlayerButtonText = '선수 추가';
  static const String playerNameInputInfo = '여러 선수는 공백으로 구분해서 입력할 수 있습니다. (예: 홍길동 김철수)';

  // PlayerSelectionList strings
  static const String selectGroupToAddPlayers = '위에서 그룹을 선택하세요';
  static const String noPlayersInGroup = '이 그룹에는 선수가 없습니다.';
  static const String alreadyAdded = '이미 추가됨';
  

  // NavigationButtonsWidget strings
  static const String previous = '이전';
  static const String next = '다음';

  // PartnerAddPlayerScreen strings
  static const String partnerMinPlayersRequired = "최소 8명의 선수가 필요합니다.";
  static const String partnerMaxPlayersAllowed = "최대 32명까지 등록 가능합니다.";
  static const String partnerPlayersRequired = "선수는 8~32명으로 구성해야 합니다";
  
  // 업데이트 다이얼로그
  static const String updateNotice = '업데이트 알림';
  static const String newVersionAvailable = '새로운 버전이 출시되었습니다';
  static const String updateMessage = '최신 버전으로 업데이트하여\n새로운 기능과 개선사항을 경험해보세요.';
  static const String updateNow = '업데이트';
  static const String updateLater = '나중에';

}
