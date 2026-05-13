# Tenken EngiFlow — システム紹介資料
# Tenken EngiFlow — System Presentation

> **現場エンジニアリング管理システム**  
> Field Engineering Management System  
> Version 1.0 | 2026年5月

---

## 目次 / Table of Contents

1. [システム概要 / System Overview](#1-システム概要--system-overview)
2. [対象ユーザーと役割 / Target Users & Roles](#2-対象ユーザーと役割--target-users--roles)
3. [主な機能 / Key Features](#3-主な機能--key-features)
4. [画面構成 / Screen Structure](#4-画面構成--screen-structure)
5. [技術スタック / Technology Stack](#5-技術スタック--technology-stack)
6. [セキュリティ / Security](#6-セキュリティ--security)
7. [導入のメリット / Business Benefits](#7-導入のメリット--business-benefits)
8. [今後の開発計画 / Roadmap](#8-今後の開発計画--roadmap)

---

## 1. システム概要 / System Overview

**Tenken EngiFlow** は、日本の現場エンジニアリング企業向けに設計された、モバイル対応の統合タスク管理・報告システムです。

**Tenken EngiFlow** is a mobile-first integrated task management and reporting system designed specifically for Japanese field engineering companies.

### システムの目的 / System Purpose

| 課題 / Problem | 解決策 / Solution |
|---|---|
| 紙ベースの作業報告書の非効率 / Inefficient paper-based reports | デジタル報告書のリアルタイム提出 / Real-time digital report submission |
| 現場状況の把握困難 / Difficulty tracking field status | ライブダッシュボードで即時確認 / Instant visibility via live dashboard |
| 承認プロセスの遅延 / Slow approval workflows | ワンタップ承認・却下 / One-tap approval and rejection |
| 問題発生時の連絡遅延 / Delayed issue communication | 即時問題報告・優先度設定 / Instant issue reporting with priority |
| 出勤管理の手動処理 / Manual attendance management | GPS不要のデジタルチェックイン / Digital check-in without GPS dependency |

---

## 2. 対象ユーザーと役割 / Target Users & Roles

システムは **3つの役割** を持つユーザーをサポートします。  
The system supports users with **3 distinct roles**.

---

### 👷 技術者（エンジニア） / Engineer

**誰が使うか / Who:** 現場で作業する技術者・点検員  
Field technicians, inspectors, and on-site workers

**できること / Capabilities:**

- ✅ 自分に割り当てられたタスクの確認・進捗更新  
  View assigned tasks and update progress status
- ✅ 出勤チェックイン・チェックアウト（遅刻自動検知）  
  Daily check-in / check-out with automatic late detection
- ✅ 日次作業報告書の作成・提出  
  Create and submit daily work entry reports
- ✅ 設備問題・安全問題の即時報告（重要度設定）  
  Instant issue reporting with severity classification
- ✅ タスクの詳細確認・却下理由の確認  
  View task details and rejection reasons

**アクセス制限 / Restrictions:**
- 自分のデータのみ閲覧・編集可能  
  Can only view and edit own data
- 他のメンバーの情報は閲覧不可  
  Cannot access other members' data

---

### 👔 監督者（スーパーバイザー） / Supervisor

**誰が使うか / Who:** チームリーダー・現場監督  
Team leaders and on-site supervisors

**できること / Capabilities:**

- ✅ 担当チームメンバー全員の管理  
  Manage all team members in their department
- ✅ タスクの割り当て・期限設定・優先度設定  
  Assign tasks with deadlines and priority levels
- ✅ 作業報告書・タスクの承認または却下  
  Approve or reject work reports and completed tasks
- ✅ チームの問題報告を担当者にアサイン・解決処理  
  Assign and resolve team issues
- ✅ リアルタイム出勤状況・勤務時間の確認  
  Real-time attendance tracking and work hours
- ✅ チーム分析レポート（出勤率・タスク完了率）  
  Team analytics (attendance rate, task completion rate)

**アクセス制限 / Restrictions:**
- 自分の部署のデータのみアクセス可能  
  Access limited to own department data

---

### 🔑 管理者（アドミン） / Admin

**誰が使うか / Who:** システム管理者・HR担当・経営者  
System administrators, HR managers, and executives

**できること / Capabilities:**

- ✅ **全ての監督者・技術者の機能**  
  All supervisor and engineer capabilities
- ✅ ユーザーアカウントの作成・管理・無効化  
  Create, manage, and deactivate user accounts
- ✅ 部署の作成・管理  
  Create and manage departments
- ✅ 全部署のタスク・問題を横断管理  
  Cross-department task and issue management
- ✅ システム全体の分析ダッシュボード  
  System-wide analytics dashboard
- ✅ ユーザー活動の監視・検索・フィルタリング  
  Monitor, search, and filter all user activity

---

## 3. 主な機能 / Key Features

### 3.1 公開ホーム画面 / Public Home Screen

ログイン不要で誰でも閲覧できるライブダッシュボード。  
A live dashboard visible to anyone without login.

```
┌──────────────────────────────────────────────────┐
│  🔧 Tenken EngiFlow    現場管理システム   [ログイン]│
├──────────────────────────────────────────────────┤
│  LIVE  2026年5月13日  09:30                       │
│                                                  │
│  現場エンジニア管理                                │
│  Field Engineering Management Dashboard          │
│                                                  │
│  [工場・施設管理] [タスク追跡] [分析]              │
├──────────────────────────────────────────────────┤
│  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐     │
│  │   4    │ │   2    │ │   6    │ │  94%   │     │
│  │ チーム │ │  緊急  │ │ 承認待 │ │ 出勤率 │     │
│  └────────┘ └────────┘ └────────┘ └────────┘     │
├──────────────────────────────────────────────────┤
│  ⚠️ 緊急タスク / Urgent Tasks                    │
│  ● HIGH  第3工場 消防設備点検 → 本日 15:00         │
│  ● HIGH  設備B-12 緊急修理   → 本日 17:00         │
├──────────────────────────────────────────────────┤
│  👥 アクティブチーム (LIVE)                       │
│  田中チーム — 安全点検 — 第1工場 — IN PROGRESS    │
│  佐藤チーム — 設備保守 — 第2工場 — IN PROGRESS    │
│  鈴木チーム — 品質検査 — 第3工場 — ON SITE        │
├──────────────────────────────────────────────────┤
│  📋 最新アクティビティ (LIVE)                     │
│  13:42  ✅  田中 太郎 が安全点検を完了             │
│  13:15  ⚠️  設備B-3 の問題が報告されました         │
│  12:55  ▶️  佐藤チーム が作業を開始               │
└──────────────────────────────────────────────────┘
```

### 3.2 初回起動チュートリアル / First-Launch Tutorial

初回起動時に4スライドのチュートリアルが自動表示されます。  
A 4-slide tutorial appears automatically on first launch.

```
┌─────────────────────────────────────┐
│  Tenken EngiFlow              [×]  │
│                                     │
│         [🔧 アイコン]               │
│                                     │
│   Tenken EngiFlow へようこそ         │
│   Welcome to Tenken EngiFlow        │
│                                     │
│  日本の現場エンジニアリング会社向けに  │
│  設計された統合管理システムです。     │
│                                     │
│          ●  ○  ○  ○               │
│                                     │
│  [スキップ]          [次へ / Next →] │
└─────────────────────────────────────┘
```

スライド構成 / Slide Contents:
1. **ようこそ / Welcome** — システム紹介
2. **技術者向け / For Engineers** — タスク・報告機能
3. **監督者・管理者向け / For Supervisors & Admins** — 管理・承認機能
4. **始め方 / Getting Started** — ログイン案内

---

### 3.3 技術者ダッシュボード / Engineer Dashboard

```
┌──────────────────────────────┐
│  Engineer Dashboard  [LOGOUT]│
├──────────────────────────────┤
│  🏠 Home Tab                 │
│  ──────────────────────────  │
│  おはようございます、田中さん  │
│                              │
│  [出勤チェックイン] 09:00     │
│                              │
│  タスク状況:                  │
│  未開始3 進行中2 提出済1 完了5 │
│                              │
│  緊急タスク:                  │
│  ● 消防設備点検 (HIGH)        │
└──────────────────────────────┘

Bottom Nav: [🏠 Home] [📋 Tasks] [📊 Reports] [👤 Profile]
```

### 3.4 監督者ダッシュボード / Supervisor Dashboard

```
┌──────────────────────────────┐
│  Supervisor Dashboard        │
├──────────────────────────────┤
│  チーム: 12名 | 出勤: 11名    │
│  承認待ちタスク: 6件           │
│  未解決問題: 2件               │
│                              │
│  [タスク割り当て] [更新]       │
└──────────────────────────────┘

Bottom Nav: [📊 Overview] [👥 Team] [✅ Approvals] [📈 Analytics]
```

### 3.5 管理者ダッシュボード / Admin Dashboard

```
┌──────────────────────────────┐
│  Admin Dashboard             │
├──────────────────────────────┤
│  総ユーザー: 45名             │
│  アクティブチーム: 8          │
│  未解決問題: 3件 (重大: 1件)  │
│                              │
│  タスク状況分析 ██████░░ 75%  │
│  問題解決率   ████████░ 88%  │
└──────────────────────────────┘

Bottom Nav: [📊 Overview] [👥 Users] [📋 Tasks] [⚠️ Issues] [📈 Reports]
```

---

## 4. 画面構成 / Screen Structure

```
App起動
  │
  ▼
スプラッシュ画面
  │
  ├── 未ログイン ──→ 公開ホーム画面 ──→ [ログインボタン] ──→ ログイン画面
  │                      │                                        │
  │               [初回チュートリアル]                        ログイン成功
  │                                                               │
  └── ログイン済み ─────────────────────────────────────────▼
                                                        役割ベースダッシュボード
                                                          ├── 技術者ダッシュボード
                                                          ├── 監督者ダッシュボード
                                                          └── 管理者ダッシュボード
```

---

## 5. 技術スタック / Technology Stack

| 項目 / Item | 技術 / Technology | 詳細 / Details |
|---|---|---|
| フロントエンド / Frontend | **Flutter** | iOS・Android・Web対応 |
| バックエンド / Backend | **Firebase** | Google Cloud管理 |
| 認証 / Authentication | **Firebase Auth** | メール/パスワード認証 |
| データベース / Database | **Cloud Firestore** | リアルタイムNoSQL |
| 状態管理 / State Management | **Provider** | 効率的なUI更新 |
| ルーティング / Routing | **go_router** | ディープリンク対応 |
| 通知 / Notifications | **Firebase Messaging** | プッシュ通知 |
| 国際化 / Localization | **Flutter l10n** | 日本語・英語対応 |
| ローカルストレージ / Local Storage | **shared_preferences** | 設定・チュートリアル状態 |

### クラウドインフラ / Cloud Infrastructure

```
[モバイルアプリ] ←→ [Firebase Auth] ←→ [Cloud Firestore]
                 ←→ [Firebase Messaging]
                 ←→ [Firebase App Check] (セキュリティ)
```

---

## 6. セキュリティ / Security

### Firestoreセキュリティルール / Firestore Security Rules

役割に基づいたデータアクセス制御を実装しています。  
Role-based data access control is implemented.

| データ / Data | 技術者 / Engineer | 監督者 / Supervisor | 管理者 / Admin |
|---|---|---|---|
| 自分のタスク / Own tasks | 読み取り・更新 / R+W | 読み取り / R | フル / Full |
| 自分の出勤 / Own attendance | 読み取り・更新 / R+W | 読み取り / R | フル / Full |
| チームのタスク / Team tasks | ❌ | 読み取り・更新 / R+W | フル / Full |
| ユーザー管理 / User management | ❌ | ❌ | フル / Full |
| 分析データ / Analytics | ❌ | 自部署 / Own dept | 全社 / All |

### アカウントセキュリティ / Account Security

- **無効化されたアカウント**はログイン時に即時ブロック  
  Deactivated accounts are blocked immediately on login attempt
- **セカンダリFirebaseアプリ**パターンにより管理者が新規ユーザー作成時も自身のセッションが維持  
  Secondary Firebase app pattern keeps admin session intact when creating users
- **パスワード**はFirebase Authが管理（アプリ内に保存なし）  
  Passwords managed by Firebase Auth (never stored in the app)

---

## 7. 導入のメリット / Business Benefits

### 定量的メリット / Quantitative Benefits

| 指標 / Metric | 導入前 / Before | 導入後 / After | 改善 / Improvement |
|---|---|---|---|
| 報告書提出時間 / Report submission time | 30分以上 / 30+ min | 3〜5分 / 3-5 min | **85%削減 / 85% reduction** |
| 承認処理時間 / Approval turnaround | 1〜2日 / 1-2 days | 当日中 / Same day | **大幅短縮 / Significant reduction** |
| 問題対応時間 / Issue response time | 数時間 / Hours | リアルタイム / Real-time | **即時対応 / Immediate** |
| 出勤記録の正確性 / Attendance accuracy | 手動・誤記リスク / Manual, error-prone | 自動・正確 / Automatic, accurate | **100%精度 / 100% accuracy** |

### 定性的メリット / Qualitative Benefits

- 📱 **ペーパーレス化** — 用紙・印刷コストの削減 / Paperless — reduced paper and printing costs
- 🌐 **日英バイリンガル対応** — 外国人スタッフも利用可能 / Bilingual support — foreign staff can use the app
- 📊 **データドリブン経営** — リアルタイム分析で意思決定をサポート / Data-driven management with real-time analytics
- 🔒 **コンプライアンス** — デジタル記録で監査対応 / Compliance-ready digital records for auditing
- 📱 **モバイルファースト** — 現場でスマートフォンから即利用 / Mobile-first — use from the field on any smartphone

---

## 8. 今後の開発計画 / Roadmap

### フェーズ 1（現在完成）/ Phase 1 (Completed)

- [x] 公開ホーム画面 + チュートリアル / Public home screen + tutorial
- [x] 役割ベース認証（技術者・監督者・管理者） / Role-based auth (engineer, supervisor, admin)
- [x] 技術者ダッシュボード（全タブ） / Engineer dashboard (all tabs)
- [x] 監督者ダッシュボード（全タブ） / Supervisor dashboard (all tabs)
- [x] 管理者ダッシュボード（全タブ） / Admin dashboard (all tabs)
- [x] リアルタイムFirestoreデータ / Real-time Firestore data
- [x] 日英バイリンガル対応 / Japanese/English bilingual support
- [x] Firestoreセキュリティルール / Firestore security rules
- [x] プッシュ通知インフラ / Push notification infrastructure

### フェーズ 2（予定）/ Phase 2 (Planned)

- [ ] オフライン対応（現場の電波が弱い環境でも利用可能） / Offline support for low-connectivity field environments
- [ ] PDFレポート出力 / PDF report export
- [ ] Excelデータエクスポート / Excel data export
- [ ] 写真添付（作業報告書・問題報告） / Photo attachments for reports and issues
- [ ] QRコードを使った設備管理 / QR code-based equipment management

### フェーズ 3（将来）/ Phase 3 (Future)

- [ ] AI による異常検知・予測保全 / AI-powered anomaly detection and predictive maintenance
- [ ] 電子署名対応 / Electronic signature support
- [ ] 基幹システム（ERP）連携 / ERP system integration
- [ ] Web管理画面 / Web admin portal
- [ ] Apple Watch・スマートウォッチ対応 / Apple Watch / smartwatch support

---

## デモ環境について / About the Demo

このデモでは、公開ホーム画面にリアルなサンプルデータを表示しています。  
The demo shows realistic sample data on the public home screen.

**デモログイン情報 / Demo Login:**  
管理者アカウントをご用意します。デモ実施時に別途ご案内いたします。  
An admin account will be prepared for the demo. Details will be provided separately.

**対応デバイス / Supported Devices:**
- iOS 13以上 / iOS 13 and above
- Android 6.0以上 / Android 6.0 and above
- Web ブラウザ（Chrome推奨）/ Web browser (Chrome recommended)

---

## お問い合わせ / Contact

本システムに関するご質問・ご相談はお気軽にお申し付けください。  
Please feel free to reach out with any questions or inquiries about this system.

---

*Tenken EngiFlow — 現場力を、デジタルへ。*  
*Tenken EngiFlow — Bringing Field Power into the Digital Age.*

---

> このドキュメントは2026年5月時点の情報に基づいています。  
> This document is based on information as of May 2026.
