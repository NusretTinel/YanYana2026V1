import 'package:shared_preferences/shared_preferences.dart';

class GuideLocalProgressService {
  GuideLocalProgressService._();
  static final GuideLocalProgressService instance = GuideLocalProgressService._();

  static const String _likedGuidesKey = 'liked_guides';
  static const String _completedStepsPrefix = 'guide_steps_';

  SharedPreferences? _prefs;

  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ─── BEĞENİ (LIKE) KONTROLÜ ───

  /// Kullanıcının bu rehberi daha önce beğenip beğenmediğini kontrol eder
  Future<bool> hasLikedGuide(String guideId) async {
    await _init();
    final likedList = _prefs!.getStringList(_likedGuidesKey) ?? [];
    return likedList.contains(guideId);
  }

  /// Rehberi beğenildi olarak kaydeder
  Future<void> saveLike(String guideId) async {
    await _init();
    final likedList = _prefs!.getStringList(_likedGuidesKey) ?? [];
    if (!likedList.contains(guideId)) {
      likedList.add(guideId);
      await _prefs!.setStringList(_likedGuidesKey, likedList);
    }
  }

  // ─── İLERLEME (PROGRESS) KONTROLÜ ───

  /// Bu rehber için tamamlanan adım ID'lerini getirir
  Future<List<String>> getCompletedSteps(String guideId) async {
    await _init();
    return _prefs!.getStringList('$_completedStepsPrefix$guideId') ?? [];
  }

  /// Bir adımın tamamlanma durumunu kaydeder (toggle mantığı)
  Future<void> toggleStepComplete(String guideId, String stepId, bool isCompleted) async {
    await _init();
    final key = '$_completedStepsPrefix$guideId';
    final completedList = _prefs!.getStringList(key) ?? [];

    if (isCompleted && !completedList.contains(stepId)) {
      completedList.add(stepId);
    } else if (!isCompleted && completedList.contains(stepId)) {
      completedList.remove(stepId);
    }

    await _prefs!.setStringList(key, completedList);
  }
}
