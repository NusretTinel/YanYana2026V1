import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/donation_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/widgets/accessibility_widgets.dart';

class DonationCreateScreen extends StatefulWidget {
  const DonationCreateScreen({super.key});

  @override
  State<DonationCreateScreen> createState() => _DonationCreateScreenState();
}

class _DonationCreateScreenState extends State<DonationCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetAmountCtrl = TextEditingController();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _targetAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final amount = double.tryParse(_targetAmountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geçerli bir tutar girin.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DonationService.instance.createCampaign(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        targetAmount: amount,
        endDate: _endDate,
        creatorId: user.id,
        creatorName: user.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Kampanya oluşturuldu! Moderatör onayından sonra yayına alınacak.'),
            duration: Duration(seconds: 4),
          ),
        );
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
        title: const Text('Yeni Kampanya Oluştur',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: YanYanaColors.textDark,
                fontSize: 18)),
        iconTheme: const IconThemeData(color: YanYanaColors.textDark),
        elevation: 0,
        actions: [
          TtsReadButton(
            texts: const [
              'Yeni kampanya oluşturma ekranı.',
              'Lütfen kampanya başlığını, açıklamasını ve hedeflenen tutarı giriniz.',
              'Bitiş tarihini seçtikten sonra kampanyanızı onaya gönderebilirsiniz.',
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
              const Text(
                'Kampanya Bilgileri',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: YanYanaColors.textDark),
              ),
              const SizedBox(height: 16),

              _voiceTextField(
                controller: _titleCtrl,
                label: 'Kampanya Başlığı',
                hint: 'Örn: Akülü Tekerlekli Sandalye Desteği',
                icon: Icons.title,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Başlık zorunludur' : null,
              ),
              const SizedBox(height: 16),

              _voiceTextField(
                controller: _descCtrl,
                label: 'Kampanya Açıklaması',
                hint: 'Kampanyanın amacını ve kime ulaşacağını anlatın',
                icon: Icons.description,
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Açıklama zorunludur'
                    : null,
              ),
              const SizedBox(height: 16),

              _voiceTextField(
                controller: _targetAmountCtrl,
                label: 'Hedeflenen Tutar (₺)',
                hint: 'Örn: 15000',
                icon: Icons.track_changes_rounded,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Tutar zorunludur';
                  if (double.tryParse(v.trim()) == null) {
                    return 'Geçerli sayı girin';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bitiş tarihi seçici
              GestureDetector(
                onTap: _pickEndDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 18),
                  decoration: BoxDecoration(
                    color: YanYanaColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: YanYanaColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: YanYanaColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kampanya Bitiş Tarihi',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: YanYanaColors.textMuted)),
                          const SizedBox(height: 2),
                          Text(
                            '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: YanYanaColors.textDark,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down,
                          color: YanYanaColors.primary),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: YanYanaColors.primaryLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: YanYanaColors.primaryLight),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: YanYanaColors.primary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Oluşturduğunuz kampanyalar, sistem güvenliği gereği yetkili adminler tarafından incelendikten sonra yayına alınır.',
                        style: TextStyle(
                            color: YanYanaColors.primaryDark,
                            fontSize: 13,
                            height: 1.4),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 40),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GradientButton(
                      label: 'Kampanyayı Onaya Gönder',
                      icon: Icons.send_rounded,
                      gradient: const LinearGradient(colors: [
                        YanYanaColors.secondary,
                        YanYanaColors.accentBlue,
                      ]),
                      onPressed: _submit,
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voiceTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: YanYanaColors.primary),
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
