#!/bin/bash

# iOS 폴더로 이동
cd ios

# CocoaPods 설치 (brew로 설치할 필요 없음, 그냥 pod install만 실행)
pod install

# 프로젝트 루트로 돌아가기
cd ..

# Flutter 패키지 설치
flutter pub get