import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Uygulama genelinde kullanılan TTS (Text-to-Speech) ve STT (Speech-to-Text) servisi.
/// Engelli kullanıcılar için sesli okuma ve sesle yazma desteği sağlar.
class AccessibilityService {
  AccessibilityService._();
  static final AccessibilityService instance = AccessibilityService._();

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _isSpeaking = false;
  bool _isListening = false;
  bool _sttInitialized = false;

  bool get isSpeaking => _isSpeaking;
  bool get isListening => _isListening;

  // ─── TTS — Sesli Okuma ────────────────────────────────────────────────────

  Future<void> _setupTts() async {
    await _tts.setLanguage('tr-TR');
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setCancelHandler(() => _isSpeaking = false);
  }

  /// Verilen metni sesli okur. Zaten okuyorsa önce durdurur.
  Future<void> speak(String text) async {
    await _setupTts();
    if (_isSpeaking) await stop();
    _isSpeaking = true;
    await _tts.speak(text);
  }

  /// Birden fazla metni sırayla (ara verilerek) okur.
  Future<void> speakAll(List<String> texts) async {
    final combined = texts.where((t) => t.trim().isNotEmpty).join('. ');
    await speak(combined);
  }

  /// Seslendirmeyi durdurur.
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    _isListening = false;
  }

  // ─── STT — Sesle Yazma ────────────────────────────────────────────────────

  /// Sesi metne çevirmek için dinlemeye başlar.
  /// [onResult] her söylenen kelimede çağrılır.
  /// [onDone] dinleme bittiğinde son metni verir.
  Future<bool> startListening({
    required void Function(String text) onResult,
    void Function(String finalText)? onDone,
  }) async {
    if (!_sttInitialized) {
      _sttInitialized = await _stt.initialize(
        onError: (_) => _isListening = false,
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
      );
    }
    if (!_sttInitialized) return false;

    _isListening = true;
    await _stt.listen(
      localeId: 'tr_TR',
      onResult: (result) {
        onResult(result.recognizedWords);
        if (result.finalResult && onDone != null) {
          onDone(result.recognizedWords);
          _isListening = false;
        }
      },
      listenMode: stt.ListenMode.dictation,
      pauseFor: const Duration(seconds: 3),
    );
    return true;
  }

  /// Dinlemeyi durdurur.
  Future<void> stopListening() async {
    await _stt.stop();
    _isListening = false;
  }

  bool get sttAvailable => _sttInitialized || _stt.isAvailable;

  void dispose() {
    _tts.stop();
    _stt.stop();
  }
}
