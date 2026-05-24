import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/models/chat_thread.dart';

/// Direct message threads from Firestore (`chat_threads`).
class MessagesModulePage extends StatefulWidget {
  const MessagesModulePage({super.key});

  @override
  State<MessagesModulePage> createState() => _MessagesModulePageState();
}

class _MessagesModulePageState extends State<MessagesModulePage> {
  final _orchestrator = BackendOrchestrator.instance;
  List<ChatThread> _threads = const [];
  bool _loading = true;
  StreamSubscription<List<ChatThread>>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _orchestrator.streamChatThreads().listen(
      (threads) {
        if (!mounted) return;
        setState(() {
          _threads = threads;
          _loading = false;
        });
      },
      onError: (_) {
        if (!mounted) return;
        setState(() => _loading = false);
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _timeLabel(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (now.difference(dt).inDays == 1) return 'Dün';
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return days[dt.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        elevation: 0,
        title: const Text(
          'Mesajlar',
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _threads.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Text(
                        'Henüz mesaj yok. Destek veya mentorluk eşleşmelerinden sonra burada görünecek.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: YanYanaColors.textMuted,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    itemCount: _threads.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final t = _threads[i];
                      return Material(
                        color: YanYanaColors.surface,
                        borderRadius: BorderRadius.circular(22),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${t.peerName}: ${t.lastMessage}',
                                ),
                              ),
                            );
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: YanYanaColors.border),
                              boxShadow: YanYanaShadows.card,
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: YanYanaColors.primaryLight,
                                  child: Text(
                                    t.peerName.isNotEmpty
                                        ? t.peerName[0]
                                        : '?',
                                    style: const TextStyle(
                                      color: YanYanaColors.primary,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              t.peerName,
                                              style: TextStyle(
                                                color: YanYanaColors.textDark,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                                letterSpacing: t.isRead
                                                    ? 0
                                                    : 0.2,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            _timeLabel(t.updatedAt),
                                            style: const TextStyle(
                                              color: YanYanaColors.textMuted,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t.contextLabel,
                                        style: const TextStyle(
                                          color: YanYanaColors.secondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        t.lastMessage,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: YanYanaColors.textMuted,
                                          fontSize: 14,
                                          fontWeight: t.isRead
                                              ? FontWeight.w500
                                              : FontWeight.w800,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        t.statusLabel,
                                        style: const TextStyle(
                                          color: YanYanaColors.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
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
                  ),
      ),
    );
  }
}
