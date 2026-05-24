import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/accessibility_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';

/// Ekrandaki metni sesli okuyan küçük buton.
/// AppBar action veya kart içinde kullanılabilir.
class TtsReadButton extends StatefulWidget {
  /// Okunacak metin listesi — sırayla birleştirilerek okunur.
  final List<String> texts;
  final double iconSize;
  final Color? color;
  final String? tooltip;

  const TtsReadButton({
    super.key,
    required this.texts,
    this.iconSize = 26,
    this.color,
    this.tooltip,
  });

  @override
  State<TtsReadButton> createState() => _TtsReadButtonState();
}

class _TtsReadButtonState extends State<TtsReadButton> {
  bool _speaking = false;

  Future<void> _toggle() async {
    if (_speaking) {
      await AccessibilityService.instance.stop();
      if (mounted) setState(() => _speaking = false);
    } else {
      setState(() => _speaking = true);
      await AccessibilityService.instance.speakAll(widget.texts);
      if (mounted) setState(() => _speaking = false);
    }
  }

  @override
  void dispose() {
    if (_speaking) AccessibilityService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: widget.tooltip ?? (_speaking ? 'Okumayı Durdur' : 'Sesli Oku'),
      icon: Icon(
        _speaking ? Icons.stop_circle_outlined : Icons.volume_up_rounded,
        size: widget.iconSize,
        color: widget.color ??
            (_speaking ? YanYanaColors.sos : YanYanaColors.primary),
      ),
      onPressed: _toggle,
    );
  }
}

/// TextField'e sesli yazdırma butonu.
/// TextField'in suffix icon'u olarak ya da yanında kullanılır.
class VoiceMicButton extends StatefulWidget {
  final TextEditingController controller;
  final double size;
  final Color? activeColor;

  const VoiceMicButton({
    super.key,
    required this.controller,
    this.size = 24,
    this.activeColor,
  });

  @override
  State<VoiceMicButton> createState() => _VoiceMicButtonState();
}

class _VoiceMicButtonState extends State<VoiceMicButton>
    with SingleTickerProviderStateMixin {
  bool _listening = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    if (_listening) AccessibilityService.instance.stopListening();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_listening) {
      await AccessibilityService.instance.stopListening();
      _pulseCtrl.stop();
      if (mounted) setState(() => _listening = false);
    } else {
      final started = await AccessibilityService.instance.startListening(
        onResult: (text) {
          if (mounted) widget.controller.text = text;
        },
        onDone: (finalText) {
          if (mounted) {
            widget.controller.text = finalText;
            setState(() => _listening = false);
            _pulseCtrl.stop();
          }
        },
      );
      if (mounted) {
        setState(() => _listening = started);
        if (started) _pulseCtrl.repeat(reverse: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final scale = _listening ? (0.9 + _pulseCtrl.value * 0.2) : 1.0;
        return GestureDetector(
          onTap: _toggle,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              _listening
                  ? Icons.hearing_rounded
                  : Icons.keyboard_voice_rounded,
              size: widget.size,
              color: _listening
                  ? (widget.activeColor ?? YanYanaColors.sos)
                  : YanYanaColors.textLight,
            ),
          ),
        );
      },
    );
  }
}

/// Büyük sesli okuma floating butonu — ekran altına yerleştirilir.
/// Disabled kullanıcılar için tüm sayfa içeriğini okur.
class AccessibilityFab extends StatefulWidget {
  final List<String> textsToRead;
  final String? readLabel;

  const AccessibilityFab({
    super.key,
    required this.textsToRead,
    this.readLabel,
  });

  @override
  State<AccessibilityFab> createState() => _AccessibilityFabState();
}

class _AccessibilityFabState extends State<AccessibilityFab> {
  bool _speaking = false;

  Future<void> _toggle() async {
    if (_speaking) {
      await AccessibilityService.instance.stop();
      if (mounted) setState(() => _speaking = false);
    } else {
      setState(() => _speaking = true);
      await AccessibilityService.instance.speakAll(widget.textsToRead);
      if (mounted) setState(() => _speaking = false);
    }
  }

  @override
  void dispose() {
    if (_speaking) AccessibilityService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'tts_fab',
      onPressed: _toggle,
      backgroundColor: _speaking ? YanYanaColors.sos : YanYanaColors.accentBlue,
      icon: Icon(
        _speaking ? Icons.stop_rounded : Icons.record_voice_over_rounded,
        color: Colors.white,
      ),
      label: Text(
        _speaking
            ? 'Okumayı Durdur'
            : (widget.readLabel ?? 'Sayfayı Sesli Oku'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
