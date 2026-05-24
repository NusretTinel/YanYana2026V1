/// Shared helpers (formatting, validators). Add utilities here as the app grows.
class AppUtils {
  AppUtils._();

  static final RegExp _email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Lightweight RFC-style email check (sufficient for client-side UX).
  static bool isValidEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return false;
    return _email.hasMatch(v);
  }
}
