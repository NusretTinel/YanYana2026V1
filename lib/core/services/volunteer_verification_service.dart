import 'package:yanyana_p/shared/models/volunteer_application.dart';

/// Mock volunteer identity/status verification.
/// NOTE: E-Devlet (or any official verification) is NOT implemented in this prototype.
class VolunteerVerificationService {
  const VolunteerVerificationService();

  Future<VolunteerApplication> approveVolunteer(
    VolunteerApplication application,
  ) async {
    await Future.delayed(const Duration(milliseconds: 450));
    return application.copyWith(status: 'Onaylandı');
  }

  Future<VolunteerApplication> rejectVolunteer(
    VolunteerApplication application,
  ) async {
    await Future.delayed(const Duration(milliseconds: 450));
    return application.copyWith(status: 'Reddedildi');
  }
}

