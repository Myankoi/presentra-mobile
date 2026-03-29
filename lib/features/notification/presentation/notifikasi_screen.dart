import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/empty_state.dart';
import 'notification_provider.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllRead(),
              child: Text(
                'Tandai Dibaca',
                style: AppTheme.labelBold(context).copyWith(color: AppTheme.primaryBlue, fontSize: 12),
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notifications.isEmpty
              ? Center(
                  child: EmptyState(
                    icon: Icons.notifications_off_outlined,
                    message: 'Belum ada notifikasi',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.loadNotifications(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.screenPadding, AppTheme.cardPadding,
                      AppTheme.screenPadding, AppTheme.sectionGap,
                    ),
                    itemCount: provider.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppTheme.chipGap),
                    itemBuilder: (context, index) {
                      final notif = provider.notifications[index];
                      return _NotificationCard(
                        data: notif,
                        onTap: () {
                          if (!notif.isRead) {
                            provider.markRead(notif.id);
                          }
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem data;
  final VoidCallback onTap;

  const _NotificationCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color iconColor;
    final IconData icon;
    switch (data.iconType) {
      case 'warning':
        icon = Icons.warning_amber_rounded;
        iconColor = AppTheme.warning;
        break;
      case 'clock':
        icon = Icons.access_time_rounded;
        iconColor = AppTheme.accentOrange;
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = AppTheme.primaryBlue;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: data.isRead ? colors.card : AppTheme.primaryBlue.withValues(alpha: context.isDark ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: AppTheme.cardShadow(context),
          border: data.isRead ? null : Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.15)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: AppTheme.itemGap),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data.judul,
                          style: AppTheme.titleMedium(context).copyWith(
                            fontSize: 13,
                            fontWeight: data.isRead ? FontWeight.w500 : FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!data.isRead)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(data.pesan, style: AppTheme.bodySmall(context).copyWith(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(data.relativeTime, style: AppTheme.bodySmall(context).copyWith(fontSize: 10, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
