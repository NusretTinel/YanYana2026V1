import 'package:flutter_test/flutter_test.dart';

// Profil tamamlama yüzdesi hesaplama fonksiyonunun birim testi
class MockUserProfile {
  final String fullName;
  final String email;
  final String emergencyContactPhone;
  final String accessibilityConstraint;

  MockUserProfile({
    required this.fullName,
    required this.email,
    required this.emergencyContactPhone,
    required this.accessibilityConstraint,
  });

  double calculateCompletionRatio() {
    int totalFields = 4;
    int filledFields = 0;

    if (fullName.isNotEmpty) filledFields++;
    if (email.isNotEmpty) filledFields++;
    if (emergencyContactPhone.isNotEmpty) filledFields++;
    if (accessibilityConstraint.isNotEmpty) filledFields++;

    return (filledFields / totalFields) * 100;
  }
}

void main() {
  test('Dynamic Profile Completion Percentage Logic Metric Verification Test', () {
    // 4 zorunlu alandan sadece 2'si dolu olan bir profil yaratıyoruz (Yani %50 olmalı)
    final halfCompletedProfile = MockUserProfile(
      fullName: 'Deniz Kaya',
      email: 'deniz@test.com',
      emergencyContactPhone: '',
      accessibilityConstraint: '',
    );

    final actualCompletionRatio = halfCompletedProfile.calculateCompletionRatio();

    // Matematiksel sonucun tam olarak 50.0 çıktığını doğrula
    expect(actualCompletionRatio, equals(50.0));
  });
}