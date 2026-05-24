import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/models/trusted_contact.dart';

/// Add and manage trusted contacts for safe-call flows.
class TrustedContactsPage extends StatefulWidget {
  const TrustedContactsPage({super.key});

  @override
  State<TrustedContactsPage> createState() => _TrustedContactsPageState();
}

class _TrustedContactsPageState extends State<TrustedContactsPage> {
  final _backend = BackendOrchestrator.instance;
  List<TrustedContact> _contacts = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await _backend.getTrustedContacts();
      if (!mounted) return;
      setState(() {
        _contacts = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _showAddSheet() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: Container(
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: YanYanaShadows.card,
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Güvenilir Kişi Ekle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: YanYanaColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Ad Soyad'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telefon'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: relCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Yakınlık (ör. Anne, Kardeş)',
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'Kaydet',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok != true || !mounted) {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      relCtrl.dispose();
      return;
    }

    try {
      if (nameCtrl.text.trim().isEmpty || phoneCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ad ve telefon zorunludur.')),
        );
        return;
      }
      await _backend.addTrustedContact(
        name: nameCtrl.text,
        phoneNumber: phoneCtrl.text,
        relationship: relCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Güvenilir kişi eklendi.')),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      nameCtrl.dispose();
      phoneCtrl.dispose();
      relCtrl.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        elevation: 0,
        title: const Text(
          'Güvenilir Kişiler',
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        backgroundColor: YanYanaColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Kişi Ekle', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _contacts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.contact_phone_outlined,
                            size: 56,
                            color: YanYanaColors.textLight.withValues(alpha: 0.8),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Henüz güvenilir kişi eklenmedi.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: YanYanaColors.textDark,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Güvenli arama için önce güvenilir bir kişi eklemelisin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: YanYanaColors.textMuted,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 88),
                    itemCount: _contacts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final c = _contacts[i];
                      return ListTile(
                        tileColor: YanYanaColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: const BorderSide(color: YanYanaColors.border),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: YanYanaColors.primaryLight,
                          child: Text(
                            c.name.isNotEmpty ? c.name[0] : '?',
                            style: const TextStyle(
                              color: YanYanaColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        title: Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text('${c.relationship} · ${c.phoneNumber}'),
                      );
                    },
                  ),
      ),
    );
  }
}
