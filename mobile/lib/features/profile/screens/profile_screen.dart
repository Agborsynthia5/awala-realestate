import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:awala_mobile/core/theme/app_theme.dart';
import 'package:awala_mobile/core/router/app_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userName = user['name'] ?? 'User';
    final userEmail = user['email'] ?? 'user@example.com';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Header ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            title: const Text('Profile'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: const Icon(Icons.person_rounded,
                              size: 52, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.cta,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.edit_rounded,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(userName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(userEmail,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13)),
                  ],
                ),
              ),
            ),
          ),

          // ─── Sections ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Personal Information
                  _Section(title: 'Personal Information', items: [
                    _Tile(icon: Icons.person_outline, label: 'Full Name',
                        value: userName, onTap: () {}),
                    _Tile(icon: Icons.email_outlined, label: 'Email',
                        value: userEmail, onTap: () {}),
                    _Tile(icon: Icons.phone_outlined, label: 'Phone',
                        value: '+237 677 123 456', onTap: () {}),
                    _Tile(icon: Icons.language_rounded, label: 'Language',
                        value: 'English', onTap: () {}),
                  ]),
                  const SizedBox(height: 16),

                  // Activity
                  _Section(title: 'My Activity', items: [
                    _Tile(
                      icon: Icons.bookmark_rounded,
                      label: 'Saved Properties',
                      value: '5 saved',
                      onTap: () {},
                    ),
                    _Tile(
                      icon: Icons.notifications_active_rounded,
                      label: 'Search Alerts',
                      value: '2 active',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Notifications
                  _Section(title: 'Notifications', items: [
                    _SwitchTile(
                        icon: Icons.mail_outline_rounded,
                        label: 'Email Notifications',
                        value: true,
                        onChanged: (_) {}),
                    _SwitchTile(
                        icon: Icons.notifications_rounded,
                        label: 'Push Notifications',
                        value: true,
                        onChanged: (_) {}),
                    _SwitchTile(
                        icon: Icons.sms_rounded,
                        label: 'SMS Notifications',
                        value: false,
                        onChanged: (_) {}),
                  ]),
                  const SizedBox(height: 16),

                  // Support
                  _Section(title: 'Support', items: [
                    _Tile(icon: Icons.help_outline_rounded,
                        label: 'Help & FAQ', onTap: () {}),
                    _Tile(icon: Icons.privacy_tip_outlined,
                        label: 'Privacy Policy', onTap: () {}),
                    _Tile(icon: Icons.description_outlined,
                        label: 'Terms of Service', onTap: () {}),
                    _Tile(
                      icon: Icons.flag_outlined,
                      label: 'Report a Problem',
                      onTap: () {},
                      iconColor: AppColors.error,
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLogout(context),
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.error),
                      label: const Text('Sign Out',
                          style: TextStyle(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text('Awala RealEstate v1.0.0',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary, fontSize: 13)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  final Color iconColor;

  const _Tile({
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: value != null
          ? Text(value!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class _SwitchTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onChanged});
  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool _val;
  @override
  void initState() { super.initState(); _val = widget.value; }

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(widget.icon, color: AppColors.primary, size: 18),
        ),
        title: Text(widget.label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: _val,
          onChanged: (v) { setState(() => _val = v); widget.onChanged(v); },
          activeThumbColor: AppColors.primary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      );
}
