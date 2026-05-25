import 'package:flutter_test/flutter_test.dart';

// SOS tetiklendiğinde butonun kilitlenme (busy) mantığını test eden controller simülasyonu
class MockHomeController {
  bool isSosBusy = false;

  Future<void> triggerEmergencySOS() async {
    isSosBusy = true; // Asenkron işlem başladığında busy kilit aktif olur
    await Future.delayed(const Duration(milliseconds: 100)); // İstek süresi simülasyonu
    isSosBusy = false; // İşlem bittiğinde kilit açılır
  }
}

void main() {
  test('Emergency SOS Concurrency Controls and Busy Semaphore State Verification', () async {
    final homeController = MockHomeController();

    // Başlangıçta buton kilitli olmamalı
    expect(homeController.isSosBusy, isFalse);

    // SOS işlemini başlatıyoruz
    final sosExecutionFuture = homeController.triggerEmergencySOS();

    // İşlem arka planda devam ederken butonun kilitlendiğini (true) doğrula
    expect(homeController.isSosBusy, isTrue);

    // İşlemin bitmesini bekle
    await sosExecutionFuture;

    // İşlem tamamen bittiğinde kilit başarıyla sıfırlanmalı (false)
    expect(homeController.isSosBusy, isFalse);
  });
}