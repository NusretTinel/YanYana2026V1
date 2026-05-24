/// Authorization level stored in Firestore `users.role`.
class AppAuthRole {
  AppAuthRole._();

  static const user = 'user';
  static const moderator = 'moderator';
  static const admin = 'admin';

  static String label(String role) {
    switch (normalize(role)) {
      case moderator:
        return 'Moderatör';
      case admin:
        return 'Admin';
      default:
        return '';
    }
  }

  static String normalize(String? value) {
    switch (value) {
      case user:
      case moderator:
      case admin:
        return value!;
      default:
        return user;
    }
  }

  static bool isAdmin(String role) => normalize(role) == admin;
  static bool isModerator(String role) => normalize(role) == moderator;
  static bool isStaff(String role) {
    final r = normalize(role);
    return r == moderator || r == admin;
  }
}

/// User identity / purpose in the app (`users.userType`).
class AppUserType {
  AppUserType._();

  static const disabledUser = 'disabled_user';
  static const volunteer = 'volunteer';
  static const regularUser = 'regular_user';
  static const business = 'business';

  static String label(String userType) {
    switch (normalize(userType)) {
      case disabledUser:
        return 'Engelli Kullanıcı';
      case volunteer:
        return 'Gönüllü';
      case regularUser:
        return 'Standart Kullanıcı';
      case business:
        return 'İşletme';
      default:
        return userType;
    }
  }

  static String normalize(String? value) {
    switch (value) {
      case disabledUser:
      case volunteer:
      case regularUser:
      case business:
        return value!;
      case 'standard_user':
        return regularUser;
      default:
        return regularUser;
    }
  }
}

/// Volunteer application state on user document (`users.volunteerStatus`).
class VolunteerStatus {
  VolunteerStatus._();

  static const none = 'none';
  static const pending = 'pending';
  static const approved = 'approved';
  static const rejected = 'rejected';

  static String label(String status) {
    switch (normalize(status)) {
      case pending:
        return 'Başvuru beklemede';
      case approved:
        return 'Gönüllü onaylandı';
      case rejected:
        return 'Başvuru reddedildi';
      default:
        return '';
    }
  }

  static String normalize(String? value) {
    switch (value) {
      case none:
      case pending:
      case approved:
      case rejected:
        return value!;
      default:
        return none;
    }
  }
}
