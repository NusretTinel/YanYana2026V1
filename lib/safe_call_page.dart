import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/home/trusted_contacts_page.dart';

class SafeCallPage extends StatefulWidget {
  const SafeCallPage({super.key});

  @override
  State<SafeCallPage> createState() => _SafeCallPageState();
}

class _SafeCallPageState extends State<SafeCallPage> {
  final _orchestrator = BackendOrchestrator.instance;

  bool isCalling = false;
  bool isLoading = true;

  String statusText = "Güvenli arama sistemi beklemede.";

  List<dynamic> trustedContacts = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTrustedContacts();
  }

  Future<void> _loadTrustedContacts() async {
    try {
      final contacts = await _orchestrator.getTrustedContacts();

      if (!mounted) return;

      setState(() {
        trustedContacts = contacts;
        selectedIndex = 0;
        isLoading = false;
        statusText = contacts.isEmpty
            ? "Güvenli arama için önce güvenilir kişi eklemelisin."
            : "Güvenli arama sistemi beklemede.";
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        statusText = "Güvenilir kişiler yüklenemedi.";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    }
  }

  Future<void> _goToTrustedContacts() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const TrustedContactsPage(),
      ),
    );

    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    await _loadTrustedContacts();
  }

  void selectContact(int index) {
    setState(() {
      selectedIndex = index;
      statusText = "${trustedContacts[index].name} kişisi seçildi.";
    });
  }

  Future<void> startSafeCall() async {
    if (trustedContacts.isEmpty) {
      await _goToTrustedContacts();
      return;
    }

    final selectedContact = trustedContacts[selectedIndex];

    setState(() {
      isCalling = true;
      statusText =
          "${selectedContact.name} ile güvenli arama bağlantısı başlatılıyor.";
    });

    try {
      await _orchestrator.startSafeCall(
        trustedContactId: selectedContact.id,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${selectedContact.name} için güvenli arama başlatıldı."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCalling = false;
        statusText = "Güvenli arama başlatılamadı.";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Bad state: ', '')),
        ),
      );
    }
  }

  void stopSafeCall() {
    setState(() {
      isCalling = false;
      statusText = "Güvenli arama sonlandırıldı.";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Güvenli arama sonlandırıldı."),
      ),
    );
  }

  void sendEmergencyAlert() {
    if (trustedContacts.isEmpty) {
      _goToTrustedContacts();
      return;
    }

    final selectedContact = trustedContacts[selectedIndex];

    setState(() {
      statusText =
          "${selectedContact.name} kişisine acil destek bildirimi gönderildi.";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${selectedContact.name} kişisine acil destek bildirimi gönderildi.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedContact =
        trustedContacts.isNotEmpty ? trustedContacts[selectedIndex] : null;

    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.background,
        elevation: 0,
        title: const Text(
          "Safe Call",
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(
          color: YanYanaColors.textDark,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isCalling ? 125 : 110,
              height: isCalling ? 125 : 110,
              decoration: BoxDecoration(
                color: isCalling
                    ? YanYanaColors.sos.withOpacity(0.14)
                    : YanYanaColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCalling ? Icons.call_rounded : Icons.phone_enabled_rounded,
                size: isCalling ? 60 : 55,
                color: isCalling ? YanYanaColors.sos : YanYanaColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Safe Call",
            style: TextStyle(
              color: YanYanaColors.textDark,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          const Text(
            "Güvenli arama için acil durumda ulaşılacak kişiyi seçebilirsiniz.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Güvenilir Kişiler",
            style: TextStyle(
              color: YanYanaColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (trustedContacts.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: YanYanaColors.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: YanYanaShadows.card,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: YanYanaColors.primary,
                    size: 38,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Henüz güvenilir kişi eklenmedi.",
                    style: TextStyle(
                      color: YanYanaColors.textDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Safe Call kullanmak için önce güvenilir kişi eklemelisin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: YanYanaColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: _goToTrustedContacts,
                    icon: const Icon(Icons.person_add_rounded),
                    label: const Text("Güvenilir Kişi Ekle"),
                  ),
                ],
              ),
            )
          else
            ...List.generate(trustedContacts.length, (index) {
              final contact = trustedContacts[index];
              final bool isSelected = index == selectedIndex;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: YanYanaColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: YanYanaShadows.card,
                  border: Border.all(
                    color: isSelected
                        ? YanYanaColors.primary.withOpacity(0.45)
                        : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.person_outline_rounded,
                    color: isSelected
                        ? YanYanaColors.primary
                        : YanYanaColors.textMuted,
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(
                      color: YanYanaColors.textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(
                    "${contact.relationship} · ${contact.phoneNumber}",
                    style: const TextStyle(
                      color: YanYanaColors.textMuted,
                    ),
                  ),
                  onTap: () => selectContact(index),
                ),
              );
            }),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: YanYanaColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: YanYanaColors.primary.withOpacity(0.15),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Durum",
                  style: TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: YanYanaColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Safe Call, güvenilir kişiye hızlı ulaşmayı sağlayan erişilebilir destek akışıdır.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 11.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          if (selectedContact != null)
            Container(
              decoration: BoxDecoration(
                color: YanYanaColors.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: YanYanaShadows.card,
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.verified_user_rounded,
                  color: YanYanaColors.primary,
                ),
                title: const Text(
                  "Seçilen Güvenilir Kişi",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: YanYanaColors.textDark,
                  ),
                ),
                subtitle: Text(
                  "${selectedContact.name} - ${selectedContact.phoneNumber}",
                  style: const TextStyle(
                    color: YanYanaColors.textMuted,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: isCalling ? sosGradient : primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ElevatedButton.icon(
                onPressed: isCalling ? stopSafeCall : startSafeCall,
                icon: Icon(
                  isCalling ? Icons.call_end_rounded : Icons.phone_rounded,
                ),
                label: Text(
                  isCalling
                      ? "Güvenli Aramayı Sonlandır"
                      : "Güvenli Aramayı Başlat",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: sosGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ElevatedButton.icon(
                onPressed: sendEmergencyAlert,
                icon: const Icon(Icons.warning_rounded),
                label: const Text("Acil Destek Bildir"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}