import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:yanyana_p/core/theme/theme.dart';

class AudioDescriptionPage extends StatefulWidget {
  const AudioDescriptionPage({super.key});

  @override
  State<AudioDescriptionPage> createState() => _AudioDescriptionPageState();
}

class _AudioDescriptionPageState extends State<AudioDescriptionPage> {
  final FlutterTts flutterTts = FlutterTts();

  final String demoText =
      "YanYana uygulamasına hoş geldiniz. "
      "Bu özellik ekran içeriklerini sesli şekilde kullanıcıya aktarır. "
      "Sesli betimleme desteği, görme zorluğu yaşayan kullanıcıların uygulama içeriğini daha kolay takip etmesini sağlar.";

  bool isSpeaking = false;
  String statusText = "Sesli betimleme beklemede.";

  Future<void> speakText() async {
    await flutterTts.setLanguage("tr-TR");
    await flutterTts.setSpeechRate(0.45);

    setState(() {
      isSpeaking = true;
      statusText = "Metin seslendiriliyor.";
    });

    await flutterTts.speak(demoText);
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();

    setState(() {
      isSpeaking = false;
      statusText = "Seslendirme durduruldu.";
    });
  }

  @override
  void initState() {
    super.initState();

    flutterTts.setCompletionHandler(() {
      if (!mounted) return;

      setState(() {
        isSpeaking = false;
        statusText = "Seslendirme tamamlandı.";
      });
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
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
          "Sesli Betimleme",
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
                width: isSpeaking ? 125 : 110,
                height: isSpeaking ? 125 : 110,
                decoration: BoxDecoration(
                  color: isSpeaking
                      ? YanYanaColors.sos.withOpacity(0.14)
                      : YanYanaColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSpeaking
                      ? Icons.graphic_eq_rounded
                      : Icons.record_voice_over_rounded,
                  size: isSpeaking ? 60 : 55,
                  color: isSpeaking
                      ? YanYanaColors.sos
                      : YanYanaColors.primary,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Sesli Betimleme",
                style: TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                "Ekran içeriklerini kullanıcıya sesli olarak aktarır.",
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
                      "Okunacak Metin",
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      demoText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 15.5,
                        height: 1.45,
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
                      "Durum",
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusText,
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
                  "Bu özellik, metin içeriklerini sesli olarak aktararak erişilebilir kullanım deneyimini destekler.",
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
                    gradient: isSpeaking ? sosGradient : primaryGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: isSpeaking ? stopSpeaking : speakText,
                    icon: Icon(
                      isSpeaking
                          ? Icons.stop_rounded
                          : Icons.volume_up_rounded,
                    ),
                    label: Text(
                      isSpeaking
                          ? "Seslendirmeyi Durdur"
                          : "Metni Seslendir",
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