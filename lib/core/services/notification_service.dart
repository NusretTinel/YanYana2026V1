import 'package:yanyana_p/shared/models/notification_model.dart';

import 'auth_service.dart';
import 'firestore_notification_service.dart';

/// In-app notifications via Firestore. UI uses [BackendOrchestrator].
class NotificationService {
  NotificationService({required this.authService});

  final AuthService authService;
  final FirestoreNotificationService _firestore =
      FirestoreNotificationService.instance;

  Future<List<NotificationModel>> getNotifications() async {
    final user = authService.currentUser;
    if (user == null) return const [];
    return _firestore.getForUser(user.id);
  }

  Stream<List<NotificationModel>> streamNotifications() {
    final user = authService.currentUser;
    if (user == null) return const Stream.empty();
    return _firestore.streamForUser(user.id);
  }

  Future<void> addForCurrentUser({
    required String title,
    required String message,
  }) async {
    final user = authService.currentUser;
    if (user == null) return;
    await _firestore.add(
      userId: user.id,
      title: title,
      message: message,
    );
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
  }) async {
    await _firestore.add(
      userId: userId,
      title: title,
      message: message,
    );
  }

  Future<void> markRead(String notificationId) async {
    await _firestore.markRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    final user = authService.currentUser;
    if (user == null) return;
    await _firestore.markAllAsRead(user.id);
  }
}
