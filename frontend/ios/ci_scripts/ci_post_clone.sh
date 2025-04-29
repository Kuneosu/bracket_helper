#!/bin/bash

# 현재 위치는 ios/ci_scripts, 상위로 이동
cd ../..

# Flutter 패키지 가져오기
flutter pub get

# iOS 디렉토리로 이동
cd ios

# CocoaPods 설치
pod install