# NoPhoneTime — 빌드 & 배포 가이드 (Mac 없이)

## 전체 흐름

```
Windows (코드 편집)
    ↓ git push → main
GitHub
    ↓ 자동 트리거
Codemagic (클라우드 Mac 빌드)
    ↓ 자동 서명 + 업로드
TestFlight → iPhone 설치
```

---

## Step 1. FamilyControls 엔타이틀먼트 신청

**가장 먼저 해야 함. 승인까지 며칠 걸림.**

1. 아래 링크에서 신청:
   https://developer.apple.com/contact/request/family-controls-distribution
2. 사용 목적 작성: "App to block distracting apps and require physical activity (running) to unlock them"
3. 승인 메일 오면 Apple Developer 계정에 자동 반영됨

---

## Step 2. App ID 등록

[Apple Developer → Certificates, IDs & Profiles](https://developer.apple.com/account/resources/identifiers/list)

### 메인 앱 App ID
- Identifier: `com.nophonetime.app`
- Capabilities 체크:
  - [x] Family Controls
  - [x] App Groups
  - [x] Background Modes (Location updates)

### Extension App ID
- Identifier: `com.nophonetime.app.monitor`
- Capabilities 체크:
  - [x] Family Controls
  - [x] App Groups

### App Group 등록
- Group ID: `group.com.nophonetime.app`
- 두 App ID 모두에 연결

---

## Step 3. App Store Connect 앱 등록

1. [App Store Connect](https://appstoreconnect.apple.com) 접속
2. **My Apps → +** → New App
3. 설정:
   - Name: `NoPhoneTime`
   - Bundle ID: `com.nophonetime.app`
   - SKU: `nophonetime`

---

## Step 4. App Store Connect API 키 발급

Codemagic이 자동 서명에 사용함.

1. App Store Connect → **Users and Access → Keys**
2. **+** 버튼 → Role: **App Manager**
3. 다운로드한 `.p8` 파일, **Key ID**, **Issuer ID** 저장

---

## Step 5. GitHub 리포지토리 생성

```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/YOUR_USERNAME/nophonetime.git
git push -u origin main
```

---

## Step 6. Codemagic 설정

1. [codemagic.io](https://codemagic.io) 접속 → GitHub 계정 연결
2. **Add application** → `nophonetime` 리포 선택
3. **YAML configuration** 선택 (codemagic.yaml 자동 감지)
4. **Environment variables** 등록:

| 변수명 | 값 | Secure |
|---|---|---|
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | Yes |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID | Yes |
| `APP_STORE_CONNECT_PRIVATE_KEY` | `.p8` 파일 내용 전체 | Yes |

---

## Step 7. 첫 빌드 실행

`main` 브랜치에 push하면 자동으로 빌드 시작.

```bash
git push origin main
```

Codemagic 빌드 완료 후 TestFlight에 자동 업로드됨.

---

## Step 8. iPhone에 설치

1. iPhone에 **TestFlight 앱** 설치
2. Apple ID로 로그인
3. App Store Connect에서 해당 Apple ID를 Internal Tester로 추가
4. TestFlight에서 NoPhoneTime 설치

---

## 이후 개발 사이클

```
코드 수정 (Windows)
    ↓
git push origin main
    ↓
Codemagic 자동 빌드 (~10분)
    ↓
TestFlight 자동 업데이트
    ↓
iPhone에서 확인
```

---

## 파일 구조

```
nophonetime/
├── project.yml                     ← XcodeGen 프로젝트 정의
├── codemagic.yaml                  ← 빌드/배포 파이프라인
├── .gitignore
├── NoPhoneTime/
│   ├── App/
│   │   ├── NoPhoneTimeApp.swift
│   │   ├── ContentView.swift
│   │   └── Colors.swift
│   ├── ViewModels/
│   │   └── AppViewModel.swift
│   ├── Services/
│   │   ├── LockService.swift
│   │   └── LocationService.swift
│   ├── Features/
│   │   ├── Setup/SetupView.swift
│   │   ├── Locked/LockedView.swift
│   │   ├── RunReady/RunReadyView.swift
│   │   ├── Running/RunningView.swift
│   │   └── Finish/FinishView.swift
│   ├── Info.plist
│   └── NoPhoneTime.entitlements
└── DeviceActivityMonitorExtension/
    ├── DeviceActivityMonitorExtension.swift
    ├── DeviceActivityMonitorExtension.entitlements
    └── Info.plist
```
