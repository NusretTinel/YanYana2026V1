import 'package:flutter_test/flutter_test.dart';

// Kanka buradaki validator sınıfı projedeki gerçek dosya yoluna göre import edilmeli
// Eğer proje yapında farklıysa burayı kendi auth_validator.dart yoluna göre güncelle.
class AuthValidator {
  static String? validateEmail(String value) {
    if (value.isEmpty || !value.contains('@')) {
      return 'Geçerli bir e-posta adresi giriniz.';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty || value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır.';
    }
    return null;
  }
}

void main() {
  group('Authentication Input Validation Sub-Routine Unit Tests', () {

    test('Should intercept and reject syntactically invalid email strings', () {
      final validationResult = AuthValidator.validateEmail('invalidEmailFormat');
      expect(validationResult, equals('Geçerli bir e-posta adresi giriniz.'));
    });

    test('Should catch and reject raw password strings fewer than 8 characters', () {
      final validationResult = AuthValidator.validatePassword('12345');
      expect(validationResult, equals('Şifre en az 8 karakter olmalıdır.'));
    });

    test('Should return null (Pass) when form variables satisfy integrity rules', () {
      final emailCheck = AuthValidator.validateEmail('verified_user@test.com');
      final passwordCheck = AuthValidator.validatePassword('SecurePassword123');

      expect(emailCheck, isNull);
      expect(passwordCheck, isNull);
    });
  });
}