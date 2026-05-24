import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:yanyana_p/core/theme/theme.dart';

class VoiceCommandPage extends StatefulWidget {
  const VoiceCommandPage({super.key});

  @override
  State<VoiceCommandPage> createState() => _VoiceCommandPageState();
}

class _VoiceCommandPageState extends State<VoiceCommandPage> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _recognizedText = "Henüz bir komut algılanmadı.";
  String _commandResult = "Komut sonucu burada görünecek.";

  Future<void> _startListening() async {
    final bool available = await _speech.initialize();

    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = "Dinleniyor...";
        _commandResult = "Komut bekleniyor.";
      });

      _speech.listen(
        localeId: "tr_TR",
        onResult: (result) {
          if (!mounted) return;

          setState(() {
            _recognizedText = result.recognizedWords;
            _commandResult = _getCommandResult(result.recognizedWords);
          });
        },
      );
    } else {
      setState(() {
        _recognizedText = "Mikrofon kullanılamıyor.";
        _commandResult = "Sesli komut başlatılamadı.";
      });
    }
  }

  String _getCommandResult(String command) {
    final lowerCommand = command.toLowerCase();

    if (command.trim().isEmpty) {
      return "Komut bekleniyor.";
    } else if (lowerCommand.contains("sos") ||
        lowerCommand.contains("yardım")) {
      return "SOS komutu algılandı. Acil yardım işlemi başlatılabilir.";
    } else if (lowerCommand.contains("arama") ||
        lowerCommand.contains("ara")) {
      return "Güvenli arama komutu algılandı.";
    } else if (lowerCommand.contains("altyazı")) {
      return "Canlı altyazı komutu algılandı.";
    } else if (lowerCommand.contains("sesli okuma") ||
        lowerCommand.contains("oku")) {
      return "Sesli okuma komutu algılandı.";
    } else {
      return "Komut algılandı ancak eşleşen bir işlem bulunamadı.";
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    if (!mounted) return;

    setState(() {
      _isListening = false;

      if (_recognizedText == "Dinleniyor...") {
        _recognizedText = "Herhangi bir komut algılanmadı.";
        _commandResult = "Komut tamamlanamadı.";
      }
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
          "Sesli Komut",
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
                  _isListening ? Icons.hearing_rounded : Icons.mic_rounded,
                  size: _isListening ? 60 : 55,
                  color: _isListening
                      ? YanYanaColors.sos
                      : YanYanaColors.primary,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Sesli Komut Sistemi",
                style: TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                "Kullanıcının uygulamayı sesli komutlarla daha kolay kullanmasını sağlar.",
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
                      "Algılanan Ses",
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _recognizedText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                      "Algılanan İşlem",
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _commandResult,
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
                  "Örnek komutlar: “SOS gönder”, “yardım çağır”, “güvenli arama başlat”, “canlı altyazıyı aç”, “sesli okuma aç”.",
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
                    onPressed: _isListening ? _stopListening : _startListening,
                    icon: Icon(
                      _isListening
                          ? Icons.stop_rounded
                          : Icons.keyboard_voice_rounded,
                    ),
                    label: Text(
                      _isListening ? "Dinlemeyi Durdur" : "Dinlemeyi Başlat",
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