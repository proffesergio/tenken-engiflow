import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/providers/locale_provider.dart';

const _kSlate = Color(0xFF37474F);

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final locale = context.watch<LocaleProvider>();
    final userData = auth.userData;

    final name = userData?['displayName'] as String? ?? '—';
    final email = userData?['email'] as String? ?? '—';
    final role = userData?['role'] as String? ?? 'engineer';
    final dept = userData?['department'] as String? ?? '—';
    final createdAt = userData?['createdAt'] as String? ?? '';
    final memberSince = _formatDate(createdAt);
    final initials = _initials(name);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      child: Column(
        children: [
          // Avatar + name
          _AvatarSection(initials: initials, name: name, role: role),
          const SizedBox(height: 24),

          // Account info
          _Section(
            title: 'Account',
            children: [
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: email,
              ),
              _InfoTile(
                icon: Icons.apartment_outlined,
                label: 'Department',
                value: dept,
              ),
              _InfoTile(
                icon: Icons.badge_outlined,
                label: 'Role',
                value: '${role[0].toUpperCase()}${role.substring(1)}',
              ),
              _InfoTile(
                icon: Icons.calendar_today_outlined,
                label: 'Member since',
                value: memberSince,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // App settings
          _Section(
            title: 'App Settings',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.language_outlined,
                        size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Language',
                        style: TextStyle(fontSize: 14, color: _kSlate),
                      ),
                    ),
                    _LanguageToggle(locale: locale),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Logout
          _Section(
            children: [
              InkWell(
                onTap: () => _confirmLogout(context, auth),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.logout, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static String _formatDate(String iso) {
    if (iso.isEmpty) return '—';
    try {
      final d = DateTime.parse(iso);
      final months = ['Jan','Feb','Mar','Apr','May','Jun',
                      'Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '—';
    }
  }

  static Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await auth.logout();
    }
  }
}

// ── Avatar section ───────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
  final String initials;
  final String name;
  final String role;

  const _AvatarSection({
    required this.initials,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _kSlate,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _kSlate,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: _kSlate.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '${role[0].toUpperCase()}${role.substring(1)}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _kSlate,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section card ─────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String? title;
  final List<Widget> children;

  const _Section({this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey[500],
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Column(
            children: children
                .asMap()
                .entries
                .map((entry) {
                  final isLast = entry.key == children.length - 1;
                  return Column(
                    children: [
                      entry.value,
                      if (!isLast)
                        const Divider(
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  );
                })
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: _kSlate),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  final LocaleProvider locale;
  const _LanguageToggle({required this.locale});

  @override
  Widget build(BuildContext context) {
    final isJa = locale.locale.languageCode == 'ja';
    return GestureDetector(
      onTap: () => locale.toggleLocale(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _kSlate,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          isJa ? '日本語' : 'English',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
