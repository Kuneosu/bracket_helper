#!/bin/sh
set -e                           # 오류 발생 시 즉시 종료

cd "$CI_PRIMARY_REPOSITORY_PATH" # = 리포지토리 루트

## 1. Flutter 설치(권장: 버전 고정)
git clone https://github.com/flutter/flutter.git -b stable --depth 1 $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

## 2. iOS 아티팩트 사전 다운로드
flutter precache --ios

## 3. 의존성
flutter pub get

## 4. CocoaPods
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods   # Homebrew 자동 업데이트 방지
cd ios && pod install
