/// In-app / push notification payload (mock; future FCM + Firestore inbox).
enum AppNotificationType { sos, match, message, announcement }

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final AppNotificationType type;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
  });
}
