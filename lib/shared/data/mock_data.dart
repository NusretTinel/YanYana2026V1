/// Static informational content only (not user-generated data).
class MockData {
  static const List<Map<String, String>> guideCards = [
    {
      'title': 'İletişim Kartı',
      'desc':
          'Kısa cümleler, net istekler ve tercih ettiğin iletişim şeklini belirt.',
      'badge': 'Rehber',
    },
    {
      'title': 'Acil Durum Kartı',
      'desc':
          'Acil durumda aranacak kişiler, temel bilgiler ve güvenli alan notları.',
      'badge': 'Rehber',
    },
    {
      'title': 'Günlük Destek Kartı',
      'desc':
          'Rutin destek ihtiyaçların için (okuma, ulaşım, sosyal destek) hızlı form.',
      'badge': 'Rehber',
    },
  ];

  static const List<String> donationSupportTypes = [
    'Maddi Bağış',
    'Eşya Bağışı',
    'Zaman Bağışı',
    'Gönüllü Destek',
  ];
}
