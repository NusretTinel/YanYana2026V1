/// Short purpose copy for live/mock rooms based on category.
String roomPurposeForCategory(String category) {
  switch (category) {
    case 'Destek':
      return 'Bu oda akran desteği ve güvenli paylaşım için tasarlandı. '
          'Zor anlarda birbirinize nazikçe eşlik edebilir, yargılamadan dinleyebilirsiniz.';
    case 'Eğitim':
      return 'Bu oda öğrenme, bilgi paylaşımı ve mentorluk için açılmıştır. '
          'Kaynaklar, deneyimler ve rehberlik burada paylaşılır.';
    case 'Sağlık':
      return 'Bu oda erişilebilir sağlık farkındalığı ve deneyim paylaşımı içindir. '
          'Profesyonel tedavi yerine geçmez; topluluk desteği sunar.';
    case 'Sosyal':
      return 'Bu oda günlük sohbet ve sosyal katılımı destekler. '
          'Tanışın, gününüzü paylaşın ve yalnızlık hissini azaltın.';
    case 'Mentorluk':
      return 'Bu oda rehberlik ve deneyim paylaşımı için açılmıştır. '
          'Kariyer, eğitim ve kişisel gelişimde birbirinize mentorluk yapabilirsiniz.';
    default:
      return 'Bu oda YanYana topluluğunda kapsayıcı iletişim ve sosyal '
          'katılımı desteklemek için oluşturulmuştur.';
  }
}

const List<String> liveRoomGuidelineRules = [
  'Saygılı olun ve farklı deneyimlere değer verin.',
  'İletişimi kapsayıcı ve erişilebilir tutun.',
  'Kişisel hassas bilgilerinizi paylaşmayın.',
  'Güvensiz davranışları bildirin.',
];

List<String> displayAccessibilityTags(List<String> tags) {
  if (tags.isNotEmpty) return tags;
  return const ['Güvenli Alan'];
}
