import 'package:flutter/material.dart';
import 'package:awala_mobile/core/theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'new_listing',
      'title': 'New listing matches your alert!',
      'body': 'A new self-contained room in Molyko is available for 22,000 FCFA/mo',
      'time': '2 min ago',
      'read': false,
      'icon': Icons.home_rounded,
      'color': AppColors.success,
    },
    {
      'type': 'price_change',
      'title': 'Price dropped!',
      'body': 'The studio in Bonduma you saved has dropped from 65,000 to 55,000 FCFA',
      'time': '1 hr ago',
      'read': false,
      'icon': Icons.trending_down_rounded,
      'color': AppColors.cta,
    },
    {
      'type': 'general',
      'title': 'Welcome to Awala RealEstate!',
      'body': 'Set up your search alerts to get notified when new properties match your needs.',
      'time': '1 day ago',
      'read': true,
      'icon': Icons.waving_hand_rounded,
      'color': AppColors.accent,
    },
  ];

  final List<Map<String, dynamic>> _alerts = [
    {
      'query': 'Room in Molyko',
      'filters': 'Max 30,000 FCFA · Any furnishing',
      'active': true,
    },
    {
      'query': 'Studio',
      'filters': 'Max 70,000 FCFA · Furnished',
      'active': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n['read']).length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$unread',
                    style: const TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() {
              for (var n in _notifications) {
                n['read'] = true;
              }
            }),
            child: const Text('Mark all read',
                style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.cta,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Notifications'),
            Tab(text: 'Search Alerts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ─── Notifications tab ─────────────────────────────────
          _notifications.isEmpty
              ? _EmptyState(
                  icon: Icons.notifications_off_outlined,
                  message: 'No notifications yet',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final n = _notifications[i];
                    return _NotifCard(
                      notif: n,
                      onTap: () => setState(() => n['read'] = true),
                      onDismiss: () => setState(() => _notifications.removeAt(i)),
                    );
                  },
                ),

          // ─── Alerts tab ───────────────────────────────────────
          Column(
            children: [
              Expanded(
                child: _alerts.isEmpty
                    ? _EmptyState(
                        icon: Icons.notifications_active_outlined,
                        message: 'No search alerts set up yet',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _alerts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _AlertCard(
                          alert: _alerts[i],
                          onToggle: (v) =>
                              setState(() => _alerts[i]['active'] = v),
                          onDelete: () =>
                              setState(() => _alerts.removeAt(i)),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddAlertSheet(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create Search Alert'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddAlertSheet() {
    final queryCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24, right: 24, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('New Search Alert',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: queryCtrl,
              decoration: const InputDecoration(
                labelText: 'Search query (e.g. "Studio in Molyko")',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.info_outline, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'You\'ll be notified when new listings match this search.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (queryCtrl.text.isNotEmpty) {
                    setState(() => _alerts.add({
                          'query': queryCtrl.text,
                          'filters': 'All filters',
                          'active': true,
                        }));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Alert'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> notif;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  const _NotifCard(
      {required this.notif, required this.onTap, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final isRead = notif['read'] as bool;
    return Dismissible(
      key: Key(notif['title']),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
            color: AppColors.error, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isRead ? Colors.white : AppColors.accent.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isRead ? AppColors.border : AppColors.accent.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: (notif['color'] as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(notif['icon'] as IconData,
                    color: notif['color'] as Color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(notif['title'],
                              style: TextStyle(
                                  fontWeight: isRead
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                  fontSize: 14)),
                        ),
                        if (!isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif['body'],
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4)),
                    const SizedBox(height: 6),
                    Text(notif['time'],
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> alert;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  const _AlertCard(
      {required this.alert, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_active_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert['query'],
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(alert['filters'],
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Switch(
              value: alert['active'],
              onChanged: onToggle,
              activeThumbColor: AppColors.primary,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
              onPressed: onDelete,
            ),
          ],
        ),
      );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppColors.border),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      );
}
