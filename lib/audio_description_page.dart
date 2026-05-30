import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

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

  String uploadedText = "Henüz dosya seçilmedi.";
  String statusText = "Sesli destek kullanıma hazır.";

  bool isSpeaking = false;
  bool isReadingFile = false;

  Future<void> pickDocumentFile() async {
    if (!mounted) return;

    setState(() {
      isReadingFile = true;
      statusText = "Dosya seçiliyor.";
    });

    try {
      final uploadInput = html.FileUploadInputElement()
        ..accept = '.txt,.md,.csv,.png,.jpg,.jpeg'
        ..click();

      uploadInput.onChange.listen((event) {
        final file = uploadInput.files?.first;

        if (file == null) {
          if (!mounted) return;

          setState(() {
            isReadingFile = false;
            statusText = "Dosya seçimi iptal edildi.";
          });
          return;
        }

        final fileName = file.name.toLowerCase();
        final reader = html.FileReader();

        reader.onLoadEnd.listen((event) async {
          final result = reader.result;

          if (result == null) {
            if (!mounted) return;

            setState(() {
              uploadedText = "Dosya okunamadı.";
              statusText = "Dosya okuma sırasında hata oluştu.";
              isReadingFile = false;
            });
            return;
          }

          final isImage = fileName.endsWith('.png') ||
              fileName.endsWith('.jpg') ||
              fileName.endsWith('.jpeg');

          if (isImage) {
            if (!mounted) return;

            setState(() {
              statusText = "Görseldeki yazılar algılanıyor. Lütfen bekleyin.";
            });

            try {
              final extractedText = await js_util.promiseToFuture<String>(
                js_util.callMethod(
                  js_util.globalThis,
                  'readTextFromImage',
                  [result.toString()],
                ),
              );

              final cleanText = extractedText.trim();

              if (!mounted) return;

              setState(() {
                uploadedText = cleanText.isEmpty
                    ? "Görselde okunabilir metin bulunamadı."
                    : cleanText;

                statusText = cleanText.isEmpty
                    ? "Görselde metin algılanamadı."
                    : "Görseldeki metin başarıyla algılandı.";

                isReadingFile = false;
              });
            } catch (e) {
              if (!mounted) return;

              setState(() {
                uploadedText = "Görseldeki metin okunamadı.";
                statusText = "OCR işlemi sırasında hata oluştu.";
                isReadingFile = false;
              });
            }
          } else {
            final text = result.toString().trim();

            if (!mounted) return;

            setState(() {
              uploadedText = text.isEmpty ? "Belge boş görünüyor." : text;

              statusText = text.isEmpty
                  ? "Belgelerde okunacak metin bulunamadı."
                  : "Belge içeriği başarıyla okundu.";

              isReadingFile = false;
            });
          }
        });

        final isImage = fileName.endsWith('.png') ||
            fileName.endsWith('.jpg') ||
            fileName.endsWith('.jpeg');

        if (isImage) {
          reader.readAsDataUrl(file);
        } else {
          reader.readAsText(file, 'UTF-8');
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        uploadedText = "Dosya okunamadı.";
        statusText = "Dosya okuma sırasında hata oluştu.";
        isReadingFile = false;
      });
    }
  }

  Future<void> speakUploadedText() async {
    if (uploadedText == "Henüz dosya seçilmedi." ||
        uploadedText == "Belge boş görünüyor." ||
        uploadedText == "Dosya okunamadı." ||
        uploadedText == "Görselde okunabilir metin bulunamadı." ||
        uploadedText == "Görseldeki metin okunamadı.") {
      return;
    }

    await flutterTts.stop();
    await flutterTts.setLanguage("tr-TR");
    await flutterTts.setSpeechRate(0.45);

    if (!mounted) return;

    setState(() {
      isSpeaking = true;
      statusText = "İçerik seslendiriliyor.";
    });

    await flutterTts.speak(uploadedText);
  }

  Future<void> stopSpeaking() async {
    await flutterTts.stop();

    if (!mounted) return;

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

    flutterTts.setErrorHandler((message) {
      if (!mounted) return;

      setState(() {
        isSpeaking = false;
        statusText = "Seslendirme sırasında hata oluştu.";
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
                "Yüklenen belge veya görsel içeriğini kullanıcıya sesli olarak aktarır.",
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
                      "Belge veya Görselden Sesli Okuma",
                      style: TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      "TXT, Markdown, CSV veya görsel yükleyerek içeriğini sesli dinleyebilirsiniz.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 13.5,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (isReadingFile)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: CircularProgressIndicator(),
                      ),

                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxHeight: 220,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: YanYanaColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: YanYanaColors.primary.withOpacity(0.12),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          uploadedText,
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: YanYanaColors.textMuted,
                            fontSize: 14.5,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isReadingFile ? null : pickDocumentFile,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: const Text("Belge veya Görsel Yükle"),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isReadingFile
                            ? null
                            : isSpeaking
                                ? stopSpeaking
                                : speakUploadedText,
                        icon: Icon(
                          isSpeaking
                              ? Icons.stop_rounded
                              : Icons.volume_up_rounded,
                        ),
                        label: Text(
                          isSpeaking
                              ? "Seslendirmeyi Durdur"
                              : "İçeriği Seslendir",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}