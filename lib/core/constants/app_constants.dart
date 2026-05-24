/// App-wide constants for the YanYana prototype.
/// Role values mirror future Firestore security rules / custom claims.
class AppConstants {
  AppConstants._();
}

/// Technical role identifiers (English snake_case).
class AppRole {
  AppRole._();

  static const String disabledUser = 'disabled_user';
  static const String volunteer = 'volunteer';
  static const String standardUser = 'standard_user';
  static const String admin = 'admin';
  static const String moderator = 'moderator';

  /// Turkish labels for UI when driven from technical roles.
  static String displayName(String technicalRole) {
    switch (technicalRole) {
      case disabledUser:
        return 'Engelli Kullanıcı';
      case volunteer:
        return 'Gönüllü';
      case standardUser:
        return 'Standart Kullanıcı';
      case admin:
        return 'Admin';
      case moderator:
        return 'Moderatör';
      default:
        return technicalRole;
    }
  }

  /// Maps legacy mock labels to technical roles where possible.
  static String normalizeToTechnical(String storedRole) {
    switch (storedRole) {
      case disabledUser:
      case volunteer:
      case standardUser:
      case admin:
      case moderator:
        return storedRole;
      case 'Kullanıcı':
        return disabledUser;
      default:
        return disabledUser;
    }
  }
}
