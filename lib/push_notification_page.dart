import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';

class PushNotificationPage extends StatefulWidget {
  const PushNotificationPage({super.key});

  @override
  State<PushNotificationPage> createState() => _PushNotificationPageState();
}

class _PushNotificationPageState extends State<PushNotificationPage> {
  String selectedType = "Acil Destek";
  bool permissionEnabled = false;
  bool isSending = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> notificationTypes = [
    "Acil Destek",
    "Safe Call",
    "Topluluk Mesajı",
    "Erişilebilirlik Hatırlatması",
  ];

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  Future<void> _requestPermission() async {
    final iosPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (!mounted) return;

    setState(() {
      permissionEnabled = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bildirim izni etkinleştirildi."),
      ),
    );
  }

  Future<void> sendDemoNotification() async {
    if (isSending) return;

    setState(() {
      isSending = true;
    });

    try {
      if (!permissionEnabled) {
        await _requestPermission();
      }

      final message = '$selectedType bildirimi başarıyla gönderildi.';

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'yanyana_channel',
        'YanYana Notifications',
        channelDescription: 'YanYana local notification channel',
        importance: Importance.max,
        priority: Priority.high,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        selectedType,
        message,
        details,
      );

      await BackendOrchestrator.instance.notificationService.addForCurrentUser(
        title: selectedType,
        message: message,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$selectedType bildirimi gönderildi."),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Bad state: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
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
                "Local notification ve uygulama içi bildirim kaydı için izin alınır.",
              ),
              secondary: const Icon(Icons.notifications_rounded),
              onChanged: (value) async {
                if (value) {
                  await _requestPermission();
                } else {
                  setState(() {
                    permissionEnabled = false;
                  });
                }
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
                onPressed: isSending ? null : sendDemoNotification,
                icon: Icon(
                  isSending ? Icons.hourglass_top_rounded : Icons.send_rounded,
                ),
                label: Text(isSending ? "Gönderiliyor..." : "Bildirim Gönder"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.white70,
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
              "Bildirim gönderildiğinde hem local notification tetiklenir hem de uygulama içi Bildirimler sayfasına kayıt eklenir.",
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