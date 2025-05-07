import 'package:bracket_helper/core/constants/app_strings_en.dart';
import 'package:bracket_helper/core/constants/app_strings_ko.dart';
import 'package:bracket_helper/core/services/language_manager.dart';

class AppStrings {
  static String get appTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.appTitle
          : AppStringsEn.appTitle;
  static String get currentVersion =>
      LanguageManager.isKorean()
          ? AppStringsKo.currentVersion
          : AppStringsEn.currentVersion;

  // 홈 화면
  static String get help =>
      LanguageManager.isKorean() ? AppStringsKo.help : AppStringsEn.help;
  static String get recentMatches =>
      LanguageManager.isKorean()
          ? AppStringsKo.recentMatches
          : AppStringsEn.recentMatches;
  static String get viewAll =>
      LanguageManager.isKorean() ? AppStringsKo.viewAll : AppStringsEn.viewAll;
  static String get services =>
      LanguageManager.isKorean()
          ? AppStringsKo.services
          : AppStringsEn.services;
  static String get tournamentListLoadError =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentListLoadError
          : AppStringsEn.tournamentListLoadError;

  // 빈 상태 메시지
  static String get noTournaments =>
      LanguageManager.isKorean()
          ? AppStringsKo.noTournaments
          : AppStringsEn.noTournaments;
  static String get createNewTournament =>
      LanguageManager.isKorean()
          ? AppStringsKo.createNewTournament
          : AppStringsEn.createNewTournament;

  // 기능 카드
  static String get createBracket =>
      LanguageManager.isKorean()
          ? AppStringsKo.createBracket
          : AppStringsEn.createBracket;
  static String get createBracketDesc =>
      LanguageManager.isKorean()
          ? AppStringsKo.createBracketDesc
          : AppStringsEn.createBracketDesc;

  static String get playerManagement =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerManagement
          : AppStringsEn.playerManagement;
  static String get playerManagementDesc =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerManagementDesc
          : AppStringsEn.playerManagementDesc;

  static String get groupManagement =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupManagement
          : AppStringsEn.groupManagement;
  // 바텀 네비게이션용 짧은 그룹 관리 텍스트
  static String get shortGroupManagement =>
      LanguageManager.isKorean() ? '그룹' : 'Groups';
  static String get groupManagementDesc =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupManagementDesc
          : AppStringsEn.groupManagementDesc;

  static String get designatedPartnerMatching =>
      LanguageManager.isKorean()
          ? AppStringsKo.designatedPartnerMatching
          : AppStringsEn.designatedPartnerMatching;
  static String get designatedPartnerMatchingDesc =>
      LanguageManager.isKorean()
          ? AppStringsKo.designatedPartnerMatchingDesc
          : AppStringsEn.designatedPartnerMatchingDesc;

  static String get viewStatistics =>
      LanguageManager.isKorean()
          ? AppStringsKo.viewStatistics
          : AppStringsEn.viewStatistics;
  static String get viewStatisticsDesc =>
      LanguageManager.isKorean()
          ? AppStringsKo.viewStatisticsDesc
          : AppStringsEn.viewStatisticsDesc;

  static String get comingSoon =>
      LanguageManager.isKorean()
          ? AppStringsKo.comingSoon
          : AppStringsEn.comingSoon;
  static String get comingSoonMessage =>
      LanguageManager.isKorean()
          ? AppStringsKo.comingSoonMessage
          : AppStringsEn.comingSoonMessage;

  // 저작권
  static String get copyright =>
      LanguageManager.isKorean()
          ? AppStringsKo.copyright
          : AppStringsEn.copyright;

  // 도움말 대화상자
  static String get helpDialogTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.helpDialogTitle
          : AppStringsEn.helpDialogTitle;
  static String get helpDialogDescription =>
      LanguageManager.isKorean()
          ? AppStringsKo.helpDialogDescription
          : AppStringsEn.helpDialogDescription;
  static String get helpDialogFeaturesTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.helpDialogFeaturesTitle
          : AppStringsEn.helpDialogFeaturesTitle;
  static String get helpDialogFeature1 =>
      LanguageManager.isKorean()
          ? AppStringsKo.helpDialogFeature1
          : AppStringsEn.helpDialogFeature1;
  static String get helpDialogFeature2 =>
      LanguageManager.isKorean()
          ? AppStringsKo.helpDialogFeature2
          : AppStringsEn.helpDialogFeature2;
  static String get helpDialogFeature3 =>
      LanguageManager.isKorean()
          ? AppStringsKo.helpDialogFeature3
          : AppStringsEn.helpDialogFeature3;
  static String get helpDialogFeature4 =>
      LanguageManager.isKorean()
          ? AppStringsKo.helpDialogFeature4
          : AppStringsEn.helpDialogFeature4;
  static String get confirm =>
      LanguageManager.isKorean() ? AppStringsKo.confirm : AppStringsEn.confirm;

  // 토너먼트 삭제 대화상자
  static String get tournamentDeleteTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentDeleteTitle
          : AppStringsEn.tournamentDeleteTitle;
  static String get tournamentDeleteQuestion =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentDeleteQuestion
          : AppStringsEn.tournamentDeleteQuestion;
  static String get tournamentDeleteWarning =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentDeleteWarning
          : AppStringsEn.tournamentDeleteWarning;
  static String get cancel =>
      LanguageManager.isKorean() ? AppStringsKo.cancel : AppStringsEn.cancel;
  static String get delete =>
      LanguageManager.isKorean() ? AppStringsKo.delete : AppStringsEn.delete;
  static String get tournamentDeleteError =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentDeleteError
          : AppStringsEn.tournamentDeleteError;

  // 설정 화면
  static String get settings =>
      LanguageManager.isKorean()
          ? AppStringsKo.settings
          : AppStringsEn.settings;

  // 설정 섹션
  static String get displaySection =>
      LanguageManager.isKorean()
          ? AppStringsKo.displaySection
          : AppStringsEn.displaySection;
  static String get appInfoSection =>
      LanguageManager.isKorean()
          ? AppStringsKo.appInfoSection
          : AppStringsEn.appInfoSection;
  static String get customerSupportSection =>
      LanguageManager.isKorean()
          ? AppStringsKo.customerSupportSection
          : AppStringsEn.customerSupportSection;
  static String get otherSection =>
      LanguageManager.isKorean()
          ? AppStringsKo.otherSection
          : AppStringsEn.otherSection;


  // 디스플레이 설정
  static String get themeSettings =>
      LanguageManager.isKorean()
          ? AppStringsKo.themeSettings
          : AppStringsEn.themeSettings;
  static String get themeOptions =>
      LanguageManager.isKorean()
          ? AppStringsKo.themeOptions
          : AppStringsEn.themeOptions;
  static String get languageSettings =>
      LanguageManager.isKorean()
          ? AppStringsKo.languageSettings
          : AppStringsEn.languageSettings;
  static String get languageOptions =>
      LanguageManager.isKorean()
          ? AppStringsKo.languageOptions
          : AppStringsEn.languageOptions;

  // 앱 정보 설정
  static String get appVersion =>
      LanguageManager.isKorean()
          ? AppStringsKo.appVersion
          : AppStringsEn.appVersion;

  static String get checkForUpdates =>
      LanguageManager.isKorean()
          ? AppStringsKo.checkForUpdates
          : AppStringsEn.checkForUpdates;
  static String get checkForUpdatesSubtitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.checkForUpdatesSubtitle
          : AppStringsEn.checkForUpdatesSubtitle;

  // 고객 지원 설정
  static String get inquiryAndFeedback =>
      LanguageManager.isKorean()
          ? AppStringsKo.inquiryAndFeedback
          : AppStringsEn.inquiryAndFeedback;
  static String get inquirySubtitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.inquirySubtitle
          : AppStringsEn.inquirySubtitle;
  static String get rateUs =>
      LanguageManager.isKorean() ? AppStringsKo.rateUs : AppStringsEn.rateUs;
  static String get rateUsSubtitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.rateUsSubtitle
          : AppStringsEn.rateUsSubtitle;
  static String get storeOpenError =>
      LanguageManager.isKorean()
          ? AppStringsKo.storeOpenError
          : AppStringsEn.storeOpenError;
  // 기타 설정
  static String get developerInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.developerInfo
          : AppStringsEn.developerInfo;
  static String get thanksFor =>
      LanguageManager.isKorean()
          ? AppStringsKo.thanksFor
          : AppStringsEn.thanksFor;
  static String get privacyPolicy =>
      LanguageManager.isKorean()
          ? AppStringsKo.privacyPolicy
          : AppStringsEn.privacyPolicy;
  static String get termsOfService =>
      LanguageManager.isKorean()
          ? AppStringsKo.termsOfService
          : AppStringsEn.termsOfService;

  // 컨트리뷰터 대화상자
  static String get close =>
      LanguageManager.isKorean() ? AppStringsKo.close : AppStringsEn.close;

  // 그룹 관리 에러 메시지
  static String get invalidPlayerId =>
      LanguageManager.isKorean()
          ? AppStringsKo.invalidPlayerId
          : AppStringsEn.invalidPlayerId;
  static String get invalidGroupId =>
      LanguageManager.isKorean()
          ? AppStringsKo.invalidGroupId
          : AppStringsEn.invalidGroupId;
  static String get removePlayerError =>
      LanguageManager.isKorean()
          ? AppStringsKo.removePlayerError
          : AppStringsEn.removePlayerError;
  static String get playerNotFound =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerNotFound
          : AppStringsEn.playerNotFound;

  // 로그 메시지
  static String get removePlayerAttempt =>
      LanguageManager.isKorean()
          ? AppStringsKo.removePlayerAttempt
          : AppStringsEn.removePlayerAttempt;
  static String get removePlayerSuccess =>
      LanguageManager.isKorean()
          ? AppStringsKo.removePlayerSuccess
          : AppStringsEn.removePlayerSuccess;
  static String get removePlayerFail =>
      LanguageManager.isKorean()
          ? AppStringsKo.removePlayerFail
          : AppStringsEn.removePlayerFail;
  static String get exceptionOccurred =>
      LanguageManager.isKorean()
          ? AppStringsKo.exceptionOccurred
          : AppStringsEn.exceptionOccurred;

  // 개발자 정보 바텀시트
  static String get developerInfoTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.developerInfoTitle
          : AppStringsEn.developerInfoTitle;
  static String get developerName =>
      LanguageManager.isKorean()
          ? AppStringsKo.developerName
          : AppStringsEn.developerName;
  static String get developerDescription =>
      LanguageManager.isKorean()
          ? AppStringsKo.developerDescription
          : AppStringsEn.developerDescription;
  static String get cannotOpenWebsite =>
      LanguageManager.isKorean()
          ? AppStringsKo.cannotOpenWebsite
          : AppStringsEn.cannotOpenWebsite;
  static String get errorOccurred =>
      LanguageManager.isKorean()
          ? AppStringsKo.errorOccurred
          : AppStringsEn.errorOccurred;

  // 이메일 피드백 런처
  static String get developerEmail =>
      LanguageManager.isKorean()
          ? AppStringsKo.developerEmail
          : AppStringsEn.developerEmail;
  static String get emailSubject =>
      LanguageManager.isKorean()
          ? AppStringsKo.emailSubject
          : AppStringsEn.emailSubject;
  static String get emailBody =>
      LanguageManager.isKorean()
          ? AppStringsKo.emailBody
          : AppStringsEn.emailBody;
  static String get emailAppErrorTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.emailAppErrorTitle
          : AppStringsEn.emailAppErrorTitle;
  static String get emailAppErrorContent =>
      LanguageManager.isKorean()
          ? AppStringsKo.emailAppErrorContent
          : AppStringsEn.emailAppErrorContent;
  static String get emailAppErrorContact =>
      LanguageManager.isKorean()
          ? AppStringsKo.emailAppErrorContact
          : AppStringsEn.emailAppErrorContact;

  // 언어 설정
  static String get korean =>
      LanguageManager.isKorean() ? AppStringsKo.korean : AppStringsEn.korean;
  static String get english =>
      LanguageManager.isKorean() ? AppStringsKo.english : AppStringsEn.english;

  // 개인정보 처리방침 대화상자
  static String get privacyPolicyTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.privacyPolicyTitle
          : AppStringsEn.privacyPolicyTitle;
  static String get privacyPolicyDescription1 =>
      LanguageManager.isKorean()
          ? AppStringsKo.privacyPolicyDescription1
          : AppStringsEn.privacyPolicyDescription1;
  static String get privacyPolicyDescription2 =>
      LanguageManager.isKorean()
          ? AppStringsKo.privacyPolicyDescription2
          : AppStringsEn.privacyPolicyDescription2;
  static String get privacyPolicyDate =>
      LanguageManager.isKorean()
          ? AppStringsKo.privacyPolicyDate
          : AppStringsEn.privacyPolicyDate;

  // 설정 아이템 베타 표시
  static String get beta =>
      LanguageManager.isKorean() ? AppStringsKo.beta : AppStringsEn.beta;

  // 서비스 이용약관 대화상자
  static String get termsOfServiceTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.termsOfServiceTitle
          : AppStringsEn.termsOfServiceTitle;
  static String get termsArticle1Title =>
      LanguageManager.isKorean()
          ? AppStringsKo.termsArticle1Title
          : AppStringsEn.termsArticle1Title;
  static String get termsArticle1Content =>
      LanguageManager.isKorean()
          ? AppStringsKo.termsArticle1Content
          : AppStringsEn.termsArticle1Content;
  static String get termsArticle2Title =>
      LanguageManager.isKorean()
          ? AppStringsKo.termsArticle2Title
          : AppStringsEn.termsArticle2Title;
  static String get termsArticle2Content =>
      LanguageManager.isKorean()
          ? AppStringsKo.termsArticle2Content
          : AppStringsEn.termsArticle2Content;
  static String get termsArticle3Title =>
      LanguageManager.isKorean()
          ? AppStringsKo.termsArticle3Title
          : AppStringsEn.termsArticle3Title;
  static String get termsArticle3Content =>
      LanguageManager.isKorean()
          ? AppStringsKo.termsArticle3Content
          : AppStringsEn.termsArticle3Content;
  static String get termsDate =>
      LanguageManager.isKorean()
          ? AppStringsKo.termsDate
          : AppStringsEn.termsDate;

  // 테마 설정
  static String get themeLight =>
      LanguageManager.isKorean()
          ? AppStringsKo.themeLight
          : AppStringsEn.themeLight;
  static String get themeDark =>
      LanguageManager.isKorean()
          ? AppStringsKo.themeDark
          : AppStringsEn.themeDark;
  static String get themeSystem =>
      LanguageManager.isKorean()
          ? AppStringsKo.themeSystem
          : AppStringsEn.themeSystem;

  // 그룹 생성 화면
  static String get groupDetailTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupDetailTitle
          : AppStringsEn.groupDetailTitle;
  static String get createGroupTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.createGroupTitle
          : AppStringsEn.createGroupTitle;
  static String get groupListTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupListTitle
          : AppStringsEn.groupListTitle;
  static String get enterGroupInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.enterGroupInfo
          : AppStringsEn.enterGroupInfo;
  static String get groupName =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupName
          : AppStringsEn.groupName;
  static String get enterGroupName =>
      LanguageManager.isKorean()
          ? AppStringsKo.enterGroupName
          : AppStringsEn.enterGroupName;
  static String get maxChars =>
      LanguageManager.isKorean()
          ? AppStringsKo.maxChars
          : AppStringsEn.maxChars;
  static String get groupColor =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupColor
          : AppStringsEn.groupColor;
  static String get selectGroupColor =>
      LanguageManager.isKorean()
          ? AppStringsKo.selectGroupColor
          : AppStringsEn.selectGroupColor;
  static String get cancelCreation =>
      LanguageManager.isKorean()
          ? AppStringsKo.cancelCreation
          : AppStringsEn.cancelCreation;
  static String get createGroup =>
      LanguageManager.isKorean()
          ? AppStringsKo.createGroup
          : AppStringsEn.createGroup;

  // 그룹 상세 화면
  static String get playerList =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerList
          : AppStringsEn.playerList;
  static String addPlayerToGroup(String groupName) {
    String format =
        LanguageManager.isKorean()
            ? AppStringsKo.addPlayerToGroup
            : AppStringsEn.addPlayerToGroup;
    return format.replaceAll('%s', groupName);
  }

  static String get addPlayerLabel =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayerLabel
          : AppStringsEn.addPlayerLabel;
  static String get addPlayerHint =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayerHint
          : AppStringsEn.addPlayerHint;
  static String get addPlayerError =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayerError
          : AppStringsEn.addPlayerError;
  static String get addPlayerFeatureTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayerFeatureTitle
          : AppStringsEn.addPlayerFeatureTitle;
  static String get addPlayerFeatureGuide =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayerFeatureGuide
          : AppStringsEn.addPlayerFeatureGuide;
  static String get add =>
      LanguageManager.isKorean() ? AppStringsKo.add : AppStringsEn.add;
  static String get error =>
      LanguageManager.isKorean() ? AppStringsKo.error : AppStringsEn.error;
  static String get tryAgain =>
      LanguageManager.isKorean()
          ? AppStringsKo.tryAgain
          : AppStringsEn.tryAgain;
  static String get groupNotFound =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupNotFound
          : AppStringsEn.groupNotFound;
  static String get groupNotFoundMessage =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupNotFoundMessage
          : AppStringsEn.groupNotFoundMessage;
  static String get goToGroupList =>
      LanguageManager.isKorean()
          ? AppStringsKo.goToGroupList
          : AppStringsEn.goToGroupList;

  // 그룹 목록 화면
  static String get groupList =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupList
          : AppStringsEn.groupList;
  static String get searchHint =>
      LanguageManager.isKorean()
          ? AppStringsKo.searchHint
          : AppStringsEn.searchHint;
  static String get noSearchResults =>
      LanguageManager.isKorean()
          ? AppStringsKo.noSearchResults
          : AppStringsEn.noSearchResults;
  static String get searchResultsHelp =>
      LanguageManager.isKorean()
          ? AppStringsKo.searchResultsHelp
          : AppStringsEn.searchResultsHelp;
  static String get saveChanges =>
      LanguageManager.isKorean()
          ? AppStringsKo.saveChanges
          : AppStringsEn.saveChanges;
  static String get manage =>
      LanguageManager.isKorean() ? AppStringsKo.manage : AppStringsEn.manage;
  static String get createGroupButton =>
      LanguageManager.isKorean()
          ? AppStringsKo.createGroupButton
          : AppStringsEn.createGroupButton;

  // 액션 버튼
  static String get cancelButton =>
      LanguageManager.isKorean()
          ? AppStringsKo.cancelButton
          : AppStringsEn.cancelButton;
  static String get confirmButton =>
      LanguageManager.isKorean()
          ? AppStringsKo.confirmButton
          : AppStringsEn.confirmButton;

  // 선수 정보 수정 대화상자
  static String get editPlayerTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.editPlayerTitle
          : AppStringsEn.editPlayerTitle;
  static String get playerNameLabel =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerNameLabel
          : AppStringsEn.playerNameLabel;
  static String get enterNameHint =>
      LanguageManager.isKorean()
          ? AppStringsKo.enterNameHint
          : AppStringsEn.enterNameHint;
  static String get nameValidationError =>
      LanguageManager.isKorean()
          ? AppStringsKo.nameValidationError
          : AppStringsEn.nameValidationError;
  static String get saveButton =>
      LanguageManager.isKorean()
          ? AppStringsKo.saveButton
          : AppStringsEn.saveButton;

  // 빈 선수 목록 위젯
  static String get noPlayersMessage =>
      LanguageManager.isKorean()
          ? AppStringsKo.noPlayersMessage
          : AppStringsEn.noPlayersMessage;
  static String get addPlayerButton =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayerButton
          : AppStringsEn.addPlayerButton;

  // 그룹 헤더 위젯
  static String playerCountLabel(int count) {
    String format =
        LanguageManager.isKorean()
            ? AppStringsKo.playerCountLabel
            : AppStringsEn.playerCountLabel;
    return format.replaceAll('%d', count.toString());
  }

  static String get addPlayer =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayer
          : AppStringsEn.addPlayer;

  // 그룹 목록 아이템
  static String get groupDelete =>
      LanguageManager.isKorean()
          ? AppStringsKo.groupDelete
          : AppStringsEn.groupDelete;
  static String get deleteGroupConfirm =>
      LanguageManager.isKorean()
          ? AppStringsKo.deleteGroupConfirm
          : AppStringsEn.deleteGroupConfirm;
  static String get deleteGroupWarning =>
      LanguageManager.isKorean()
          ? AppStringsKo.deleteGroupWarning
          : AppStringsEn.deleteGroupWarning;
  static String get remove =>
      LanguageManager.isKorean() ? AppStringsKo.remove : AppStringsEn.remove;
  static String get changeGroupColor =>
      LanguageManager.isKorean()
          ? AppStringsKo.changeGroupColor
          : AppStringsEn.changeGroupColor;
  static String get change =>
      LanguageManager.isKorean() ? AppStringsKo.change : AppStringsEn.change;
  static String get searchedPlayers =>
      LanguageManager.isKorean()
          ? AppStringsKo.searchedPlayers
          : AppStringsEn.searchedPlayers;

  // 선수 삭제 확인 대화상자
  static String get playerDelete =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerDelete
          : AppStringsEn.playerDelete;
  static String get playerDeleteConfirm =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerDeleteConfirm
          : AppStringsEn.playerDeleteConfirm;
  static String get playerDeleteWarning =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerDeleteWarning
          : AppStringsEn.playerDeleteWarning;

  // 선수 목록 아이템
  static String get edit =>
      LanguageManager.isKorean() ? AppStringsKo.edit : AppStringsEn.edit;

  // 선수 검색 필드
  static String get searchPlayerByName =>
      LanguageManager.isKorean()
          ? AppStringsKo.searchPlayerByName
          : AppStringsEn.searchPlayerByName;
  static String searchResults(int count) {
    String format =
        LanguageManager.isKorean()
            ? AppStringsKo.searchResults
            : AppStringsEn.searchResults;
    return format.replaceAll('%d', count.toString());
  }

  // 그룹 이름 변경 대화상자
  static String get changeGroupName =>
      LanguageManager.isKorean()
          ? AppStringsKo.changeGroupName
          : AppStringsEn.changeGroupName;
  static String get changeGroupNamePrefix =>
      LanguageManager.isKorean()
          ? AppStringsKo.changeGroupNamePrefix
          : AppStringsEn.changeGroupNamePrefix;
  static String get changeGroupNameSuffix =>
      LanguageManager.isKorean()
          ? AppStringsKo.changeGroupNameSuffix
          : AppStringsEn.changeGroupNameSuffix;

  // 경기 화면
  static String get loading =>
      LanguageManager.isKorean() ? AppStringsKo.loading : AppStringsEn.loading;
  static String get loadingBracket =>
      LanguageManager.isKorean()
          ? AppStringsKo.loadingBracket
          : AppStringsEn.loadingBracket;
  static String get tournamentInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentInfo
          : AppStringsEn.tournamentInfo;
  static String get matchScoreInputInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.matchScoreInputInfo
          : AppStringsEn.matchScoreInputInfo;
  static String get shareBracketGuide =>
      LanguageManager.isKorean()
          ? AppStringsKo.shareBracketGuide
          : AppStringsEn.shareBracketGuide;
  static String get shareBracketInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.shareBracketInfo
          : AppStringsEn.shareBracketInfo;
  static String get shareBracketSkip =>
      LanguageManager.isKorean()
          ? AppStringsKo.shareBracketSkip
          : AppStringsEn.shareBracketSkip;
  static String get share =>
      LanguageManager.isKorean() ? AppStringsKo.share : AppStringsEn.share;

  // 하단 액션 버튼
  static String get reshuffleBracket =>
      LanguageManager.isKorean()
          ? AppStringsKo.reshuffleBracket
          : AppStringsEn.reshuffleBracket;
  static String get finishMatch =>
      LanguageManager.isKorean()
          ? AppStringsKo.finishMatch
          : AppStringsEn.finishMatch;

  // 대진표 이미지 생성기
  static String get participantsAndMatches =>
      LanguageManager.isKorean()
          ? AppStringsKo.participantsAndMatches
          : AppStringsEn.participantsAndMatches;
  static String get generatedBy =>
      LanguageManager.isKorean()
          ? AppStringsKo.generatedBy
          : AppStringsEn.generatedBy;
  static String get generatingBracketImage =>
      LanguageManager.isKorean()
          ? AppStringsKo.generatingBracketImage
          : AppStringsEn.generatingBracketImage;

  // 대진표 공유 유틸리티
  static String get generatingBracketImageMessage =>
      LanguageManager.isKorean()
          ? AppStringsKo.generatingBracketImageMessage
          : AppStringsEn.generatingBracketImageMessage;
  static String get imageCancelled =>
      LanguageManager.isKorean()
          ? AppStringsKo.imageCancelled
          : AppStringsEn.imageCancelled;
  static String get bracketShareTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.bracketShareTitle
          : AppStringsEn.bracketShareTitle;
  static String get bracketShareError =>
      LanguageManager.isKorean()
          ? AppStringsKo.bracketShareError
          : AppStringsEn.bracketShareError;

  // 인터넷 연결 오류
  static String get noInternetConnection =>
      LanguageManager.isKorean()
          ? AppStringsKo.noInternetConnection
          : AppStringsEn.noInternetConnection;
  static String get loadingContributors =>
      LanguageManager.isKorean()
          ? AppStringsKo.loadingContributors
          : AppStringsEn.loadingContributors;
  static String get loadingError =>
      LanguageManager.isKorean()
          ? AppStringsKo.loadingError
          : AppStringsEn.loadingError;

  // 커스텀 탭 바
  static String get bracketTab =>
      LanguageManager.isKorean()
          ? AppStringsKo.bracketTab
          : AppStringsEn.bracketTab;
  static String get currentRankingTab =>
      LanguageManager.isKorean()
          ? AppStringsKo.currentRankingTab
          : AppStringsEn.currentRankingTab;

  // 헤더 섹션
  static String participantsCount(int count) {
    String format =
        LanguageManager.isKorean()
            ? AppStringsKo.participantsCount
            : AppStringsEn.participantsCount;
    return format.replaceAll('%d', count.toString());
  }

  static String matchesCount(int count) {
    String format =
        LanguageManager.isKorean()
            ? AppStringsKo.matchesCount
            : AppStringsEn.matchesCount;
    return format.replaceAll('%d', count.toString());
  }

  static String get editBracket =>
      LanguageManager.isKorean()
          ? AppStringsKo.editBracket
          : AppStringsEn.editBracket;
  static String get shareBracket =>
      LanguageManager.isKorean()
          ? AppStringsKo.shareBracket
          : AppStringsEn.shareBracket;

  // 랭킹 헤더
  static String get rank =>
      LanguageManager.isKorean() ? AppStringsKo.rank : AppStringsEn.rank;
  static String get name =>
      LanguageManager.isKorean() ? AppStringsKo.name : AppStringsEn.name;
  static String get win =>
      LanguageManager.isKorean() ? AppStringsKo.win : AppStringsEn.win;
  static String get draw =>
      LanguageManager.isKorean() ? AppStringsKo.draw : AppStringsEn.draw;
  static String get lose =>
      LanguageManager.isKorean() ? AppStringsKo.lose : AppStringsEn.lose;
  static String get points =>
      LanguageManager.isKorean() ? AppStringsKo.points : AppStringsEn.points;
  static String get goalDifference =>
      LanguageManager.isKorean()
          ? AppStringsKo.goalDifference
          : AppStringsEn.goalDifference;

  // 정렬 옵션 바
  static String get sortBy =>
      LanguageManager.isKorean() ? AppStringsKo.sortBy : AppStringsEn.sortBy;

  // 토너먼트 정보 대화상자
  static String get titleLabel =>
      LanguageManager.isKorean()
          ? AppStringsKo.titleLabel
          : AppStringsEn.titleLabel;
  static String get participantsCountLabel =>
      LanguageManager.isKorean()
          ? AppStringsKo.participantsCountLabel
          : AppStringsEn.participantsCountLabel;
  static String get participantsCountValue =>
      LanguageManager.isKorean()
          ? AppStringsKo.participantsCountValue
          : AppStringsEn.participantsCountValue;
  static String get matchesCountLabel =>
      LanguageManager.isKorean()
          ? AppStringsKo.matchesCountLabel
          : AppStringsEn.matchesCountLabel;
  static String get matchesCountValue =>
      LanguageManager.isKorean()
          ? AppStringsKo.matchesCountValue
          : AppStringsEn.matchesCountValue;

  // 메인 화면
  static String get exitApp =>
      LanguageManager.isKorean() ? AppStringsKo.exitApp : AppStringsEn.exitApp;
  static String get exitConfirm =>
      LanguageManager.isKorean()
          ? AppStringsKo.exitConfirm
          : AppStringsEn.exitConfirm;
  static String get exit =>
      LanguageManager.isKorean() ? AppStringsKo.exit : AppStringsEn.exit;
  static String get home =>
      LanguageManager.isKorean() ? AppStringsKo.home : AppStringsEn.home;

  // 대회 생성 화면
  static String get createBracketTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.createBracketTitle
          : AppStringsEn.createBracketTitle;
  static String get basicInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.basicInfo
          : AppStringsEn.basicInfo;
  static String get addPlayers =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayers
          : AppStringsEn.addPlayers;
  static String get editBracketTitle =>
      LanguageManager.isKorean()
          ? AppStringsKo.editBracketTitle
          : AppStringsEn.editBracketTitle;
  static String get exitTournamentCreation =>
      LanguageManager.isKorean()
          ? AppStringsKo.exitTournamentCreation
          : AppStringsEn.exitTournamentCreation;
  static String get exitTournamentConfirm =>
      LanguageManager.isKorean()
          ? AppStringsKo.exitTournamentConfirm
          : AppStringsEn.exitTournamentConfirm;
  static String get unsavedChangesWarning =>
      LanguageManager.isKorean()
          ? AppStringsKo.unsavedChangesWarning
          : AppStringsEn.unsavedChangesWarning;
  static String get exitTournament =>
      LanguageManager.isKorean()
          ? AppStringsKo.exitTournament
          : AppStringsEn.exitTournament;

  // 대회 정보 입력 화면
  static String get tournamentInfoInput =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentInfoInput
          : AppStringsEn.tournamentInfoInput;
  static String get reset =>
      LanguageManager.isKorean() ? AppStringsKo.reset : AppStringsEn.reset;
  static String get reGenerate =>
      LanguageManager.isKorean()
          ? AppStringsKo.reGenerate
          : AppStringsEn.reGenerate;
  static String get tournamentName =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentName
          : AppStringsEn.tournamentName;
  static String get enterTournamentName =>
      LanguageManager.isKorean()
          ? AppStringsKo.enterTournamentName
          : AppStringsEn.enterTournamentName;
  static String get tournamentNameAutoSetInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentNameAutoSetInfo
          : AppStringsEn.tournamentNameAutoSetInfo;
  static String get tournamentDate =>
      LanguageManager.isKorean()
          ? AppStringsKo.tournamentDate
          : AppStringsEn.tournamentDate;
  static String get scoreInput =>
      LanguageManager.isKorean()
          ? AppStringsKo.scoreInput
          : AppStringsEn.scoreInput;
  static String get gameSettings =>
      LanguageManager.isKorean()
          ? AppStringsKo.gameSettings
          : AppStringsEn.gameSettings;
  static String get gamesPerPlayer =>
      LanguageManager.isKorean()
          ? AppStringsKo.gamesPerPlayer
          : AppStringsEn.gamesPerPlayer;
  static String get gamesPerPlayerInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.gamesPerPlayerInfo
          : AppStringsEn.gamesPerPlayerInfo;
  static String get gameFormat =>
      LanguageManager.isKorean()
          ? AppStringsKo.gameFormat
          : AppStringsEn.gameFormat;
  static String get doubles =>
      LanguageManager.isKorean() ? AppStringsKo.doubles : AppStringsEn.doubles;
  static String get singles =>
      LanguageManager.isKorean() ? AppStringsKo.singles : AppStringsEn.singles;
  static String get gameFormatInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.gameFormatInfo
          : AppStringsEn.gameFormatInfo;

  // 입력 초기화 대화상자
  static String get resetInput =>
      LanguageManager.isKorean()
          ? AppStringsKo.resetInput
          : AppStringsEn.resetInput;
  static String get resetConfirm =>
      LanguageManager.isKorean()
          ? AppStringsKo.resetConfirm
          : AppStringsEn.resetConfirm;
  static String get resetWarning =>
      LanguageManager.isKorean()
          ? AppStringsKo.resetWarning
          : AppStringsEn.resetWarning;
  static String get resetButton =>
      LanguageManager.isKorean()
          ? AppStringsKo.resetButton
          : AppStringsEn.resetButton;

  // AddPlayerScreen strings
  static String get savedPlayers =>
      LanguageManager.isKorean()
          ? AppStringsKo.savedPlayers
          : AppStringsEn.savedPlayers;
  static String get currentPlayerList =>
      LanguageManager.isKorean()
          ? AppStringsKo.currentPlayerList
          : AppStringsEn.currentPlayerList;
  static String get minPlayersRequired =>
      LanguageManager.isKorean()
          ? AppStringsKo.minPlayersRequired
          : AppStringsEn.minPlayersRequired;
  static String get maxPlayersAllowed =>
      LanguageManager.isKorean()
          ? AppStringsKo.maxPlayersAllowed
          : AppStringsEn.maxPlayersAllowed;
  static String get playersRequired =>
      LanguageManager.isKorean()
          ? AppStringsKo.playersRequired
          : AppStringsEn.playersRequired;

  // EditMatchScreen strings
  static String get noMatches =>
      LanguageManager.isKorean()
          ? AppStringsKo.noMatches
          : AppStringsEn.noMatches;
  static String get autoGenerateMatch =>
      LanguageManager.isKorean()
          ? AppStringsKo.autoGenerateMatch
          : AppStringsEn.autoGenerateMatch;
  static String get courtCount =>
      LanguageManager.isKorean()
          ? AppStringsKo.courtCount
          : AppStringsEn.courtCount;
  static String get saveAndReturn =>
      LanguageManager.isKorean()
          ? AppStringsKo.saveAndReturn
          : AppStringsEn.saveAndReturn;
  static String get saveAndComplete =>
      LanguageManager.isKorean()
          ? AppStringsKo.saveAndComplete
          : AppStringsEn.saveAndComplete;
  static String get matchSaveError =>
      LanguageManager.isKorean()
          ? AppStringsKo.matchSaveError
          : AppStringsEn.matchSaveError;
  static String get courtNumberLimitError =>
      LanguageManager.isKorean()
          ? AppStringsKo.courtNumberLimitError
          : AppStringsEn.courtNumberLimitError;
  static String get noPlayer =>
      LanguageManager.isKorean()
          ? AppStringsKo.noPlayer
          : AppStringsEn.noPlayer;
  static String get versus =>
      LanguageManager.isKorean() ? AppStringsKo.versus : AppStringsEn.versus;
  static String get isSaving =>
      LanguageManager.isKorean()
          ? AppStringsKo.isSaving
          : AppStringsEn.isSaving;
  static String get duplicatePlayerName =>
      LanguageManager.isKorean()
          ? AppStringsKo.duplicatePlayerName
          : AppStringsEn.duplicatePlayerName;
  // AddPlayerActionButton strings
  static String get addSelectedPlayers =>
      LanguageManager.isKorean()
          ? AppStringsKo.addSelectedPlayers
          : AppStringsEn.addSelectedPlayers;
  static String get addNoPlayers =>
      LanguageManager.isKorean()
          ? AppStringsKo.addNoPlayers
          : AppStringsEn.addNoPlayers;

  // EmptyPlayerListWidget strings
  static String get noAddedPlayersMessage =>
      LanguageManager.isKorean()
          ? AppStringsKo.noAddedPlayersMessage
          : AppStringsEn.noAddedPlayersMessage;
  static String get addPlayerMessage =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayerMessage
          : AppStringsEn.addPlayerMessage;

  // GroupDropdown strings
  static String get selectGroup =>
      LanguageManager.isKorean()
          ? AppStringsKo.selectGroup
          : AppStringsEn.selectGroup;
  static String get allGroups =>
      LanguageManager.isKorean()
          ? AppStringsKo.allGroups
          : AppStringsEn.allGroups;
  static String get noSavedGroups =>
      LanguageManager.isKorean()
          ? AppStringsKo.noSavedGroups
          : AppStringsEn.noSavedGroups;

  // GroupRefreshButton strings
  static String get refreshGroups =>
      LanguageManager.isKorean()
          ? AppStringsKo.refreshGroups
          : AppStringsEn.refreshGroups;

  // InlineEditablePlayerItem strings
  static String get playerNameInputHint =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerNameInputHint
          : AppStringsEn.playerNameInputHint;
  static String get save =>
      LanguageManager.isKorean() ? AppStringsKo.save : AppStringsEn.save;
  static String get tapToEdit =>
      LanguageManager.isKorean()
          ? AppStringsKo.tapToEdit
          : AppStringsEn.tapToEdit;
  static String get toggleEdit =>
      LanguageManager.isKorean()
          ? AppStringsKo.toggleEdit
          : AppStringsEn.toggleEdit;

  // NoGroupsMessage strings
  static String get noGroupsMessage =>
      LanguageManager.isKorean()
          ? AppStringsKo.noGroupsMessage
          : AppStringsEn.noGroupsMessage;

  // PlayerInputField strings
  static String get playerNameInputLabel =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerNameInputLabel
          : AppStringsEn.playerNameInputLabel;
  static String get addPlayerButtonText =>
      LanguageManager.isKorean()
          ? AppStringsKo.addPlayerButtonText
          : AppStringsEn.addPlayerButtonText;
  static String get playerNameInputInfo =>
      LanguageManager.isKorean()
          ? AppStringsKo.playerNameInputInfo
          : AppStringsEn.playerNameInputInfo;

  // PlayerSelectionList strings
  static String get selectGroupToAddPlayers =>
      LanguageManager.isKorean()
          ? AppStringsKo.selectGroupToAddPlayers
          : AppStringsEn.selectGroupToAddPlayers;
  static String get noPlayersInGroup =>
      LanguageManager.isKorean()
          ? AppStringsKo.noPlayersInGroup
          : AppStringsEn.noPlayersInGroup;
  static String get alreadyAdded =>
      LanguageManager.isKorean()
          ? AppStringsKo.alreadyAdded
          : AppStringsEn.alreadyAdded;

  // NavigationButtonsWidget strings
  static String get previous =>
      LanguageManager.isKorean()
          ? AppStringsKo.previous
          : AppStringsEn.previous;
  static String get next =>
      LanguageManager.isKorean() ? AppStringsKo.next : AppStringsEn.next;

  // PartnerAddPlayerScreen strings
  static String get partnerMinPlayersRequired =>
      LanguageManager.isKorean()
          ? AppStringsKo.partnerMinPlayersRequired
          : AppStringsEn.partnerMinPlayersRequired;
  static String get partnerMaxPlayersAllowed =>
      LanguageManager.isKorean()
          ? AppStringsKo.partnerMaxPlayersAllowed
          : AppStringsEn.partnerMaxPlayersAllowed;
  static String get partnerPlayersRequired =>
      LanguageManager.isKorean()
          ? AppStringsKo.partnerPlayersRequired
          : AppStringsEn.partnerPlayersRequired;
  static String get partnerRequired =>
      LanguageManager.isKorean()
          ? AppStringsKo.partnerRequired
          : AppStringsEn.partnerRequired;
  static String get partnerPairOverLimit =>
      LanguageManager.isKorean()
          ? AppStringsKo.partnerPairOverLimit
          : AppStringsEn.partnerPairOverLimit;
  static String partnerPairOverLimitMessage(int playerCount, int maxPairs) {
    String format =
        LanguageManager.isKorean()
            ? AppStringsKo.partnerPairOverLimitMessage
            : AppStringsEn.partnerPairOverLimitMessage;
    return format
        .replaceAll('%d1', playerCount.toString())
        .replaceAll('%d2', maxPairs.toString());
  }
  static String get matchGenerationFailed =>
      LanguageManager.isKorean()
          ? AppStringsKo.matchGenerationFailed
          : AppStringsEn.matchGenerationFailed;
  static String get matchGenerationFailedMessage =>
      LanguageManager.isKorean()
          ? AppStringsKo.matchGenerationFailedMessage
          : AppStringsEn.matchGenerationFailedMessage;
  static String get partnerPairNoPlayer =>
      LanguageManager.isKorean()
          ? AppStringsKo.partnerPairNoPlayer
          : AppStringsEn.partnerPairNoPlayer;
  static String get partnerPairNoPlayerSubText =>
      LanguageManager.isKorean()
          ? AppStringsKo.partnerPairNoPlayerSubText
          : AppStringsEn.partnerPairNoPlayerSubText;
  static String get singleTournamentNoPartner =>
      LanguageManager.isKorean()
          ? AppStringsKo.singleTournamentNoPartner
          : AppStringsEn.singleTournamentNoPartner;
  static String get partnerPairs =>
      LanguageManager.isKorean()
          ? AppStringsKo.partnerPairs
          : AppStringsEn.partnerPairs;



  // 업데이트 다이얼로그
  static String get updateNotice =>
      LanguageManager.isKorean()
          ? AppStringsKo.updateNotice
          : AppStringsEn.updateNotice;
  static String get newVersionAvailable =>
      LanguageManager.isKorean()
          ? AppStringsKo.newVersionAvailable
          : AppStringsEn.newVersionAvailable;
  static String get updateMessage =>
      LanguageManager.isKorean()
          ? AppStringsKo.updateMessage
          : AppStringsEn.updateMessage;
  static String get updateNow =>
      LanguageManager.isKorean()
          ? AppStringsKo.updateNow
          : AppStringsEn.updateNow;
  static String get updateLater =>
      LanguageManager.isKorean()
          ? AppStringsKo.updateLater
          : AppStringsEn.updateLater;
}
