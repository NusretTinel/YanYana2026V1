import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/guide_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/widgets/accessibility_widgets.dart';
import '../models/guide_model.dart';

class GuideCreateScreen extends StatefulWidget {
  const GuideCreateScreen({super.key});

  @override
  State<GuideCreateScreen> createState() => _GuideCreateScreenState();
}

class _GuideCreateScreenState extends State<GuideCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  GuideCategory _category = GuideCategory.dailyTasks;

  final List<TextEditingController> _stepTitleCtrls = [TextEditingController()];
  final List<TextEditingController> _stepDescCtrls = [TextEditingController()];

  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    for (var c in _stepTitleCtrls) c.dispose();
    for (var c in _stepDescCtrls) c.dispose();
    super.dispose();
  }

  void _addStep() {
    setState(() {
      _stepTitleCtrls.add(TextEditingController());
      _stepDescCtrls.add(TextEditingController());
    });
  }

  void _removeStep(int index) {
    if (_stepTitleCtrls.length > 1) {
      setState(() {
        _stepTitleCtrls[index].dispose();
        _stepDescCtrls[index].dispose();
        _stepTitleCtrls.removeAt(index);
        _stepDescCtrls.removeAt(index);
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final hasStep = _stepTitleCtrls.any((c) => c.text.trim().isNotEmpty);
    if (!hasStep) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('En az bir adım eklemelisiniz.')));
      return;
    }
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final steps = List.generate(_stepTitleCtrls.length, (i) => {
            'title': _stepTitleCtrls[i].text.trim(),
            'description': _stepDescCtrls[i].text.trim(),
          }).where((s) => s['title']!.isNotEmpty).toList();

      String roleLabel = 'Kullanıcı';
      if (user.isAdmin) roleLabel = 'Admin';
      else if (user.isModerator) roleLabel = 'Moderatör';
      else if (user.userType == AppUserType.volunteer) roleLabel = 'Gönüllü';
      else if (user.userType == AppUserType.disabledUser) roleLabel = 'Kullanıcı';

      await GuideService.instance.createGuide(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        steps: steps,
        authorId: user.id,
        authorName: user.name,
        authorRole: roleLabel,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Rehber başarıyla oluşturuldu! Moderatör onayından sonra yayına alınacak.'),
          duration: Duration(seconds: 4),
        ));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        title: const Text('Yeni Rehber Oluştur',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: YanYanaColors.textDark,
                fontSize: 18)),
        iconTheme: const IconThemeData(color: YanYanaColors.textDark),
        elevation: 0,
        actions: [
          // Formu sesli oku (engelli kullanıcılar için)
          TtsReadButton(
            texts: const [
              'Yeni rehber oluşturma ekranı.',
              'Başlık ve açıklama giriniz.',
              'Ardından adımları ekleyiniz.',
              'Rehberiniz moderatör onayından sonra yayına alınacak.',
            ],
            tooltip: 'Sayfayı Sesli Anlat',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rehber Bilgileri',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: YanYanaColors.textDark)),
              const SizedBox(height: 16),

              // Başlık — STT destekli
              _voiceTextField(
                controller: _titleCtrl,
                label: 'Rehber Başlığı',
                hint: 'Örn: Otobüse Nasıl Binilir?',
                icon: Icons.title,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Başlık zorunludur'
                    : null,
              ),
              const SizedBox(height: 16),

              // Açıklama — STT destekli
              _voiceTextField(
                controller: _descCtrl,
                label: 'Kısa Açıklama',
                hint: 'Rehberin amacını anlatın',
                icon: Icons.description,
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Açıklama zorunludur'
                    : null,
              ),
              const SizedBox(height: 16),

              // Kategori
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: YanYanaColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: YanYanaColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<GuideCategory>(
                    value: _category,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down,
                        color: YanYanaColors.primary),
                    style: const TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                    items: const [
                      DropdownMenuItem(
                          value: GuideCategory.dailyTasks,
                          child: Text('Günlük İşler')),
                      DropdownMenuItem(
                          value: GuideCategory.recipes,
                          child: Text('Yemek Tarifleri')),
                      DropdownMenuItem(
                          value: GuideCategory.socialSkills,
                          child: Text('Sosyal Beceriler')),
                      DropdownMenuItem(
                          value: GuideCategory.other, child: Text('Diğer')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Text('Adımlar',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: YanYanaColors.textDark)),
              const SizedBox(height: 4),
              const Text(
                'Her adım için başlık ve açıklama yazabilir ya da mikrofon butonuna basarak sesle girebilirsiniz.',
                style:
                    TextStyle(fontSize: 13, color: YanYanaColors.textMuted),
              ),
              const SizedBox(height: 16),

              ...List.generate(_stepTitleCtrls.length, (idx) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: YanYanaColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: YanYanaColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: YanYanaColors.primaryLight,
                            child: Text('${idx + 1}',
                                style: const TextStyle(
                                    color: YanYanaColors.primary,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('Adım ${idx + 1}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: YanYanaColors.textDark)),
                          ),
                          if (_stepTitleCtrls.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: YanYanaColors.sos),
                              onPressed: () => _removeStep(idx),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _voiceTextField(
                        controller: _stepTitleCtrls[idx],
                        label: 'Adım Başlığı',
                        hint: 'Örn: Suyu Kaynat',
                        icon: Icons.format_list_numbered,
                      ),
                      const SizedBox(height: 10),
                      _voiceTextField(
                        controller: _stepDescCtrls[idx],
                        label: 'Adım Açıklaması',
                        hint: 'Bu adımda ne yapılacağını açıklayın',
                        icon: Icons.notes,
                        maxLines: 2,
                      ),
                    ],
                  ),
                );
              }),

              TextButton.icon(
                onPressed: _addStep,
                icon: const Icon(Icons.add_circle,
                    color: YanYanaColors.secondary),
                label: const Text('Yeni Adım Ekle',
                    style: TextStyle(
                        color: YanYanaColors.secondary,
                        fontWeight: FontWeight.bold)),
              ),

              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GradientButton(
                      label: 'Rehberi Onaya Gönder',
                      icon: Icons.send_rounded,
                      onPressed: _submit,
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// TextField + sağ tarafta mikrofon (STT) butonu
  Widget _voiceTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: YanYanaColors.primary),
        // Mikrofon STT butonu
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: VoiceMicButton(controller: controller),
        ),
        filled: true,
        fillColor: YanYanaColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: YanYanaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: YanYanaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: YanYanaColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: YanYanaColors.textMuted),
      ),
    );
  }
}
