import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:yanyana_p/core/theme/theme.dart';

class ShakeHelpPage extends StatefulWidget {
  const ShakeHelpPage({super.key});

  @override
  State<ShakeHelpPage> createState() => _ShakeHelpPageState();
}

class _ShakeHelpPageState extends State<ShakeHelpPage> {
  ShakeDetector? detector;

  bool isActivated = false;
  String statusText = "Shake Detection pasif durumda.";

  @override
  void initState() {
    super.initState();

    detector = ShakeDetector.autoStart(
      onPhoneShake: (ShakeEvent event) {
        if (!isActivated) return;

        sendHelpAlert();
      },
    );

    detector?.stopListening();
  }

  void sendHelpAlert() {
    setState(() {
      statusText =
          "Yardım sinyali gönderildi. En yakın destek birimine bildirim iletilebilir.";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Yardım bildirimi gönderildi."),
      ),
    );
  }

  @override
  void dispose() {
    detector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.background,
        elevation: 0,
        title: const Text(
          "Shake for Help",
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(
          color: YanYanaColors.textDark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isActivated ? 125 : 110,
                height: isActivated ? 125 : 110,
                decoration: BoxDecoration(
                  color: isActivated
                      ? YanYanaColors.sos.withOpacity(0.14)
                      : YanYanaColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.vibration_rounded,
                  size: isActivated ? 60 : 55,
                  color: isActivated
                      ? YanYanaColors.sos
                      : YanYanaColors.primary,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Shake for Help",
                style: TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Telefon sallandığında hızlı yardım bildirimi gönderilir.",
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
                  value: isActivated,
                  activeThumbColor: YanYanaColors.primary,
                  title: const Text(
                    "Shake Detection",
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    isActivated
                        ? "Sallama algılama aktif."
                        : "Telefon sallanınca yardım bildirimi gönder.",
                  ),
                  secondary: Icon(
                    isActivated
                        ? Icons.notifications_active_rounded
                        : Icons.phone_android_rounded,
                  ),
                  onChanged: (value) {
                    setState(() {
                      isActivated = value;

                      statusText = value
                          ? "Shake Detection aktif edildi."
                          : "Shake Detection devre dışı bırakıldı.";
                    });

                    if (value) {
                      detector?.startListening();
                    } else {
                      detector?.stopListening();
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? "Shake Detection aktif edildi."
                              : "Shake Detection kapatıldı.",
                        ),
                      ),
                    );
                  },
                ),
              ),

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

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: sendHelpAlert,
                    icon: const Icon(Icons.notification_important_rounded),
                    label: const Text("Test Yardım Bildirimi Gönder"),
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

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: YanYanaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: YanYanaColors.divider),
                ),
                child: const Text(
                  "Gerçek sallama algılama özelliği fiziksel mobil cihazlarda test edilmelidir.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}