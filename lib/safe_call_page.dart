import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';

class SafeCallPage extends StatefulWidget {
  const SafeCallPage({super.key});

  @override
  State<SafeCallPage> createState() => _SafeCallPageState();
}

class _SafeCallPageState extends State<SafeCallPage> {
  String selectedContact = "Anne";
  String selectedNumber = "0555 111 22 33";

  bool isCalling = false;
  String statusText = "Güvenli arama sistemi beklemede.";

  final List<Map<String, String>> emergencyContacts = [
    {"name": "Anne", "number": "0555 111 22 33"},
    {"name": "Baba", "number": "0555 444 55 66"},
    {"name": "Yakın Arkadaş", "number": "0555 777 88 99"},
  ];

  void selectContact(String name, String number) {
    setState(() {
      selectedContact = name;
      selectedNumber = number;

      statusText = "$selectedContact kişisi seçildi.";
    });
  }

  void startSafeCall() {
    setState(() {
      isCalling = true;
      statusText =
          "$selectedContact ile güvenli arama bağlantısı başlatılıyor.";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$selectedContact aranıyor: $selectedNumber"),
      ),
    );
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
    setState(() {
      statusText =
          "$selectedContact kişisine acil destek bildirimi gönderildi.";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text("$selectedContact kişisine acil destek bildirimi gönderildi."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                isCalling
                    ? Icons.call_rounded
                    : Icons.phone_enabled_rounded,
                size: isCalling ? 60 : 55,
                color: isCalling
                    ? YanYanaColors.sos
                    : YanYanaColors.primary,
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
            "Acil Kişiler",
            style: TextStyle(
              color: YanYanaColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 10),

          ...emergencyContacts.map((contact) {
            final bool isSelected = contact["name"] == selectedContact;

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
                  contact["name"]!,
                  style: const TextStyle(
                    color: YanYanaColors.textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  contact["number"]!,
                  style: const TextStyle(
                    color: YanYanaColors.textMuted,
                  ),
                ),
                onTap: () {
                  selectContact(
                    contact["name"]!,
                    contact["number"]!,
                  );
                },
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
              ],
            ),
          ),

          const SizedBox(height: 16),

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
                "Seçilen Acil Kişi",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: YanYanaColors.textDark,
                ),
              ),
              subtitle: Text(
                "$selectedContact - $selectedNumber",
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
                  isCalling
                      ? Icons.call_end_rounded
                      : Icons.phone_rounded,
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