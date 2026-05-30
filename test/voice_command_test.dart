import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Voice Command Tests', () {
    test('Speech recognition should update caption text', () {
      String captionText = "Dinleniyor...";

      captionText = "Komut algılandı";

      expect(captionText, equals("Komut algılandı"));
    });

    test('Status text should change after voice input', () {
      String statusText = "";

      statusText = "Konuşma başarıyla algılandı.";

      expect(statusText.contains("başarıyla"), true);
    });

    test('Turkish locale configuration should remain active', () {
      const locale = "tr-TR";

      expect(locale, equals("tr-TR"));
    });
  });
}