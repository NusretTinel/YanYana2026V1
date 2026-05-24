import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:yanyana_p/core/theme/theme.dart';

class LiveCaptionPage extends StatefulWidget {
  const LiveCaptionPage({super.key});

  @override
  State<LiveCaptionPage> createState() => _LiveCaptionPageState();
}

class _LiveCaptionPageState extends State<LiveCaptionPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _captionText = "Henüz konuşma algılanmadı.";
  String _statusText = "Canlı altyazı beklemede.";

  Future<void> _startCaptioning() async {
    final bool available = await _speech.initialize();

    if (available) {
      if (!mounted) return;

      setState(() {
        _isListening = true;
        _captionText = "Dinleniyor...";
        _statusText = "Mikrofon aktif. Konuşma altyazıya dönüştürülüyor.";
      });

      _speech.listen(
        localeId: "tr_TR",
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            _captionText = result.recognizedWords.isEmpty
                ? "Dinleniyor..."
                : result.recognizedWords;
            _statusText = "Konuşma başarıyla altyazıya çevrildi.";
          });
        },
      );
    } else {
      if (!mounted) return;

      setState(() {
        _captionText = "Mikrofon kullanılamıyor.";
        _statusText = "Canlı altyazı başlatılamadı.";
      });
    }
  }

  Future<void> _stopCaptioning() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _isListening = false;

      if (_captionText == "Dinleniyor...") {
        _captionText = "Herhangi bir konuşma algılanmadı.";
      }

      _statusText = "Canlı altyazı durduruldu.";
    });
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.background,
        elevation: 0,
        title: const Text(
          "Canlı Altyazı",
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(
          color: YanYanaColors.textDark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 120,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _isListening ? 125 : 110,
                height: _isListening ? 125 : 110,
                decoration: BoxDecoration(
                  color: _isListening
                      ? YanYanaColors.sos.withOpacity(0.14)
                      : YanYanaColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isListening
                      ? Icons.record_voice_over_rounded
                      : Icons.closed_caption_rounded,
                  size: _isListening ? 60 : 55,
                  color: _isListening
                      ? YanYanaColors.sos
                      : YanYanaColors.primary,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Canlı Altyazı Sistemi",
                style: TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                "Konuşmaları gerçek zamanlı olarak altyazıya dönüştürür.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: YanYanaColors.textMuted,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: YanYanaColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: YanYanaShadows.card,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Canlı Altyazı Metni",
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _captionText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: YanYanaColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: YanYanaColors.primary.withOpacity(0.15),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      "Durum",
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: YanYanaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: YanYanaColors.divider),
                ),
                child: const Text(
                  "Demo için konuşmaya başladıktan sonra söylenen cümleler bu alanda altyazı olarak görünür.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _isListening ? sosGradient : primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isListening ? _stopCaptioning : _startCaptioning,
                    icon: Icon(
                      _isListening
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    label: Text(
                      _isListening
                          ? "Altyazıyı Durdur"
                          : "Canlı Altyazıyı Başlat",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}