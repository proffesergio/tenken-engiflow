import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tenken_engiflow/presentation/components/language_switcher.dart';

class PublicHomeScreen extends StatefulWidget {
  const PublicHomeScreen({super.key});

  @override
  State<PublicHomeScreen> createState() => _PublicHomeScreenState();
}

class _PublicHomeScreenState extends State<PublicHomeScreen> {
  static const String _tutorialKey = 'tutorial_shown_v1';

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool(_tutorialKey) ?? false;
    if (!shown && mounted) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) _showTutorial(prefs);
    }
  }

  void _showTutorial(SharedPreferences prefs) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TutorialDialog(
        onClose: () => prefs.setBool(_tutorialKey, true),
      ),
    );
  }

  void _showTutorialManually() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) _showTutorial(prefs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildStatsGrid(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader('緊急タスク', 'Urgent Tasks', Icons.warning_amber_rounded, const Color(0xFFC62828)),
                  const SizedBox(height: 10),
                  _buildUrgentTasks(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('アクティブチーム', 'Active Teams', Icons.groups, const Color(0xFF1565C0), liveIndicator: true),
                  const SizedBox(height: 10),
                  _buildActiveTeams(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('最新アクティビティ', 'Recent Activity', Icons.timeline, const Color(0xFF37474F), liveIndicator: true),
                  const SizedBox(height: 10),
                  _buildRecentActivity(),
                  const SizedBox(height: 24),
                  _buildLoginCTA(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF37474F),
      foregroundColor: Colors.white,
      elevation: 2,
      titleSpacing: 16,
      title: const Row(
        children: [
          Icon(Icons.engineering, size: 26, color: Colors.white),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tenken EngiFlow',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Text(
                '現場管理システム',
                style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white70, size: 20),
          tooltip: 'Tutorial / チュートリアル',
          onPressed: _showTutorialManually,
        ),
        const Padding(
          padding: EdgeInsets.only(right: 4),
          child: LanguageSwitcher(showLabel: false),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, left: 4),
          child: OutlinedButton(
            onPressed: () => context.push('/login'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white70, width: 1),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              minimumSize: const Size(0, 34),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('ログイン', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  // ─── Hero ──────────────────────────────────────────────────────────────────

  Widget _buildHeroBanner(BuildContext context) {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dateStr = '${now.year}年${now.month}月${now.day}日';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF37474F), Color(0xFF546E7A), Color(0xFF4A6572)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 8, color: Color(0xFF66BB6A)),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE  $dateStr  $timeStr',
                      style: const TextStyle(fontSize: 11, color: Colors.white, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '現場エンジニア管理',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            'Field Engineering Management Dashboard',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroPill(Icons.factory_outlined, '工場・施設管理', 'Facility'),
              const SizedBox(width: 8),
              _heroPill(Icons.assignment_outlined, 'タスク追跡', 'Tasks'),
              const SizedBox(width: 8),
              _heroPill(Icons.bar_chart, '分析', 'Analytics'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroPill(IconData icon, String ja, String en) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text('$ja / $en', style: const TextStyle(fontSize: 11, color: Colors.white)),
        ],
      ),
    );
  }

  // ─── Stats ─────────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(BuildContext context) {
    return Row(
      children: [
        _statCard('4', 'チーム\nTeams', Icons.groups_rounded, const Color(0xFF1565C0)),
        const SizedBox(width: 10),
        _statCard('2', '緊急\nUrgent', Icons.warning_amber_rounded, const Color(0xFFC62828)),
        const SizedBox(width: 10),
        _statCard('6', '承認待\nPending', Icons.pending_actions, const Color(0xFFE65100)),
        const SizedBox(width: 10),
        _statCard('94%', '出勤率\nAttend.', Icons.people_rounded, const Color(0xFF2E7D32)),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, color: Color(0xFF757575), height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String ja, String en, IconData icon, Color color, {bool liveIndicator = false}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(ja, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(width: 6),
        Text(en, style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
        if (liveIndicator) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 6, color: Color(0xFF66BB6A)),
                SizedBox(width: 4),
                Text('LIVE', style: TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ─── Urgent Tasks ──────────────────────────────────────────────────────────

  Widget _buildUrgentTasks() {
    return Column(
      children: [
        _urgentTaskCard(
          titleJa: '第3工場 消防設備点検',
          titleEn: 'Plant 3 Fire Equipment Inspection',
          assignee: '田中 太郎',
          deadline: '本日 15:00',
          department: '安全管理部',
        ),
        const SizedBox(height: 10),
        _urgentTaskCard(
          titleJa: '設備B-12 緊急修理',
          titleEn: 'Equipment B-12 Emergency Repair',
          assignee: '佐藤 次郎',
          deadline: '本日 17:00',
          department: '設備保全部',
        ),
      ],
    );
  }

  Widget _urgentTaskCard({
    required String titleJa,
    required String titleEn,
    required String assignee,
    required String deadline,
    required String department,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC62828).withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFC62828), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC62828),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('HIGH PRIORITY', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 6),
                Text(titleJa, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
                Text(titleEn, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 13, color: Color(0xFF9E9E9E)),
                    const SizedBox(width: 4),
                    Text(assignee, style: const TextStyle(fontSize: 12, color: Color(0xFF616161))),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, size: 13, color: Color(0xFFC62828)),
                    const SizedBox(width: 4),
                    Text(deadline, style: const TextStyle(fontSize: 12, color: Color(0xFFC62828), fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Active Teams ──────────────────────────────────────────────────────────

  Widget _buildActiveTeams() {
    final teams = [
      {'name': '田中チーム', 'task': '安全点検', 'location': '第1工場', 'members': '3名', 'status': 'IN PROGRESS'},
      {'name': '佐藤チーム', 'task': '設備保守', 'location': '第2工場', 'members': '4名', 'status': 'IN PROGRESS'},
      {'name': '鈴木チーム', 'task': '品質検査', 'location': '第3工場', 'members': '2名', 'status': 'ON SITE'},
      {'name': '山田チーム', 'task': '環境点検', 'location': '外部施設', 'members': '3名', 'status': 'ON SITE'},
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: teams.asMap().entries.map((e) {
          final team = e.value;
          final isLast = e.key == teams.length - 1;
          return _teamRow(
            name: team['name']!,
            task: team['task']!,
            location: team['location']!,
            members: team['members']!,
            status: team['status']!,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _teamRow({
    required String name,
    required String task,
    required String location,
    required String members,
    required String status,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.groups_rounded, color: Color(0xFF1565C0), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF212121))),
                Text('$task · $location', style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
              ),
              const SizedBox(height: 4),
              Text(members, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E))),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Recent Activity ───────────────────────────────────────────────────────

  Widget _buildRecentActivity() {
    final activities = [
      {'time': '13:42', 'message': '田中 太郎 が安全点検を完了しました', 'icon': Icons.check_circle_rounded, 'color': const Color(0xFF2E7D32)},
      {'time': '13:15', 'message': '設備B-3 の問題が報告されました', 'icon': Icons.report_problem, 'color': const Color(0xFFC62828)},
      {'time': '12:55', 'message': '佐藤チーム が設備保守を開始しました', 'icon': Icons.play_circle_filled, 'color': const Color(0xFF1565C0)},
      {'time': '12:30', 'message': '山田 一郎 が出勤しました', 'icon': Icons.login, 'color': const Color(0xFF37474F)},
      {'time': '11:45', 'message': '品質検査タスクが鈴木チームに割り当て', 'icon': Icons.assignment, 'color': const Color(0xFFE65100)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: activities.asMap().entries.map((e) {
          final a = e.value;
          final isLast = e.key == activities.length - 1;
          return _activityItem(
            time: a['time'] as String,
            message: a['message'] as String,
            icon: a['icon'] as IconData,
            color: a['color'] as Color,
            isLast: isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _activityItem({
    required String time,
    required String message,
    required IconData icon,
    required Color color,
    required bool isLast,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E), fontFeatures: [])),
          const SizedBox(width: 10),
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: const TextStyle(fontSize: 12, color: Color(0xFF424242))),
          ),
        ],
      ),
    );
  }

  // ─── Login CTA ─────────────────────────────────────────────────────────────

  Widget _buildLoginCTA(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF37474F), Color(0xFF546E7A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF37474F).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_open_rounded, color: Colors.white, size: 22),
              SizedBox(width: 8),
              Text('ダッシュボードにアクセス', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Access your personalized dashboard',
            style: TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _roleBadge('管理者\nAdmin', const Color(0xFF81C784)),
              const SizedBox(width: 8),
              _roleBadge('監督者\nSupervisor', const Color(0xFFFFB74D)),
              const SizedBox(width: 8),
              _roleBadge('技術者\nEngineer', const Color(0xFF64B5F6)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/login'),
                  icon: const Icon(Icons.login, size: 18),
                  label: const Text('ログイン / Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF37474F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              '初めての方は管理者にアカウント発行を依頼してください\nNew users: contact your administrator for account creation',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Colors.white54, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBadge(String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600, height: 1.4),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Tutorial Dialog
// ═══════════════════════════════════════════════════════════════════════════════

class _TutorialDialog extends StatefulWidget {
  final VoidCallback onClose;

  const _TutorialDialog({required this.onClose});

  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _Slide(
      iconData: Icons.engineering,
      iconColor: Color(0xFF37474F),
      bgColor: Color(0xFFECEFF1),
      titleJa: 'Tenken EngiFlow へようこそ',
      titleEn: 'Welcome to Tenken EngiFlow',
      bodyJa: '日本の現場エンジニアリング会社向けに設計された\n統合タスク管理・報告システムです。',
      bodyEn: 'An integrated task management & reporting system\ndesigned for Japanese field engineering companies.',
      features: [],
    ),
    _Slide(
      iconData: Icons.construction_rounded,
      iconColor: Color(0xFF1565C0),
      bgColor: Color(0xFFE3F2FD),
      titleJa: '技術者（エンジニア）向け',
      titleEn: 'For Engineers',
      bodyJa: '現場での作業を効率的に管理・報告できます。',
      bodyEn: 'Efficiently manage and report on-site work.',
      features: [
        'タスク管理・進捗更新 / Task tracking & status updates',
        '出勤チェックイン・アウト / Check-in & check-out',
        '日次作業報告書の提出 / Daily work report submission',
        '設備問題の即時報告 / Instant issue reporting',
      ],
    ),
    _Slide(
      iconData: Icons.manage_accounts_rounded,
      iconColor: Color(0xFFE65100),
      bgColor: Color(0xFFFFF3E0),
      titleJa: '監督者・管理者向け',
      titleEn: 'For Supervisors & Admins',
      bodyJa: 'チーム全体の管理と分析が一目でわかります。',
      bodyEn: 'Full team oversight, approvals, and analytics at a glance.',
      features: [
        'チームメンバー管理・タスク割り当て / Team & task assignment',
        '作業報告書の承認・却下 / Work report approval',
        'リアルタイム分析ダッシュボード / Real-time analytics dashboard',
        'ユーザー・部署管理（管理者のみ） / User & dept management (Admin)',
      ],
    ),
    _Slide(
      iconData: Icons.rocket_launch_rounded,
      iconColor: Color(0xFF2E7D32),
      bgColor: Color(0xFFE8F5E9),
      titleJa: '始め方',
      titleEn: 'Getting Started',
      bodyJa: '画面右上の「ログイン」ボタンから\nアカウントにサインインしてください。',
      bodyEn: 'Tap the "ログイン / Login" button at the top right\nto sign in with your account credentials.',
      features: [
        '管理者：全機能へのフルアクセス / Admin: full system access',
        '監督者：チーム管理・承認 / Supervisor: team management & approvals',
        '技術者：個人タスク・報告 / Engineer: personal tasks & reports',
        '新規ユーザーは管理者へお問い合わせ / New users: contact your admin',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _close() {
    widget.onClose();
    Navigator.of(context).pop();
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SizedBox(
        width: screenW,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  const Icon(Icons.engineering, size: 18, color: Color(0xFF37474F)),
                  const SizedBox(width: 6),
                  const Text(
                    'Tenken EngiFlow',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF37474F)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    tooltip: '閉じる / Close',
                    onPressed: _close,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ),
            ),

            // Page content
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (ctx, i) => _buildSlide(_slides[i]),
              ),
            ),

            // Dot indicators
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFF37474F) : const Color(0xFFBDBDBD),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _close,
                    child: const Text('スキップ / Skip', style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13)),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF37474F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1 ? 'はじめる / Start' : '次へ / Next  →',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_Slide slide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: slide.bgColor,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(slide.iconData, size: 40, color: slide.iconColor),
          ),
          const SizedBox(height: 18),
          Text(
            slide.titleJa,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF212121)),
          ),
          const SizedBox(height: 4),
          Text(
            slide.titleEn,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
          const SizedBox(height: 14),
          Text(
            slide.bodyJa,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Color(0xFF424242), height: 1.5),
          ),
          if (slide.bodyEn.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              slide.bodyEn,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E), height: 1.5),
            ),
          ],
          if (slide.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...slide.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: slide.iconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(f, style: const TextStyle(fontSize: 12, color: Color(0xFF424242), height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Simple data class for tutorial slides
class _Slide {
  final IconData iconData;
  final Color iconColor;
  final Color bgColor;
  final String titleJa;
  final String titleEn;
  final String bodyJa;
  final String bodyEn;
  final List<String> features;

  const _Slide({
    required this.iconData,
    required this.iconColor,
    required this.bgColor,
    required this.titleJa,
    required this.titleEn,
    required this.bodyJa,
    required this.bodyEn,
    required this.features,
  });
}
