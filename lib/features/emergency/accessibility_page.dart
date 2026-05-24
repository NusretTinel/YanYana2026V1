import 'package:flutter/material.dart';
import 'package:yanyana_p/audio_description_page.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/features/home/main_page.dart';
import 'package:yanyana_p/core/theme/theme.dart';

import 'package:yanyana_p/live_caption_page.dart';
import 'package:yanyana_p/push_notification_page.dart';
import 'package:yanyana_p/shake_help_page.dart';

import 'package:yanyana_p/features/admin/admin_dashboard_page.dart';
import 'package:yanyana_p/features/home/trusted_contacts_page.dart';

import 'package:yanyana_p/shared/models/support_request.dart';
import 'package:yanyana_p/voice_command_page.dart';

class AccessibilityPage extends StatefulWidget {
  const AccessibilityPage({super.key});

  @override
  State<AccessibilityPage> createState() => _AccessibilityPageState();
}

class _AccessibilityPageState extends State<AccessibilityPage> {
  final _orchestrator = BackendOrchestrator.instance;
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;

    if (mounted) {
      setState(() => _busy = true);
    }

    try {
      await action();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _goToTrustedContacts() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const TrustedContactsPage(),
      ),
    );
  }

  void _showAddTrustedContactDialog({
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _goToTrustedContacts();
            },
            child: const Text('Kişi Ekle'),
          ),
        ],
      ),
    );
  }

  Future<void> _triggerSOS() async {
    final contacts = await _orchestrator.getTrustedContacts();

    if (!mounted) return;

    if (contacts.isEmpty) {
      _showAddTrustedContactDialog(
        title: 'SOS',
        message: 'SOS göndermek için önce güvenilir kişi eklemelisin.',
      );
      return;
    }

    int selectedIndex = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final selectedContact = contacts[selectedIndex];

          return AlertDialog(
            title: const Text('SOS isteği gönderilsin mi?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Acil destek isteğin seçtiğin güvenilir kişiye iletilmek üzere kaydedilecek.',
                ),
                const SizedBox(height: 14),
                ...List.generate(contacts.length, (index) {
                  final contact = contacts[index];

                  return RadioListTile<int>(
                    value: index,
                    groupValue: selectedIndex,
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedIndex = value;
                      });
                    },
                    title: Text(contact.name),
                    subtitle: Text(
                      '${contact.relationship} · ${contact.phoneNumber}',
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _goToTrustedContacts();
                },
                child: const Text('Kişi Ekle'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  _run(() async {
                    await _orchestrator.triggerSOS();

                    if (!mounted) return;

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'SOS isteği ${selectedContact.name} için başarıyla oluşturuldu.',
                        ),
                      ),
                    );
                  });
                },
                child: const Text('Gönder'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startSafeCall() async {
    final contacts = await _orchestrator.getTrustedContacts();

    if (!mounted) return;

    if (contacts.isEmpty) {
      _showAddTrustedContactDialog(
        title: 'Güvenli Arama',
        message: 'Güvenli arama için önce güvenilir kişi eklemelisin.',
      );
      return;
    }

    int selectedIndex = 0;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          final selectedContact = contacts[selectedIndex];

          return AlertDialog(
            title: const Text('Güvenli Arama'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Güvenli arama, güvendiğin bir kişiye hızlıca ulaşman için tasarlanmıştır.',
                ),
                const SizedBox(height: 14),
                ...List.generate(contacts.length, (index) {
                  final contact = contacts[index];

                  return RadioListTile<int>(
                    value: index,
                    groupValue: selectedIndex,
                    onChanged: (value) {
                      if (value == null) return;

                      setDialogState(() {
                        selectedIndex = value;
                      });
                    },
                    title: Text(contact.name),
                    subtitle: Text(
                      '${contact.relationship} · ${contact.phoneNumber}',
                    ),
                  );
                }),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _goToTrustedContacts();
                },
                child: const Text('Kişi Ekle'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);

                  _run(() async {
                    await _orchestrator.startSafeCall(
                      trustedContactId: selectedContact.id,
                    );

                    if (!mounted) return;

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Güvenli arama isteği ${selectedContact.name} için kaydedildi.',
                        ),
                      ),
                    );
                  });
                },
                child: const Text('Başlat'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _quickSupport() async {
    await _run(() async {
      final user = _orchestrator.getCurrentUser();
      if (user == null) return;

      final req = SupportRequest(
        id: 'sr_${DateTime.now().millisecondsSinceEpoch}',
        requesterName: user.name,
        requestType: 'Hızlı Destek',
        description: 'Hızlı destek prototipi: kısa yardım ihtiyacı.',
        status: 'Açık',
        assignedVolunteerName: null,
      );

      final updated = await _orchestrator.createSupportRequest(req);

      if (!mounted) return;

      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            'Hızlı destek talebi oluşturuldu. Gönüllü: ${updated.assignedVolunteerName ?? '-'}',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MainPage.bottomContentPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Erişilebilirlik ve Hızlı Destek',
                style: TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Acil durum, güvenli iletişim ve erişilebilir etkileşim prototipleri.',
                style: TextStyle(
                  color: YanYanaColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),

              _sectionCard(
                title: 'Acil / Güvenli İletişim',
                icon: Icons.shield_rounded,
                color: YanYanaColors.sos,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: _busy ? '...' : 'SOS',
                            icon: Icons.emergency_share_rounded,
                            gradient: sosGradient,
                            onPressed: _busy ? () {} : _triggerSOS,
                            height: 52,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GradientButton(
                            label: _busy ? '...' : 'Güvenli Arama',
                            icon: Icons.call_rounded,
                            gradient: primaryGradient,
                            onPressed: _busy ? () {} : _startSafeCall,
                            height: 52,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: GradientButton(
                        label: _busy ? '...' : 'Hızlı Destek',
                        icon: Icons.volunteer_activism_rounded,
                        gradient: supportGradient,
                        onPressed: _busy ? () {} : _quickSupport,
                        height: 52,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              _sectionCard(
                title: 'Erişilebilirlik Özellikleri',
                icon: Icons.accessibility_new_rounded,
                color: YanYanaColors.secondary,
                child: Column(
                  children: const [
                    _FeatureTile(
                      icon: Icons.menu_book_rounded,
                      title: 'Sesli Betimlemeli Okuma',
                      desc: 'Metni sesli okuma özelliği.',
                      badge: 'Prototype',
                    ),
                    Divider(height: 18, color: YanYanaColors.divider),
                    _FeatureTile(
                      icon: Icons.mic_rounded,
                      title: 'Sesli Komut Sistemi',
                      desc:
                          'Kullanıcı komutlarını algılayan sesli kontrol sistemi.',
                      badge: 'MVP',
                    ),
                    Divider(height: 18, color: YanYanaColors.divider),
                    _FeatureTile(
                      icon: Icons.closed_caption_rounded,
                      title: 'Canlı Altyazı Desteği',
                      desc: 'Konuşmaları gerçek zamanlı altyazıya dönüştürür.',
                      badge: 'Prototype',
                    ),
                    Divider(height: 18, color: YanYanaColors.divider),
                    _FeatureTile(
                      icon: Icons.vibration_rounded,
                      title: 'Titreşimli Geri Bildirim',
                      desc: 'Shake for Help ve hızlı yardım bildirimi.',
                      badge: 'MVP',
                    ),
                    Divider(height: 18, color: YanYanaColors.divider),
                    _FeatureTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'Push Notification Prototype',
                      desc: 'Bildirim gönderimini demo olarak simüle eder.',
                      badge: 'Prototype',
                    ),
                  ],
                ),
              ),

              if (_orchestrator.isAdmin) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.admin_panel_settings_rounded),
                    label: const Text(
                      'Admin Paneli',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: YanYanaColors.primary,
                      side: const BorderSide(color: YanYanaColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: YanYanaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: YanYanaColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final String badge;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.desc,
    required this.badge,
  });

  void _navigate(BuildContext context) {
    Widget? page;

    if (title == 'Sesli Betimlemeli Okuma') {
      page = const AudioDescriptionPage();
    } else if (title == 'Sesli Komut Sistemi') {
      page = const VoiceCommandPage();
    } else if (title == 'Canlı Altyazı Desteği') {
      page = const LiveCaptionPage();
    } else if (title == 'Titreşimli Geri Bildirim') {
      page = const ShakeHelpPage();
    } else if (title == 'Push Notification Prototype') {
      page = const PushNotificationPage();
    }

    if (page != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => page!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color badgeColor;

    switch (badge) {
      case 'MVP':
        badgeColor = YanYanaColors.success;
        break;
      default:
        badgeColor = YanYanaColors.accentBlue;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _navigate(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: badgeColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: YanYanaColors.textDark,
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: badgeColor.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: YanYanaColors.textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: YanYanaColors.textMuted,
                      fontSize: 12.5,
                      height: 1.35,
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
}