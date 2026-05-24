import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/models/notification_model.dart';

/// In-app notifications loaded via [BackendOrchestrator].
class NotificationsModulePage extends StatefulWidget {
  const NotificationsModulePage({super.key});

  @override
  State<NotificationsModulePage> createState() => _NotificationsModulePageState();
}

class _NotificationsModulePageState extends State<NotificationsModulePage> {
  final _items = <NotificationModel>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    BackendOrchestrator.instance.notificationService.markAllAsRead();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await BackendOrchestrator.instance.getNotifications();
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(list);
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _toggleRead(NotificationModel n) {
    BackendOrchestrator.instance.notificationService.markRead(n.id);
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk';
    if (diff.inHours < 24) return '${diff.inHours} sa';
    if (diff.inDays < 7) return '${diff.inDays} gün';
    return '${t.day}.${t.month}.${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        elevation: 0,
        title: const Text(
          'Bildirimler',
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<NotificationModel>>(
          stream: BackendOrchestrator.instance.streamNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Bildirimler yüklenemedi.'));
            }
            final items = snapshot.data ?? [];

            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 56,
                    color: YanYanaColors.textLight,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Henüz bildirimin yok.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: YanYanaColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Yeni destek, topluluk veya sistem bildirimleri burada görünecek.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = items[i];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _toggleRead(n),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: n.isRead
                            ? YanYanaColors.surface
                            : YanYanaColors.primaryLight.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: n.isRead
                              ? YanYanaColors.border
                              : YanYanaColors.primary,
                        ),
                        boxShadow: YanYanaShadows.soft,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.notifications_rounded,
                            color: YanYanaColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  n.title,
                                  style: const TextStyle(
                                    color: YanYanaColors.textDark,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  n.message,
                                  style: const TextStyle(
                                    color: YanYanaColors.textMuted,
                                    fontSize: 14,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatTime(n.createdAt),
                                  style: const TextStyle(
                                    color: YanYanaColors.textLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
