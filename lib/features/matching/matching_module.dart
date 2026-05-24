import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/models/support_request.dart';

/// Support request flow: RequestManager → Firestore + MatchingEngine.
class MatchingModulePage extends StatefulWidget {
  const MatchingModulePage({super.key});

  @override
  State<MatchingModulePage> createState() => _MatchingModulePageState();
}

class _MatchingModulePageState extends State<MatchingModulePage> {
  final _descCtrl = TextEditingController();
  final _orchestrator = BackendOrchestrator.instance;

  static const _types = [
    'Ulaşım Desteği',
    'Okuma Desteği',
    'Sosyal Destek',
    'Acil Destek',
    'Mentorluk',
  ];

  String _selectedType = _types.first;
  bool _busy = false;
  String? _lastResult;

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _findVolunteer() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _lastResult = null;
    });
    final user = _orchestrator.getCurrentUser();
    if (user == null) {
      setState(() => _busy = false);
      return;
    }
    final desc = _descCtrl.text.trim().isEmpty
        ? 'Kısa destek ihtiyacı.'
        : _descCtrl.text.trim();

    final req = SupportRequest(
      id: 'mr_${DateTime.now().millisecondsSinceEpoch}',
      requesterName: user.name,
      requestType: _selectedType,
      description: desc,
      status: 'Açık',
      assignedVolunteerName: null,
    );

    final updated = await _orchestrator.createSupportRequest(req);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _lastResult =
          'Eşleşen gönüllü: ${updated.assignedVolunteerName ?? '-'} · Durum: ${updated.status}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Talep kaydedildi. ${_lastResult!}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _orchestrator.getCurrentUser();
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        elevation: 0,
        title: const Text(
          'Gönüllü Eşleşmesi',
          style: TextStyle(
            color: YanYanaColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Destek İste',
                style: TextStyle(
                  color: YanYanaColors.textMuted.withValues(alpha: 0.95),
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'İhtiyaç türünü seç, kısa açıkla ve gönüllü eşleştirmesini başlat.',
                style: TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Destek türü',
                style: TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _types.map((t) {
                  final sel = t == _selectedType;
                  return ChoiceChip(
                    label: Text(t),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedType = t),
                    selectedColor: YanYanaColors.primary,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : YanYanaColors.textDark,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descCtrl,
                minLines: 2,
                maxLines: 4,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: YanYanaColors.textDark,
                ),
                decoration: InputDecoration(
                  labelText: 'Kısa açıklama',
                  hintText: 'Nasıl yardıma ihtiyacın var?',
                  filled: true,
                  fillColor: YanYanaColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: YanYanaColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(color: YanYanaColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                      color: YanYanaColors.primary,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: GradientButton(
                  label: _busy ? 'Eşleştiriliyor...' : 'Gönüllü Bul',
                  icon: Icons.volunteer_activism_rounded,
                  isLoading: _busy,
                  gradient: supportGradient,
                  onPressed: _busy ? () {} : _findVolunteer,
                ),
              ),
              if (_lastResult != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: YanYanaColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: YanYanaColors.border),
                  ),
                  child: Text(
                    _lastResult!,
                    style: const TextStyle(
                      color: YanYanaColors.textDark,
                      fontSize: 14,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: calmGradient,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: YanYanaColors.border),
                ),
                child: const Text(
                  'Akış (hedef mimari): Kullanıcı → RequestManager → '
                  'MatchingEngine → NotificationDispatcher. Bu ekranda '
                  'Talepler Firestore\'a kaydedilir ve eşleştirme sonucu bildirim oluşturulur.',
                  style: TextStyle(
                    color: YanYanaColors.textDark,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (user != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Kullanıcı: ${user.name}',
                  style: const TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
