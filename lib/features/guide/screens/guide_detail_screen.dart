import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/accessibility_service.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/guide_service.dart';
import 'package:yanyana_p/core/services/guide_local_progress_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/widgets/accessibility_widgets.dart';
import '../models/guide_model.dart';

class GuideDetailScreen extends StatefulWidget {
  final Guide guide;
  const GuideDetailScreen({super.key, required this.guide});

  @override
  State<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends State<GuideDetailScreen> {
  bool _canModerate = false;
  bool _isDisabledUser = false;
  bool _isApproving = false;
  bool _isLiking = false;
  String _currentUserId = '';

  // Local state
  bool _hasLikedLocal = false;
  List<String> _completedStepIds = [];

  @override
  void initState() {
    super.initState();
    final user = AuthService.instance.currentUser;
    _canModerate = user != null && 
        (user.isStaff || user.userType == AppUserType.volunteer);
    _isDisabledUser = user?.userType == AppUserType.disabledUser;
    _currentUserId = user?.id ?? '';

    _loadLocalProgress();
  }

  Future<void> _loadLocalProgress() async {
    final progressService = GuideLocalProgressService.instance;
    final hasLiked = await progressService.hasLikedGuide(widget.guide.id);
    final completed = await progressService.getCompletedSteps(widget.guide.id);
    
    if (mounted) {
      setState(() {
        _hasLikedLocal = hasLiked;
        _completedStepIds = completed;
      });
    }
  }

  @override
  void dispose() {
    AccessibilityService.instance.stop();
    super.dispose();
  }

  void _toggleStepCompleted(GuideStep step) {
    setState(() {
      step.isCompleted = !step.isCompleted;
      widget.guide.completedStepsCount =
          widget.guide.steps.where((s) => s.isCompleted).length;
    });
  }

  Future<void> _approveGuide() async {
    setState(() => _isApproving = true);
    try {
      await GuideService.instance.approveGuide(widget.guide.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rehber onaylandı ve yayına alındı!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isApproving = false);
    }
  }

  Future<void> _rejectGuide() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rehberi Reddet'),
        content: const Text('Bu rehber silinecek. Emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reddet',
                style: TextStyle(color: YanYanaColors.sos)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await GuideService.instance.rejectGuide(widget.guide.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rehber reddedildi ve silindi.')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  Future<void> _likeGuide() async {
    if (_hasLikedLocal) return; // Zaten beğenmiş

    setState(() => _isLiking = true);
    try {
      await GuideService.instance.likeGuide(widget.guide.id);
      await GuideLocalProgressService.instance.saveLike(widget.guide.id);
      
      if (mounted) {
        setState(() {
          widget.guide.likes++;
          _hasLikedLocal = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Beğenilirken hata oluştu.')));
      }
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  void _onStepCompleted(String stepId, bool isCompleted) async {
    await GuideLocalProgressService.instance.toggleStepComplete(widget.guide.id, stepId, isCompleted);
    
    setState(() {
      if (isCompleted) {
        if (!_completedStepIds.contains(stepId)) _completedStepIds.add(stepId);
      } else {
        _completedStepIds.remove(stepId);
      }
    });

    // Bütün adımlar tamamlandı mı kontrolü
    if (isCompleted && _completedStepIds.length == widget.guide.steps.length) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [YanYanaColors.surface, Color(0xFFF0FFF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 80),
                const SizedBox(height: 16),
                const Text('Harika İş Çıkardın!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: YanYanaColors.textDark)),
                const SizedBox(height: 8),
                Text('"${widget.guide.title}" rehberindeki tüm adımları başarıyla tamamladın.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: YanYanaColors.textMuted)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'Teşekkürler!',
                    icon: Icons.check_circle_outline,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tüm rehber içeriğini TTS ile okutacak metin listesi
  List<String> get _fullPageTexts {
    final texts = <String>[
      widget.guide.title,
      widget.guide.description,
      '${widget.guide.steps.length} adım var.',
    ];
    for (var i = 0; i < widget.guide.steps.length; i++) {
      final s = widget.guide.steps[i];
      texts.add('Adım ${i + 1}: ${s.title}. ${s.description}');
    }
    return texts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        title: Text(widget.guide.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: YanYanaColors.textDark,
                fontSize: 18)),
        iconTheme: const IconThemeData(color: YanYanaColors.textDark),
        elevation: 0,
        actions: [
          // Tüm sayfayı sesli oku
          TtsReadButton(
            texts: _fullPageTexts,
            tooltip: 'Rehberi Sesli Oku',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.guide.coverImageUrl != null)
              Image.network(
                widget.guide.coverImageUrl!,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderHeader(),
              )
            else
              _placeholderHeader(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Moderasyon bandı — Yetkili veya Gönüllü (kendisi yazmadıysa)
                  if (!widget.guide.isApproved && _canModerate)
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: YanYanaColors.warning.withValues(alpha: 0.1),
                        border: Border.all(
                            color: YanYanaColors.warning, width: 1.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: YanYanaColors.warning, size: 24),
                              SizedBox(width: 8),
                              Text('Moderasyon Bekliyor',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                      color: YanYanaColors.warning)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                              'Bu içerik henüz yayında değil.',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: YanYanaColors.textDark)),
                          const SizedBox(height: 14),
                          
                          if (_currentUserId == widget.guide.authorId)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: YanYanaColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: YanYanaColors.border)
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline, color: YanYanaColors.primary, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Kendi oluşturduğunuz rehberi onaylayamazsınız. Başka bir gönüllü veya yetkilinin onaylaması bekleniyor.',
                                      style: TextStyle(fontSize: 12, color: YanYanaColors.textDark),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: _isApproving
                                      ? const Center(
                                          child: CircularProgressIndicator())
                                      : GradientButton(
                                          height: 48,
                                          label: 'Onayla',
                                          icon: Icons.check_rounded,
                                          gradient: const LinearGradient(colors: [
                                            YanYanaColors.success,
                                            Color(0xFF16A34A),
                                          ]),
                                          onPressed: _approveGuide,
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GradientButton(
                                    height: 48,
                                    label: 'Reddet',
                                    icon: Icons.close_rounded,
                                    gradient: const LinearGradient(colors: [
                                      YanYanaColors.sos,
                                      Colors.redAccent,
                                    ]),
                                    onPressed: _rejectGuide,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                  // Yazar
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: YanYanaColors.textLight),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.guide.authorName} · ${widget.guide.authorRole}',
                        style: const TextStyle(
                            fontSize: 13, color: YanYanaColors.textLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(widget.guide.title,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: YanYanaColors.textDark)),
                  const SizedBox(height: 12),
                  Text(widget.guide.description,
                      style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: YanYanaColors.textMuted)),

                  const SizedBox(height: 24),

                  // İlerleme barı
                  LinearProgressIndicator(
                    value: widget.guide.progressPercentage,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: YanYanaColors.surfaceSoft,
                    color: YanYanaColors.success,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.guide.completedStepsCount} / ${widget.guide.steps.length} Adım Tamamlandı',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: YanYanaColors.success,
                        fontSize: 14),
                  ),

                  // Engelli kullanıcı için adımları sesli oku butonu
                  if (_isDisabledUser) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final stepTexts = widget.guide.steps.asMap().entries
                            .map((e) =>
                                'Adım ${e.key + 1}: ${e.value.title}. ${e.value.description}')
                            .toList();
                        AccessibilityService.instance.speakAll(stepTexts);
                      },
                      icon: const Icon(Icons.record_voice_over_rounded,
                          color: YanYanaColors.accentBlue),
                      label: const Text('Tüm Adımları Sesli Oku',
                          style: TextStyle(color: YanYanaColors.accentBlue)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: YanYanaColors.accentBlue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  const Text('Adımlar',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: YanYanaColors.textDark)),
                  const SizedBox(height: 16),

                  ...widget.guide.steps.asMap().entries.map(
                        (entry) =>
                            _buildStepCard(entry.value, entry.key + 1),
                      ),

                  const SizedBox(height: 32),

                  Center(
                    child: Column(
                      children: [
                        const Text(
                          'Bu rehber sana yardımcı oldu mu?',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: YanYanaColors.textDark),
                        ),
                        const SizedBox(height: 16),
                        GradientButton(
                          label: 'Evet, faydalı (${widget.guide.likes})',
                          icon: Icons.thumb_up_alt_rounded,
                          gradient: supportGradient,
                          onPressed: _likeGuide,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderHeader() {
    return Container(
      height: 200,
      color: YanYanaColors.primaryLight,
      child: const Icon(Icons.menu_book, size: 80, color: YanYanaColors.primary),
    );
  }

  Widget _buildStepCard(GuideStep step, int stepNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: step.isCompleted
            ? YanYanaColors.surfaceSoft
            : YanYanaColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: step.isCompleted
            ? Border.all(
                color: YanYanaColors.success.withValues(alpha: 0.5), width: 2)
            : Border.all(color: Colors.transparent, width: 2),
        boxShadow: step.isCompleted ? [] : YanYanaShadows.soft,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: step.isCompleted
                      ? YanYanaColors.success
                      : YanYanaColors.primaryLight,
                  child: Text(
                    stepNumber.toString(),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: step.isCompleted
                            ? Colors.white
                            : YanYanaColors.primary),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      decoration:
                          step.isCompleted ? TextDecoration.lineThrough : null,
                      color: step.isCompleted
                          ? YanYanaColors.textLight
                          : YanYanaColors.textDark,
                    ),
                  ),
                ),
                // TTS: Bu adımı sesli oku (gerçek TTS)
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 28),
                  color: YanYanaColors.accentBlue,
                  tooltip: 'Sesli Oku',
                  onPressed: () {
                    AccessibilityService.instance.speak(
                        'Adım $stepNumber: ${step.title}. ${step.description}');
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (step.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(step.imageUrl!,
                      height: 180, width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            Text(
              step.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: step.isCompleted
                    ? YanYanaColors.textLight
                    : YanYanaColors.textMuted,
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              height: 50,
              label: step.isCompleted
                  ? 'Adımı Tamamladım ✓'
                  : 'Bu Adımı Yaptım',
              icon: step.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              gradient: step.isCompleted
                  ? const LinearGradient(
                      colors: [YanYanaColors.success, Color(0xFF16A34A)])
                  : primaryGradient,
              onPressed: () => _toggleStepCompleted(step),
            ),
          ],
        ),
      ),
    );
  }
}
