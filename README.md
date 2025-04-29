# 대진 도우미 

![License](https://img.shields.io/badge/license-MIT-blue)

> **아마추어 스포츠·소규모 대회를 위한 오프라인 대진표 빌더 & 매니저**

---
![Play Store 그래픽 이미지](https://github.com/user-attachments/assets/d5009d9e-04c8-4847-82cd-c6dbc429a808)

## ✨ 프로젝트 개요

**대진 도우미**는 배드민턴·탁구·테니스 등 생활 체육 동호회나 학교·사내 친선전을 쉽고 빠르게 운영할 수 있도록 돕는 모바일 앱입니다. 인터넷 연결이 없더라도 대진표 생성, 경기 결과 입력, 순위 집계, 이미지 공유까지 **모두 기기 내에서** 처리합니다.

### 🎯 개발 목적
- **개인 학습** : Flutter·Clean Architecture 실습 및 포트폴리오 구축
- **실사용** : 현재 활동 중인 클럽 경기 운영에 즉시 활용

### 📂 레포지토리 목적
- Git을 통한 **버전 관리**
- 기능 추가·수정 내역 **기록 및 추적**

---

## 🔑 주요 기능

| 카테고리 | 기능 |
|-----------|------|
| 대진표 생성 | 3‑단계 마법사로 대회 정보·선수·대진표 설정 |
| 선수 관리 | 선수 목록 저장, 폴더별 그룹 관리, 빠른 불러오기 |
| 대진표 편집 | 자동 생성·드래그&드롭 수정, 랜덤 재생성 |
| 경기 진행 | 점수 입력, 실시간 순위 계산, 다중 정렬 |
| 공유 | 대진표·순위표 이미지 캡처 후 시스템 공유 |
| 완전 오프라인 | Drift(SQLite) 로컬 DB — 서버 불필요 |

---

## 📸 스크린샷

<p align="center">
  <img src="https://github.com/user-attachments/assets/4284f765-e228-4f64-921a-4ed2b29b016b" width="200"/>
  <img src="https://github.com/user-attachments/assets/bcb39271-f7d2-4a0d-8166-1c7a3cb8c558" width="200"/>
  <img src="https://github.com/user-attachments/assets/f8855037-319c-4bae-903e-fe23175b0739" width="200"/>
  <img src="https://github.com/user-attachments/assets/6b9873d8-afd6-4207-8512-b447b33c44ba" width="200"/>
  <img src="https://github.com/user-attachments/assets/dd8c571d-27bd-418e-964a-990adedd173d" width="200"/>
  <img src="https://github.com/user-attachments/assets/80924cc7-7486-4726-9175-9a53c8d08b04" width="200"/>
  <img src="https://github.com/user-attachments/assets/f1e62972-c1c9-4507-9494-34c6088d7c05" width="200"/>
</p>

---

## 📁 프로젝트 구조 (요약)

```
lib/
 ├─ core/            # 공통 상수, 테마, 유틸
 ├─ data/            # Drift 테이블, DAO, Repository 구현
 ├─ domain/          # 엔티티, UseCase
 ├─ presentation/    # UI 화면 / 상태
 └─ main.dart        # 엔트리 포인트
```

---

## 🏗️ 기술 스택

- **Flutter 3.29.2** · **Dart 3.7.2**
- **GetIt** – 의존성 주입·상태 관리
- **GoRouter** – 네비게이션
- **Drift (SQLite)** – 로컬 데이터베이스
- **Clean Architecture + MVVM**

---

## 🗂️ 아키텍처

```
Presentation ↔ ViewModel ↔ UseCase ↔ Repository ↔ Drift(DB)
```

단방향 의존성으로 테스트와 유지보수를 용이하게 합니다.

---

## 🗓️ 버전 규칙

`v <메이저>.<YYWEEKS>.<빌드>`  예) `v 1.2516.19`

---

## 📜 라이선스

```
MIT License
Copyright (c) 2025 Kuneosu
```

---

## 📬 연락처

- Email: **brackethelper@gmail.com**

> 피드백과 기여를 언제든 환영합니다!

