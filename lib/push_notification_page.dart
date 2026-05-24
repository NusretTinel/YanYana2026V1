import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';

class PushNotificationPage extends StatefulWidget {
  const PushNotificationPage({super.key});

  @override
  State<PushNotificationPage> createState() => _PushNotificationPageState();
}

class _PushNotificationPageState extends State<PushNotificationPage> {
  String selectedType = "Acil Destek";
  bool permissionEnabled = false;

  final List<String> notificationTypes = [
    "Acil Destek",
    "Safe Call",
    "Topluluk Mesajı",
    "Erişilebilirlik Hatırlatması",
  ];

  void sendDemoNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$selectedType bildirimi gönderildi."),
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
        title: const Text("Push Notification"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: YanYanaColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                size: 55,
                color: YanYanaColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            "Push Notification",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: YanYanaColors.textDark,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            "Kullanıcıya acil destek, güvenlik ve topluluk bildirimleri göndermek için tasarlanmıştır.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 30),

          Container(
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: YanYanaShadows.card,
            ),
            child: SwitchListTile(
              value: permissionEnabled,
              activeThumbColor: YanYanaColors.primary,
              title: const Text(
                "Bildirim İzni",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                "Gerçek Firebase bağlantısında kullanıcıdan izin istenir.",
              ),
              secondary: const Icon(Icons.notifications_rounded),
              onChanged: (value) {
                setState(() {
                  permissionEnabled = value;
                });
              },
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: YanYanaShadows.card,
            ),
            child: DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: InputDecoration(
                labelText: "Bildirim Türü",
                labelStyle: const TextStyle(
                  color: YanYanaColors.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: YanYanaColors.border,
                  ),
                ),
              ),
              items: notificationTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedType = value;
                });
              },
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ElevatedButton.icon(
                onPressed: sendDemoNotification,
                icon: const Icon(Icons.send_rounded),
                label: const Text("Bildirim Gönder"),
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

          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: YanYanaShadows.card,
            ),
            child: const Text(
              "Not: Gerçek push notification için Firebase Cloud Messaging bağlantısı gerekir.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: YanYanaColors.textMuted,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}