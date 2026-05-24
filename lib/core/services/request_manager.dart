import 'package:yanyana_p/shared/models/support_request.dart';

import 'auth_service.dart';
import 'chat_thread_service.dart';
import 'matching_engine.dart';
import 'notification_service.dart';
import 'support_request_service.dart';

/// Accepts support requests, persists to Firestore, runs matching, notifies user.
class RequestManager {
  final MatchingEngine matchingEngine;
  final NotificationService notificationService;
  final SupportRequestService supportRequestService;
  final ChatThreadService chatThreadService;
  final AuthService authService;

  const RequestManager({
    required this.matchingEngine,
    required this.notificationService,
    required this.supportRequestService,
    required this.chatThreadService,
    required this.authService,
  });

  Future<SupportRequest> createSupportRequest(SupportRequest request) async {
    final user = authService.currentUser;
    if (user == null) throw StateError('Oturum açmanız gerekiyor.');

    final saved = await supportRequestService.create(
      userId: user.id,
      requesterName: request.requesterName,
      requestType: request.requestType,
      description: request.description,
      status: request.status,
    );

    final volunteer = matchingEngine.findBestVolunteer(request);
    final updated = await supportRequestService.updateMatch(
      requestId: saved.id,
      status: 'Eşleştirildi',
      assignedVolunteerName: volunteer,
    );

    await notificationService.addForCurrentUser(
      title: 'Yeni Destek Talebi',
      message:
          '${updated.requestType} için $volunteer eşleştirildi.',
    );

    await chatThreadService.addThread(
      userId: user.id,
      peerName: volunteer,
      contextLabel: updated.requestType,
      lastMessage: 'Destek talebiniz eşleştirildi.',
    );

    return updated;
  }
}
