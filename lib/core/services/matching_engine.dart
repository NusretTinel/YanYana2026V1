import 'package:yanyana_p/shared/models/support_request.dart';
import 'package:yanyana_p/shared/models/volunteer_match.dart';

/// Selects the most suitable volunteer for a request (mock logic).
///
/// Later this can be backed by Firestore queries and Cloud Functions scoring.
class MatchingEngine {
  const MatchingEngine();

  String findBestVolunteer(SupportRequest request) {
    final type = request.requestType.toLowerCase();
    if (type.contains('ulaşım')) return 'Ali Demir';
    if (type.contains('okuma')) return 'Zeynep Kaya';
    if (type.contains('acil')) return 'Ece Yıldız';
    if (type.contains('mentorluk')) return 'Elif Çetin';
    return 'Gönüllü Ekibi';
  }

  /// Structured match result; does not replace [findBestVolunteer] for existing callers.
  VolunteerMatch buildVolunteerMatch(SupportRequest request) {
    return VolunteerMatch(
      supportRequestId: request.id,
      volunteerName: findBestVolunteer(request),
      mockScore: 0.91,
      createdAt: DateTime.now(),
    );
  }
}
