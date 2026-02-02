# 🏗️ Tenken EngiFlow - Engineering Task Management System

<div align="center">
  
![Flutter](https://img.shields.io/badge/Flutter-3.16-blue?style=flat&logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Emulator-orange?style=flat&logo=firebase)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=flat)
![Status](https://img.shields.io/badge/Status-In%20Development-yellow?style=flat)

**A professional task management solution for Japanese engineering companies**

</div>

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [User Roles & Permissions](#-user-roles--permissions)
- [Installation Guide](#-installation-guide)
- [Usage Guide](#-usage-guide)
- [Technology Stack](#-technology-stack)
- [Firebase Setup](#-firebase-setup)
- [Development Guidelines](#-development-guidelines)

---

## 🎯 Overview

**Tenken EngiFlow** is a mobile application designed specifically for Japanese engineering and construction companies to manage daily workloads, maintenance tasks, and employee evaluations. The app emphasizes **accuracy, discipline, documentation, and traceability** in engineering operations.

### 主な概要 (Main Overview)

**Tenken EngiFlow**は、日本のエンジニアリング・建設会社向けに特別に設計されたモバイルアプリケーションです。日々の作業負荷、メンテナンス業務、従業員評価を管理することを目的としています。本アプリは、エンジニアリング業務における**正確性、規律、文書化、追跡可能性**を重視しています。

---

## ✨ Key Features

### 🔐 Authentication & Security

- **Role-based login system** (Engineer/Supervisor/Admin)
- **Secure Firebase Authentication** with email/password
- **Automatic session management**
- **Department-based user grouping**

### 📊 Dashboard & Monitoring

- **Today's Attendance Status** - Real-time check-in/check-out tracking
- **Daily Work Entries** - Task completion tracking (Done/Pending)
- **Machinery Inspection Alerts** - Automated reminders for equipment checks
- **Pending Reports** - Overview of due documentation
- **Role-specific views** - Customized dashboard for each user type

### 📝 Task Management

- **Work Entry Creation** - Log daily tasks with timestamps
- **Task Assignment** - Supervisors can assign work to engineers
- **Progress Tracking** - Visual indicators for task completion
- **Priority System** - Urgent/Important/Normal classification

### 🏷️ Japanese Engineering Standards

- **Clean, Minimalist UI** - Japanese aesthetic design principles
- **Information Density** - More data, less clutter
- **No Unnecessary Animations** - Focus on functionality
- **Bilingual Support** - English/Japanese interface (Future Release)

### 主な機能 (Key Features - Japanese)

#### 🔐 認証とセキュリティ

- **役割ベースのログインシステム** (技術者/監督者/管理者)
- **メール/パスワードによる安全なFirebase認証**
- **自動セッション管理**
- **部門別ユーザーグループ化**

#### 📊 ダッシュボードと監視

- **本日の出勤状況** - リアルタイム出退勤追跡
- **日次作業記録** - タスク完了状況追跡 (完了/保留)
- **機械点検アラート** - 設備チェックの自動リマインダー
- **未処理レポート** - 期限文書の概要
- **役割別表示** - ユーザー種別ごとのカスタマイズされたダッシュボード

#### 📝 タスク管理

- **作業記録作成** - タイムスタンプ付き日次タスク記録
- **タスク割り当て** - 監督者が技術者に作業を割り当て可能
- **進捗状況追跡** - タスク完了の視覚的指標
- **優先度システム** - 緊急/重要/通常の分類

---

## 👥 User Roles & Permissions

| Role                     | 役割                                                                       | Permissions                                                                                                                                                             | 権限                                                                                                                                        |
| ------------------------ | -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **Engineer**<br>技術者   | Field workers, site engineers<br>現場作業員、現場技術者                    | • Create daily work entries<br>• Submit inspection reports<br>• View assigned tasks<br>• Check attendance status                                                        | • 日次作業記録の作成<br>• 点検報告書の提出<br>• 割り当てられたタスクの表示<br>• 出勤状況の確認                                              |
| **Supervisor**<br>監督者 | Team leaders, project managers<br>チームリーダー、プロジェクトマネージャー | • All Engineer permissions<br>• Approve/reject work entries<br>• Assign tasks to engineers<br>• Generate team performance reports<br>• View machinery inspection alerts | • 技術者の全権限<br>• 作業記録の承認/拒否<br>• 技術者へのタスク割り当て<br>• チームパフォーマンスレポートの作成<br>• 機械点検アラートの表示 |
| **Admin**<br>管理者      | System administrators, head office<br>システム管理者、本社                 | • All Supervisor permissions<br>• Manage user accounts<br>• Configure system settings<br>• Access all company data<br>• Generate company-wide reports                   | • 監督者の全権限<br>• ユーザーアカウントの管理<br>• システム設定の構成<br>• 全社データへのアクセス<br>• 全社レポートの作成                  |

---

## 🎛️ Admin Dashboard (NEW! ✨)

### Overview (管理者ダッシュボード)

The **Admin Dashboard** provides comprehensive system administration tools with 5 main tabs:

**管理者ダッシュボード**は、5つのメインタブを備えた包括的なシステム管理ツールです：

### 5 Admin Tabs:

1. **📊 Overview Tab**
   - System statistics (total users, engineers, supervisors, admins)
   - Recent activity feed
   - System health status indicators

2. **👥 User Management Tab**
   - Add/Edit/Delete users
   - Search users by name or email
   - Filter users by role
   - Bulk user operations (future)

3. **⚙️ System Configuration Tab**
   - Department management (add, edit, view teams)
   - Company settings (maintenance mode, company name)
   - Notification preferences (push, email, SMS)

4. **📈 Reports & Analytics Tab**
   - Key performance indicators (KPIs)
   - Department performance metrics
   - Custom date range filtering
   - Export to PDF/Excel (coming soon)

5. **🔐 Permissions Management Tab**
   - Role-based permission matrix
   - Engineer/Supervisor/Admin permission levels
   - Fine-grained access control configuration

### Admin Dashboard Documentation

- 📖 **QUICK_START.md** - Quick reference guide (5 min read)
- 📚 **DEVELOPMENT_INSTRUCTIONS.md** - Complete how-to guide
- 📋 **ADMIN_DASHBOARD_GUIDE.md** - Technical implementation details
- 📊 **ADMIN_DASHBOARD_SUMMARY.md** - Project summary & status

### Access Admin Dashboard

```
1. Login with admin credentials
2. Dashboard automatically shows all 5 tabs
3. Available only to users with role: "admin"
4. Full bilingual support (English/Japanese)
```

---

## 🚀 Installation Guide

### Prerequisites 前提条件

- **Flutter SDK** (version 3.16.0 or higher)
- **Android Studio** or VS Code with Flutter extension
- **Android Emulator** or physical device (API 21+)
- **Firebase Account** (for backend services)

### Step-by-Step Setup 段階的なセットアップ

```bash
# 1. Clone the repository
git clone https://your-repository/tenken_engiflow.git
cd tenken_engiflow

# 2. Install dependencies
flutter pub get

# 3. Setup Firebase (See Firebase Setup section below)

# 4. Run the application
flutter run
```

### Firebase Setup Firebaseセットアップ

1. **Create Firebase Project** Firebaseプロジェクトの作成
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Click "Add Project" → Name: "Tenken EngiFlow"
   - Disable Google Analytics (optional)

2. **Register Android App** Androidアプリの登録
   - Click "Add App" → Android
   - Package name: `com.tenken.engiflow`
   - Download `google-services.json`
   - Place file in `android/app/`

3. **Enable Firebase Services** Firebaseサービスの有効化
   - **Authentication** → Sign-in method → Enable Email/Password
   - **Firestore Database** → Create Database → Start in test mode
   - Set location to `asia-northeast1` (Tokyo) for better latency

4. **Configure Firestore Rules** Firestoreルールの設定

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
  }
}
```

---

## 📱 Usage Guide 使用方法ガイド

### For Engineers 技術者向け

1. **Daily Login** 日次ログイン
   - Open app and enter credentials
   - Dashboard shows today's tasks and attendance status
   - アプリを開き、資格情報を入力
   - ダッシュボードに本日のタスクと出勤状況が表示

2. **Work Entry Creation** 作業記録の作成
   - Tap "New Entry" from dashboard
   - Select task type, add description, set priority
   - Submit for supervisor approval
   - ダッシュボードから「新規記録」をタップ
   - タスク種別を選択、説明を追加、優先度を設定
   - 監督者の承認のために提出

3. **Report Submission** 報告書の提出
   - Navigate to "Reports" section
   - Fill inspection checklist
   - Attach photos if needed
   - Submit before deadline
   - 「報告書」セクションに移動
   - 点検チェックリストを記入
   - 必要に応じて写真を添付
   - 期限前に提出

### For Supervisors 監督者向け

1. **Team Monitoring** チーム監視
   - View all engineers' attendance on dashboard
   - Check pending work entries requiring approval
   - Monitor machinery inspection alerts
   - ダッシュボードで全技術者の出勤状況を表示
   - 承認が必要な保留中の作業記録を確認
   - 機械点検アラートを監視

2. **Task Assignment** タスク割り当て
   - Select engineer from team list
   - Assign tasks with deadlines and priorities
   - Set recurring tasks for regular maintenance
   - チームリストから技術者を選択
   - 期限と優先度付きでタスクを割り当て
   - 定期的なメンテナンスのための繰り返しタスクを設定

3. **Report Approval** 報告書の承認
   - Review submitted reports
   - Add comments or request revisions
   - Approve completed reports
   - Generate weekly performance summaries
   - 提出された報告書を確認
   - コメントを追加または修正を要求
   - 完了した報告書を承認
   - 週次パフォーマンス概要を作成

---

## 🛠️ Technology Stack

### Frontend フロントエンド

- **Flutter 3.16** - Cross-platform framework
- **Dart 3.2** - Programming language
- **Material Design 3** - UI components with Japanese minimalism

### Backend & Database バックエンドとデータベース

- **Firebase Authentication** - User management
- **Cloud Firestore** - NoSQL database
- **Firebase Security Rules** - Data protection

### State Management & Architecture 状態管理とアーキテクチャ

- **Provider** - State management
- **Clean Architecture** - Separation of concerns
- **Repository Pattern** - Data abstraction

### Development Tools 開発ツール

- **Android Studio** - Primary IDE
- **Firebase Emulator Suite** - Local testing
- **Git** - Version control

---

## 🏗️ Development Guidelines

### Code Structure コード構造

```
lib/
├── core/           # App constants, themes, utilities
├── data/           # Data layer (models, repositories)
├── domain/         # Business logic (entities, use cases)
└── presentation/   # UI layer (screens, widgets, providers)
```

### Japanese UI Principles 日本のUI原則

1. **Minimal Color Palette** - Use blues, greys, whites (企業カラーの青、グレー、白)
2. **High Information Density** - Show relevant data efficiently (関連データを効率的に表示)
3. **Clean Typography** - Clear hierarchy without decorative fonts (装飾的なフォントなしで明確な階層)
4. **Consistent Spacing** - Use 8px grid system (8pxグリッドシステムを使用)
5. **Intuitive Icons** - Standard Material icons with Japanese context (日本の文脈に合った標準Materialアイコン)

### Security Considerations セキュリティ考慮事項

- All API calls through Firebase secured endpoints
- Role-based access control at Firestore rules level
- Password hashing via Firebase Auth
- No sensitive data in client-side storage
- Firebaseセキュアエンドポイントを介した全APIコール
- Firestoreルールレベルでの役割ベースアクセス制御
- Firebase Authによるパスワードハッシュ化
- クライアント側ストレージに機密データなし

---

## 🔮 Future Enhancements 将来の拡張機能

### Phase 2 (Next Release) フェーズ2 (次回リリース)

- [ ] **Japanese/English language toggle** 日本語/英語言語切り替え
- [ ] **Offline mode with sync** 同期付きオフラインモード
- [ ] **QR code scanning for equipment** 設備用QRコードスキャン
- [ ] **Photo attachment to reports** 報告書への写真添付
- [ ] **Push notifications for alerts** アラートのプッシュ通知

### Phase 3 フェーズ3

- [ ] **GPS location tracking** GPS位置情報追跡
- [ ] **Barcode generation for assets** 資産用バーコード生成
- [ ] **Integration with accounting software** 会計ソフトウェアとの統合
- [ ] **Advanced analytics dashboard** 高度な分析ダッシュボード
- [ ] **API for third-party systems** サードパーティシステム用API

---

## 📄 License & Contributing ライセンスと貢献

### License ライセンス

This project is proprietary software developed for internal use by engineering companies. All rights reserved.

本プロジェクトは、エンジニアリング会社の内部使用のために開発されたプロプライエタリソフトウェアです。すべての権利を保有します。

### Contributing 貢献

For bug reports or feature suggestions, please contact the development team at `bhnbids@gmail.com`.

バグ報告や機能提案については、開発チーム `dev@tenken-engiflow.com` までご連絡ください。

---

<div align="center">

**Developed with precision for Japanese engineering excellence** by **_Hossain Billal_** (ビラル ホセイン)
**日本のエンジニアリング優秀性のために精密に開発**

© 2026 Tenken EngiFlow. All rights reserved.

</div>

---

🎯 ROLE-BASED ARCHITECTURE PLAN
Role Definitions & Permissions:

Role - Dashboard Focus - Features - Access Level

Engineer - Task execution Daily work entries, inspections, personal - reports - Personal data only

Supervisor - Team oversight Team progress, report approval, task assignment - Team-level access

Admin - System management User management, analytics, system configuration - Full system access

---

📱 TESTING DIFFERENT ROLES:
To test different roles, you'll need to:

Register multiple users with different roles

Check Firebase Console to verify role assignment

Logout and login with different accounts

Example Test Users:

Engineer: engineer@tenken.com / Password123

Supervisor: supervisor@tenken.com / Password123

Admin: admin@tenken.com / Password123
