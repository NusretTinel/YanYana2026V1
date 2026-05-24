import 'package:flutter/material.dart';
import 'safe_call_page.dart';
import 'live_caption_page.dart';
import 'voice_command_page.dart';
import 'audio_description_page.dart';
import 'shake_help_page.dart';
import 'push_notification_page.dart';

class FunctionalityPage extends StatelessWidget {
  const FunctionalityPage({super.key});

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fonksiyonalite"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "YanYana Accessibility",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Erişilebilirlik ve güvenlik özelliklerini buradan yönetebilirsiniz.",
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _featureCard(
            icon: Icons.vibration,
            title: "Shake for Help",
            subtitle: "Telefonu sallayarak hızlı destek iste",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShakeHelpPage(),
                ),
              );
            },
          ),

          _featureCard(
            icon: Icons.mic,
            title: "Sesli Komut Sistemi",
            subtitle: "Sesli kullanım desteği",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoiceCommandPage(),
                ),
              );
            },
          ),

          _featureCard(
            icon: Icons.record_voice_over,
            title: "Sesli Betimleme",
            subtitle: "Ekran içeriklerini sesli açıklama desteği",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AudioDescriptionPage(),
                ),
              );
            },
          ),

          _featureCard(
            icon: Icons.closed_caption,
            title: "Canlı Altyazı",
            subtitle: "Gerçek zamanlı altyazı desteği",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LiveCaptionPage(),
                ),
              );
            },
          ),

          _featureCard(
            icon: Icons.notifications_active,
            title: "Push Notification",
            subtitle: "Acil destek ve güvenlik bildirimi",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PushNotificationPage(),
                ),
              );
            },
          ),

          _featureCard(
            icon: Icons.support_agent,
            title: "Hızlı Destek Butonu",
            subtitle: "Acil durumda hızlı destek erişimi",
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Acil Destek"),
                      ],
                    ),
                    content: const Text(
                      "Destek ekibine acil yardım bildirimi gönderilsin mi?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("İptal"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Acil destek bildirimi gönderildi.",
                              ),
                            ),
                          );
                        },
                        child: const Text("Gönder"),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          _featureCard(
            icon: Icons.call,
            title: "Safe Call",
            subtitle: "Güvenli ve sakinleştirici arama desteği",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SafeCallPage(),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Community"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_accessibility),
            label: "Function",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}