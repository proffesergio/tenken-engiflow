<div align="center">

# 🏗️ Tenken EngiFlow

### 現場エンジニアリング管理システム

### Field Engineering Management System

[![Flutter](https://img.shields.io/badge/Flutter-3.16+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud-FFCA28?style=flat&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-4CAF50?style=flat&logo=android&logoColor=white)](https://flutter.dev/multi-platform)
[![i18n](https://img.shields.io/badge/Language-日本語%20%7C%20English-red?style=flat)](https://github.com)
[![Status](https://img.shields.io/badge/Status-Showcase%20Ready-brightgreen?style=flat)](https://github.com)

**日本のエンジニアリング会社向けに設計されたモバイルファーストの統合タスク管理・報告システム**

**A mobile-first integrated task management and reporting system built for Japanese engineering companies**

</div>

---

## 言語 / Language

- 🇯🇵 [日本語版 README はこちら](#-日本語ガイド)
- 🇬🇧 [English Guide below](#-english-guide)

---

# 🇬🇧 English Guide

## Table of Contents

- [Overview](#overview)
- [App Flow](#app-flow)
- [Key Features](#key-features)
- [User Roles & Permissions](#user-roles--permissions)
- [How to Use — Engineers](#how-to-use--engineers)
- [How to Use — Supervisors](#how-to-use--supervisors)
- [How to Use — Admins](#how-to-use--admins)
- [Technology Stack](#technology-stack)
- [Installation](#installation)
- [Roadmap](#roadmap)

---

## Overview

**Tenken EngiFlow** is a role-based engineering task management application built with Flutter and Firebase. It is designed to digitise and streamline the daily workflows of Japanese engineering field teams — from task assignment and attendance tracking to issue reporting and analytics.

The app requires **no login to view** the public dashboard. First-time visitors are greeted with a guided tutorial that explains the system, and a small Login button in the top-right corner allows authenticated users (admins, supervisors, and engineers) to access their personalised dashboard.

---

## App Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                           APP LAUNCH                                │
│                               ↓                                     │
│                      Splash Screen (/)                              │
│                               ↓                                     │
│                    Public Home Screen (/home)                       │
│               ┌───────────────────────────────┐                    │
│               │  • First-launch tutorial popup │                    │
│               │  • Live stats dashboard        │                    │
│               │  • Urgent tasks overview       │                    │
│               │  • Active teams feed           │                    │
│               │  • Recent activity timeline    │                    │
│               │  • [ログイン / Login] button   │                    │
│               └───────────────────────────────┘                    │
│                               ↓                                     │
│                    Login Screen (/login)                            │
│              Email + Password  →  Role determined                   │
│              automatically from user's Firebase record              │
│                               ↓                                     │
│               ┌──────────────────────────────┐                     │
│               │   Role-Based Dashboard        │                     │
│               │   /dashboard                  │                     │
│               ├──────────────────────────────┤                     │
│               │  👷 Engineer Dashboard        │                     │
│               │  👔 Supervisor Dashboard      │                     │
│               │  🔑 Admin Dashboard           │                     │
│               └──────────────────────────────┘                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Key Features

### 🏠 Public Home Screen — No Login Required

The landing page is a professional dashboard visible to anyone. It shows:

| Widget              | Description                                                    |
| ------------------- | -------------------------------------------------------------- |
| **Hero Banner**     | Company name, current date/time, live indicator                |
| **Stats Grid**      | Active teams, urgent tasks, pending approvals, attendance rate |
| **Urgent Tasks**    | High-priority tasks with assignee and deadline                 |
| **Active Teams**    | Which teams are currently on-site and where                    |
| **Recent Activity** | Timestamped live feed of latest events                         |
| **Login CTA**       | Prominent but non-intrusive login card with role badges        |

```
┌───────────────────────────────────────────────────────┐
│  🔧 Tenken EngiFlow  現場管理システム       [ログイン] │
│  LIVE  2026年5月13日  09:30                           │
│                                                       │
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐         │
│  │   4    │ │   2    │ │   6    │ │  94%   │         │
│  │チーム  │ │ 緊急   │ │ 承認待 │ │ 出勤率 │         │
│  │ Teams  │ │ Urgent │ │Pending │ │Attend. │         │
│  └────────┘ └────────┘ └────────┘ └────────┘         │
│                                                       │
│  ⚠️ HIGH  第3工場 消防設備点検  →  本日 15:00         │
│  ⚠️ HIGH  設備B-12 緊急修理    →  本日 17:00         │
│                                                       │
│  👥 LIVE  田中チーム — 安全点検 — 第1工場             │
│           佐藤チーム — 設備保守 — 第2工場             │
│           鈴木チーム — 品質検査 — 第3工場             │
│                                                       │
│  13:42 ✅  田中 太郎 が安全点検を完了                │
│  13:15 ⚠️  設備B-3 の問題が報告されました            │
│  12:55 ▶️  佐藤チーム が作業を開始                   │
└───────────────────────────────────────────────────────┘
```

### 🎓 First-Launch Tutorial

On first open, a 4-slide tutorial dialog appears automatically:

| Slide | Content                                                              |
| ----- | -------------------------------------------------------------------- |
| 1     | **Welcome** — System purpose and overview                            |
| 2     | **For Engineers** — Tasks, check-in, reports, issue reporting        |
| 3     | **For Supervisors & Admins** — Team management, approvals, analytics |
| 4     | **Getting Started** — How to login and which role to use             |

The tutorial can be dismissed at any time and re-opened via the `?` icon in the app bar.

### 🔐 Authentication & Security

- Role-based login — one login screen, role loaded from Firebase
- Deactivated accounts are blocked immediately at login
- GoRouter redirect guards all authenticated routes
- Firestore security rules enforce per-role data access
- Secondary Firebase app pattern prevents admin session loss when creating users

---

## User Roles & Permissions

|                                   | 👷 Engineer<br>技術者 | 👔 Supervisor<br>監督者 | 🔑 Admin<br>管理者 |
| --------------------------------- | --------------------- | ----------------------- | ------------------ |
| View public home screen           | ✅                    | ✅                      | ✅                 |
| View own tasks                    | ✅                    | ✅                      | ✅                 |
| Daily check-in / check-out        | ✅                    | ✅                      | ✅                 |
| Submit work entries               | ✅                    | ✅                      | ✅                 |
| Report issues                     | ✅                    | ✅                      | ✅                 |
| View team members                 | ❌                    | ✅ (own dept)           | ✅                 |
| Assign tasks to engineers         | ❌                    | ✅                      | ✅                 |
| Approve / reject work entries     | ❌                    | ✅                      | ✅                 |
| Approve / reject tasks            | ❌                    | ✅                      | ✅                 |
| Manage team issues                | ❌                    | ✅                      | ✅                 |
| View team attendance analytics    | ❌                    | ✅ (own dept)           | ✅                 |
| Create / deactivate user accounts | ❌                    | ❌                      | ✅                 |
| Manage departments                | ❌                    | ❌                      | ✅                 |
| View all departments' data        | ❌                    | ❌                      | ✅                 |
| System-wide analytics             | ❌                    | ❌                      | ✅                 |

---

## How to Use — Engineers

Engineers are the primary field workers. After logging in they land on the **Engineer Dashboard** with five tabs.

### 🏠 Home Tab

- **Attendance card** — Tap `チェックイン` to clock in. The card shows your check-in time and a running duration. Tap `チェックアウト` when done (hours are calculated automatically).
- **Task summary grid** — Four counters: Pending / In Progress / Submitted / Approved.
- **Quick actions** — Shortcut buttons to log a work entry or report an issue.
- **Today's tasks** — The first few active tasks at a glance.

### 📋 Tasks Tab

- Filter tasks with chip bar: `All` / `Pending` / `In Progress` / `Submitted` / `Done`.
- Overdue tasks are flagged with a red badge.
- Tap a task card to open the **Task Detail screen** — view priority, deadline, description, and a status timeline.
- From detail: `Start Task` → `Submit for Review` → awaits supervisor approval.
- If rejected, a rejection card appears with the supervisor's reason; tap `Resubmit` after making changes.

### 📊 Reports Tab (Work Entries & Issues)

- Two sub-tabs: **Work Entries** and **Issues**.
- **Work Entries** — Tap the `+` FAB to log daily work: date, description, hours worked, linked task.
- **Issues** — Tap the `+` FAB to report a problem: title, description, severity (`Low / Medium / High / Critical`), category.
- All submissions go to Firestore and appear in the supervisor's **Approvals** tab.

### 👤 Profile Tab

- View your account info, role badge, and department.
- Toggle between 🇬🇧 English and 🇯🇵 Japanese.
- Logout with confirmation dialog.

```
Engineer Dashboard:
┌──────────────────────────────────────┐
│  Engineer Dashboard     [ROLE] [OUT] │
│  第2工場  田中 太郎                   │
├──────────────────────────────────────┤
│  おはようございます！                 │
│                                      │
│  [✅ チェックイン  09:02]             │
│  本日の勤務時間: 3時間12分            │
│                                      │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐│
│  │  3   │ │  2   │ │  1   │ │  5   ││
│  │未開始│ │進行中│ │提出済│ │ 完了 ││
│  └──────┘ └──────┘ └──────┘ └──────┘│
│                                      │
│  [+ 作業報告] [⚠️ 問題報告]          │
└──────────────────────────────────────┘
[🏠 Home][📋 Tasks][📊 Reports][👤 Profile]
```

---

## How to Use — Supervisors

Supervisors oversee a department's team. After login they land on the **Supervisor Dashboard** with four tabs.

### 📊 Overview Tab

- **Stats grid** — Team size, pending approvals, today's attendance %, open issues.
- **Quick actions** — Assign a new task, refresh data.
- **Recent activity feed** — Timestamped list of task updates, check-ins, and issue reports from the team.

### 👥 Team Tab

- Search bar to find a team member by name.
- Each member card shows their department, role, and quick-action buttons.
- **Assign task** — Opens a dialog: title, description, priority, due date, select assignee.
- **Update attendance** — Opens a dialog to manually record a member's attendance status.
- Tap a member to open their **details sheet** with full profile and task history.

### ✅ Approvals Tab

Three sub-tabs with badge counts:

| Sub-tab          | What's shown                    | Actions                                 |
| ---------------- | ------------------------------- | --------------------------------------- |
| **Tasks**        | Submitted tasks awaiting review | Approve / Reject (with reason)          |
| **Work Entries** | Submitted daily logs            | Approve / Reject                        |
| **Issues**       | Open issues in the department   | Assign to a team member / Mark resolved |

### 📈 Analytics Tab

- Pick a date to view attendance for that day (present / late / absent breakdown).
- Pending approval counts and issue overview.
- Full attendance record list with status chips.
- Critical issue warning appears when any unresolved critical issue exists.

```
Supervisor Dashboard:
┌──────────────────────────────────────┐
│  Supervisor Dashboard   [ROLE] [OUT] │
│  第1工場  佐藤 監督                   │
├──────────────────────────────────────┤
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐│
│  │  12  │ │  6   │ │  94% │ │  2   ││
│  │ チーム│ │承認待│ │ 出勤 │ │問題  ││
│  └──────┘ └──────┘ └──────┘ └──────┘│
│                                      │
│  [タスク割り当て]  [更新]             │
│                                      │
│  最新アクティビティ                   │
│  13:42 田中 太郎 が点検完了           │
│  13:15 設備B-3 問題報告              │
└──────────────────────────────────────┘
[📊 Overview][👥 Team][✅ Approvals][📈 Analytics]
```

---

## How to Use — Admins

Admins have full system access. After login they land on the **Admin Dashboard** with five tabs.

### 📊 Overview Tab

- System-wide stats: total users (by role), tasks (by status), issues (by status).
- Recent activity feed pulling from multiple Firestore collections.

### 👥 User Management Tab

- **Search** users by name or email.
- **Filter** by role: All / Engineer / Supervisor / Admin.
- **Add user** — Name, email, password, role, department. Uses a secondary Firebase app so the admin's own session is never interrupted.
- **Edit user** — Change name, department, or role.
- **Deactivate** — Marks the account as inactive. The user is blocked on their next login attempt without deleting their data.

### 📋 Tasks Tab (Admin)

- View **all tasks** across all departments.
- Search by title; filter by status and priority.
- Each task card shows priority badge, status badge, and overdue flag.
- Use the `⋮` menu to change a task's status directly.

### ⚠️ Issues Tab (Admin)

- View **all issues** across all departments.
- Search; filter by status and severity.
- Severity and status badges for quick scanning.
- Use the `⋮` menu to update issue status.

### 📈 Reports & Analytics Tab

- Horizontal bar charts (no external library) for:
  - User distribution by role
  - Task status breakdown
  - Issue overview (by status and severity)
  - Department performance breakdown
- Export placeholders (PDF/Excel — Phase 2).

```
Admin Dashboard:
┌──────────────────────────────────────┐
│  Admin Dashboard        [ROLE] [OUT] │
├──────────────────────────────────────┤
│  総ユーザー: 45  技術者: 32          │
│  タスク: 127    問題: 8 (重大: 1)   │
│                                      │
│  タスク状況                          │
│  完了  ██████████░░░  68%           │
│  進行中 ████░░░░░░░░  24%           │
│  未着手 ██░░░░░░░░░░  8%            │
└──────────────────────────────────────┘
[📊 Overview][👥 Users][📋 Tasks][⚠️ Issues][📈 Reports]
```

---

## Technology Stack

| Layer                | Technology               | Details                                |
| -------------------- | ------------------------ | -------------------------------------- |
| **Frontend**         | Flutter 3.16+            | iOS, Android, Web                      |
| **Language**         | Dart 3.2+                | Null-safe, strongly typed              |
| **UI**               | Material Design 3        | Japanese minimalist aesthetic          |
| **State Management** | Provider 6.1             | Efficient reactive UI                  |
| **Routing**          | go_router 12             | Deep-link ready, redirect guards       |
| **Backend**          | Firebase Cloud Firestore | Real-time NoSQL, Tokyo region          |
| **Authentication**   | Firebase Auth 4.15       | Email/password, session management     |
| **Notifications**    | Firebase Messaging 14    | Push notification infrastructure       |
| **Localisation**     | Flutter l10n             | Japanese + English, runtime switchable |
| **Local Storage**    | shared_preferences       | Tutorial seen flag, user preferences   |
| **Security**         | Firestore Security Rules | Per-role data access enforcement       |

### Firebase Project

- **Region**: `asia-northeast1` (Tokyo) for minimum latency
- **Firestore collections**: `users`, `tasks`, `work_entries`, `issues`, `attendance`, `departments`, `system_config`
- **Security**: Role-based rules — engineers see only their own data; supervisors see their department; admins see everything

---

## Installation

### Prerequisites

- Flutter SDK 3.16 or higher
- Android Studio / VS Code with Flutter extension
- Firebase account with a project configured

### Setup Steps

```bash
# 1. Clone the repository
git clone https://github.com/your-org/tenken_engiflow.git
cd tenken_engiflow

# 2. Install dependencies
flutter pub get

# 3. Place your Firebase config file
#    Android: android/app/google-services.json
#    iOS:     ios/Runner/GoogleService-Info.plist
#    Web:     already wired in lib/firebase_options.dart

# 4. Deploy Firestore security rules
firebase deploy --only firestore:rules

# 5. Run the app
flutter run
```

### Firebase Configuration

1. Create a project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Email/Password** under Authentication → Sign-in method
3. Create a **Cloud Firestore** database in `asia-northeast1` (Tokyo)
4. Register your Android/iOS app and download the config files
5. Use the existing `firestore.rules` at project root

### First Admin Account

Create the first admin directly in Firebase Console:

1. **Authentication** → Add user (email + password)
2. **Firestore** → `users` collection → New document with the user's `uid`:

```json
{
  "uid": "<firebase-auth-uid>",
  "email": "admin@yourcompany.co.jp",
  "displayName": "管理者",
  "role": "admin",
  "department": "システム管理部",
  "isActive": true,
  "createdAt": "<timestamp>"
}
```

After that, the admin can create all other users from the app's **User Management** tab.

---

## Roadmap

### Phase 1 — Complete ✅

- [x] Public home screen with live-looking dashboard
- [x] First-launch tutorial (4 slides, bilingual)
- [x] GoRouter with auth redirect guards
- [x] Engineer dashboard — all 5 tabs (Home, Tasks, Task Detail, Reports, Profile)
- [x] Supervisor dashboard — all 4 tabs (Overview, Team, Approvals, Analytics)
- [x] Admin dashboard — all 5 tabs (Overview, Users, Tasks, Issues, Reports)
- [x] Real Firestore data throughout (no hardcoded values)
- [x] Attendance check-in / check-out with late detection
- [x] Issue reporting with severity levels
- [x] Work entry submission and approval workflow
- [x] Task assignment, progress tracking, and approval/rejection
- [x] Bilingual EN/JP with runtime language toggle
- [x] Firestore security rules (role-based)
- [x] Push notification infrastructure (FCM)
- [x] Deactivated account enforcement at login

### Phase 2 — Planned

- [ ] PDF report export (pdf + printing packages)
- [ ] Excel data export
- [ ] Photo attachments for work entries and issue reports
- [ ] Offline support (Firestore persistence + sync indicator)
- [ ] QR code scanning for equipment ID lookup

### Phase 3 — Future

- [ ] AI-assisted anomaly detection and predictive maintenance alerts
- [ ] Electronic signature for report sign-off
- [ ] ERP / SAP integration API
- [ ] Web admin portal (Flutter Web)
- [ ] Smartwatch companion (Apple Watch / Wear OS)

---

## License & Contact

This is proprietary software developed for Japanese engineering companies. All rights reserved.

For demo access or business enquiries: **bhnbids@gmail.com**

---

---

# 🇯🇵 日本語ガイド

## 目次

- [概要](#概要)
- [アプリのフロー](#アプリのフロー)
- [主な機能](#主な機能)
- [ユーザーの役割と権限](#ユーザーの役割と権限)
- [使い方 — 技術者（エンジニア）](#使い方--技術者エンジニア)
- [使い方 — 監督者（スーパーバイザー）](#使い方--監督者スーパーバイザー)
- [使い方 — 管理者（アドミン）](#使い方--管理者アドミン)
- [技術スタック](#技術スタック)
- [インストール方法](#インストール方法)
- [ロードマップ](#ロードマップ)

---

## 概要

**Tenken EngiFlow** は、Flutter と Firebase を使用して構築された、役割ベースのエンジニアリングタスク管理アプリケーションです。日本の現場エンジニアリングチームの日常業務（タスク割り当て、出勤管理、問題報告、分析）をデジタル化・効率化するために設計されています。

このアプリは**ログインなしで公開ダッシュボードを閲覧できます**。初回起動時にはシステムを説明するガイドチュートリアルが表示され、右上の小さなログインボタンから認証済みユーザー（管理者、監督者、技術者）がパーソナライズされたダッシュボードにアクセスできます。

---

## アプリのフロー

```
┌───────────────────────────────────────────────────────────────┐
│                       アプリ起動                              │
│                           ↓                                   │
│                  スプラッシュ画面 (/)                          │
│                           ↓                                   │
│                 公開ホーム画面 (/home)                         │
│           ┌─────────────────────────────┐                    │
│           │ • 初回チュートリアルポップアップ│                  │
│           │ • リアルタイム統計ダッシュボード│                 │
│           │ • 緊急タスク一覧              │                   │
│           │ • アクティブチーム表示        │                   │
│           │ • 最新アクティビティ          │                   │
│           │ • [ログイン] ボタン           │                   │
│           └─────────────────────────────┘                    │
│                           ↓                                   │
│                 ログイン画面 (/login)                          │
│          メール＋パスワード → 役割はFirebaseから自動判定       │
│                           ↓                                   │
│           ┌──────────────────────────────┐                   │
│           │    役割ベースダッシュボード    │                   │
│           │    /dashboard                 │                   │
│           ├──────────────────────────────┤                   │
│           │  👷 技術者ダッシュボード      │                   │
│           │  👔 監督者ダッシュボード      │                   │
│           │  🔑 管理者ダッシュボード      │                   │
│           └──────────────────────────────┘                   │
└───────────────────────────────────────────────────────────────┘
```

---

## 主な機能

### 🏠 公開ホーム画面（ログイン不要）

誰でも閲覧できるプロフェッショナルなダッシュボード画面です。

| 要素                   | 説明                                                   |
| ---------------------- | ------------------------------------------------------ |
| **ヒーローバナー**     | 会社名、現在の日時、ライブ表示インジケーター           |
| **統計グリッド**       | アクティブチーム数、緊急タスク数、承認待ち件数、出勤率 |
| **緊急タスク**         | 担当者と期限付きの高優先度タスク                       |
| **アクティブチーム**   | 現在どのチームがどこで作業しているか                   |
| **最新アクティビティ** | タイムスタンプ付きのリアルタイムイベントフィード       |
| **ログイン案内**       | 役割バッジ付きの目立つログインカード                   |

### 🎓 初回起動チュートリアル

初回起動時に4スライドのチュートリアルダイアログが自動表示されます：

| スライド | 内容                                                    |
| -------- | ------------------------------------------------------- |
| 1        | **ようこそ** — システムの目的と概要                     |
| 2        | **技術者向け** — タスク、チェックイン、報告書、問題報告 |
| 3        | **監督者・管理者向け** — チーム管理、承認、分析         |
| 4        | **始め方** — ログイン方法と役割の説明                   |

チュートリアルはいつでも閉じられ、アプリバーの `?` アイコンから再度開けます。

### 🔐 認証とセキュリティ

- 役割ベースのログイン（1つのログイン画面、役割はFirebaseから自動読み込み）
- 無効化されたアカウントはログイン時に即時ブロック
- GoRouterリダイレクトが全認証済みルートを保護
- Firestoreセキュリティルールが役割別データアクセスを強制
- セカンダリFirebaseアプリパターンにより管理者セッションを維持しながら新規ユーザーを作成

---

## ユーザーの役割と権限

| 機能                             | 👷 技術者 | 👔 監督者        | 🔑 管理者 |
| -------------------------------- | --------- | ---------------- | --------- |
| 公開ホーム画面の閲覧             | ✅        | ✅               | ✅        |
| 自分のタスク確認                 | ✅        | ✅               | ✅        |
| チェックイン・アウト             | ✅        | ✅               | ✅        |
| 作業記録の提出                   | ✅        | ✅               | ✅        |
| 問題報告                         | ✅        | ✅               | ✅        |
| チームメンバーの確認             | ❌        | ✅（自部署のみ） | ✅        |
| タスクの割り当て                 | ❌        | ✅               | ✅        |
| 作業記録の承認・却下             | ❌        | ✅               | ✅        |
| タスクの承認・却下               | ❌        | ✅               | ✅        |
| チームの問題管理                 | ❌        | ✅               | ✅        |
| チーム出勤分析の閲覧             | ❌        | ✅（自部署のみ） | ✅        |
| ユーザーアカウントの作成・無効化 | ❌        | ❌               | ✅        |
| 部署の管理                       | ❌        | ❌               | ✅        |
| 全部署データの閲覧               | ❌        | ❌               | ✅        |
| 全社分析の閲覧                   | ❌        | ❌               | ✅        |

---

## 使い方 — 技術者（エンジニア）

技術者は現場の主役です。ログイン後は**5つのタブ**を持つ技術者ダッシュボードに移動します。

### 🏠 ホームタブ

- **出勤カード** — `チェックイン`をタップして出勤打刻。カードに出勤時刻と経過時間が表示されます。退勤時は`チェックアウト`をタップ（勤務時間が自動計算されます）。
- **タスク状況グリッド** — 未開始・進行中・提出済・承認済の4つのカウンター。
- **クイックアクション** — 作業記録と問題報告へのショートカットボタン。
- **本日のタスク** — アクティブなタスクをすぐに確認できます。

### 📋 タスクタブ

- フィルターチップバー：`すべて`・`未開始`・`進行中`・`提出済`・`完了`
- 期限切れタスクには赤バッジが表示されます。
- タスクカードをタップすると**タスク詳細画面**が開きます — 優先度・期限・説明・状況タイムラインを確認できます。
- `作業開始` → `レビュー提出` → 監督者の承認待ち、という流れで進みます。
- 却下された場合は、監督者の理由が表示されます。修正後に`再提出`できます。

### 📊 レポートタブ（作業記録・問題報告）

- **作業記録**サブタブ — `+`ボタンで日次作業を記録（日付・説明・時間・関連タスク）。
- **問題報告**サブタブ — `+`ボタンで問題を報告（タイトル・説明・重要度・カテゴリー）。
- すべての提出内容はFirestoreに保存され、監督者の**承認タブ**に表示されます。

### 👤 プロフィールタブ

- アカウント情報・役割バッジ・部署を確認できます。
- 🇬🇧 英語 と 🇯🇵 日本語 の切り替えができます。
- 確認ダイアログ付きのログアウト。

---

## 使い方 — 監督者（スーパーバイザー）

監督者は部署のチームを統括します。ログイン後は**4つのタブ**を持つ監督者ダッシュボードに移動します。

### 📊 概要タブ

- **統計グリッド** — チーム規模・承認待ち件数・本日の出勤率・未解決問題数。
- **クイックアクション** — 新規タスク割り当て・データ更新。
- **最新アクティビティ** — チームのタスク更新・チェックイン・問題報告のタイムスタンプ付き一覧。

### 👥 チームタブ

- チームメンバーを名前で検索できます。
- 各メンバーカードに部署・役割・クイックアクションボタンが表示されます。
- **タスク割り当て** — ダイアログでタイトル・説明・優先度・期日・担当者を設定。
- **出勤更新** — メンバーの出勤状況を手動で記録。
- メンバーをタップすると**詳細シート**が開き、完全なプロフィールとタスク履歴が確認できます。

### ✅ 承認タブ

バッジカウント付きの3つのサブタブ：

| サブタブ     | 表示内容                     | 操作                                        |
| ------------ | ---------------------------- | ------------------------------------------- |
| **タスク**   | レビュー待ちの提出済みタスク | 承認 / 却下（理由入力）                     |
| **作業記録** | 提出された日次記録           | 承認 / 却下                                 |
| **問題**     | 部署内の未解決問題           | チームメンバーへの割り当て / 解決済みにする |

### 📈 分析タブ

- 日付を選択してその日の出勤状況（出勤・遅刻・欠勤の内訳）を確認。
- 承認待ち件数と問題概要。
- 状況チップ付きの完全な出勤記録一覧。
- 未解決の重大問題がある場合は警告が表示されます。

---

## 使い方 — 管理者（アドミン）

管理者はシステム全体へのフルアクセスを持ちます。ログイン後は**5つのタブ**を持つ管理者ダッシュボードに移動します。

### 📊 概要タブ

- システム全体の統計：総ユーザー数（役割別）・タスク数（状況別）・問題数（状況別）。
- 複数のFirestoreコレクションから取得した最新アクティビティフィード。

### 👥 ユーザー管理タブ

- **検索** — 名前またはメールでユーザーを検索。
- **フィルター** — 役割別：すべて / 技術者 / 監督者 / 管理者。
- **ユーザー追加** — 名前・メール・パスワード・役割・部署を設定。セカンダリFirebaseアプリを使用するため、管理者自身のセッションは維持されます。
- **ユーザー編集** — 名前・部署・役割の変更。
- **無効化** — アカウントを非アクティブに設定。ユーザーは次回ログイン時にブロックされます（データは保持）。

### 📋 タスクタブ（管理者）

- **全部署のタスク**を一覧表示。
- タイトルで検索、状況と優先度でフィルター。
- 各タスクカードに優先度バッジ・状況バッジ・期限切れフラグが表示されます。
- `⋮`メニューからタスクの状況を直接変更できます。

### ⚠️ 問題タブ（管理者）

- **全部署の問題**を一覧表示。
- 検索、状況・重要度でフィルター。
- 迅速な確認のための重要度・状況バッジ。
- `⋮`メニューから問題の状況を更新できます。

### 📈 レポート・分析タブ

- 以下の水平バーチャート（外部ライブラリ不要）：
  - 役割別ユーザー分布
  - タスク状況内訳
  - 問題概要（状況別・重要度別）
  - 部署別パフォーマンス内訳
- エクスポート（PDF/Excel）はフェーズ2で実装予定。

---

## 技術スタック

| レイヤー               | 技術                        | 詳細                                   |
| ---------------------- | --------------------------- | -------------------------------------- |
| **フロントエンド**     | Flutter 3.16+               | iOS・Android・Web対応                  |
| **言語**               | Dart 3.2+                   | Null安全、強型付け                     |
| **UI**                 | Material Design 3           | 日本のミニマリスト美学                 |
| **状態管理**           | Provider 6.1                | 効率的なリアクティブUI                 |
| **ルーティング**       | go_router 12                | ディープリンク対応、リダイレクトガード |
| **バックエンド**       | Firebase Cloud Firestore    | リアルタイムNoSQL、東京リージョン      |
| **認証**               | Firebase Auth 4.15          | メール/パスワード、セッション管理      |
| **通知**               | Firebase Messaging 14       | プッシュ通知インフラ                   |
| **国際化**             | Flutter l10n                | 日本語・英語、実行時切り替え           |
| **ローカルストレージ** | shared_preferences          | チュートリアル表示フラグ、ユーザー設定 |
| **セキュリティ**       | Firestoreセキュリティルール | 役割別データアクセス強制               |

---

## インストール方法

### 前提条件

- Flutter SDK 3.16以上
- Android Studio / VS Code（Flutter拡張機能付き）
- Firebaseアカウントと設定済みプロジェクト

### セットアップ手順

```bash
# 1. リポジトリをクローン
git clone https://github.com/your-org/tenken_engiflow.git
cd tenken_engiflow

# 2. 依存関係をインストール
flutter pub get

# 3. Firebaseの設定ファイルを配置
#    Android: android/app/google-services.json
#    iOS:     ios/Runner/GoogleService-Info.plist

# 4. Firestoreセキュリティルールをデプロイ
firebase deploy --only firestore:rules

# 5. アプリを実行
flutter run
```

### 最初の管理者アカウント

Firebase Consoleで最初の管理者を直接作成します：

1. **Authentication** → ユーザーを追加（メール＋パスワード）
2. **Firestore** → `users`コレクション → ユーザーの`uid`でドキュメントを作成：

```json
{
  "uid": "<firebase-auth-uid>",
  "email": "admin@yourcompany.co.jp",
  "displayName": "管理者",
  "role": "admin",
  "department": "システム管理部",
  "isActive": true,
  "createdAt": "<timestamp>"
}
```

その後、管理者はアプリの**ユーザー管理**タブから他のすべてのユーザーを作成できます。

---

## ロードマップ

### フェーズ 1 — 完了 ✅

- [x] ライブダッシュボード付き公開ホーム画面
- [x] 初回起動チュートリアル（4スライド、バイリンガル）
- [x] 認証リダイレクトガード付きGoRouter
- [x] 技術者ダッシュボード — 全5タブ（ホーム・タスク・タスク詳細・レポート・プロフィール）
- [x] 監督者ダッシュボード — 全4タブ（概要・チーム・承認・分析）
- [x] 管理者ダッシュボード — 全5タブ（概要・ユーザー・タスク・問題・レポート）
- [x] 全画面でリアルFirestoreデータを使用（ハードコードなし）
- [x] 遅刻検知付き出勤チェックイン・アウト
- [x] 重要度レベル付き問題報告
- [x] 作業記録の提出・承認ワークフロー
- [x] タスク割り当て・進捗管理・承認/却下
- [x] 実行時言語切り替え付き日英バイリンガル対応
- [x] Firestoreセキュリティルール（役割ベース）
- [x] プッシュ通知インフラ（FCM）
- [x] ログイン時の無効化アカウント検知

### フェーズ 2 — 予定

- [ ] PDFレポートエクスポート（pdf + printingパッケージ）
- [ ] Excelデータエクスポート
- [ ] 作業記録・問題報告への写真添付
- [ ] オフラインサポート（Firestoreの永続化＋同期インジケーター）
- [ ] 設備IDルックアップ用QRコードスキャン

### フェーズ 3 — 将来

- [ ] AI活用の異常検知・予知保全アラート
- [ ] 報告書承認用電子署名
- [ ] ERP / SAP連携API
- [ ] Web管理ポータル（Flutter Web）
- [ ] スマートウォッチ対応（Apple Watch / Wear OS）

---

## ライセンスとお問い合わせ

これは日本のエンジニアリング会社向けに開発されたプロプライエタリソフトウェアです。すべての権利を保有します。

デモアクセスやビジネスお問い合わせ: **bhnbids@gmail.com**

---

<div align="center">

**Developed with precision for Japanese engineering excellence**  
**日本のエンジニアリング優秀性のために精密に開発**

by **Hossain Billal** (ビラル・ホセイン)

© 2026 Tenken EngiFlow. All rights reserved. 全著作権所有.

---

_Tenken EngiFlow — 現場力を、デジタルへ。_  
_Bringing Field Power into the Digital Age._

</div>
