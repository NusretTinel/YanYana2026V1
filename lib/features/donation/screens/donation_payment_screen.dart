import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/donation_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/widgets/accessibility_widgets.dart';
import '../models/donation_model.dart';

class DonationPaymentScreen extends StatefulWidget {
  final DonationCampaign campaign;

  const DonationPaymentScreen({super.key, required this.campaign});

  @override
  State<DonationPaymentScreen> createState() => _DonationPaymentScreenState();
}

class _DonationPaymentScreenState extends State<DonationPaymentScreen> {
  final _amountCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _completeDonation() async {
    final amountText = _amountCtrl.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen bir miktar girin.')));
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geçerli bir tutar girin.')));
      return;
    }

    final user = AuthService.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Bağış yapmak için giriş yapmalısınız.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await DonationService.instance.makeDonation(
        campaignId: widget.campaign.id,
        userId: user.id,
        userName: user.name,
        amount: amount,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Teşekkürler ${user.name}! ${widget.campaign.title} için $amount ₺ bağışınız alındı.'),
            backgroundColor: YanYanaColors.success,
            duration: const Duration(seconds: 3),
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
        title: const Text('Bağış Yap',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: YanYanaColors.textDark,
                fontSize: 18)),
        iconTheme: const IconThemeData(color: YanYanaColors.textDark),
        elevation: 0,
        actions: [
          TtsReadButton(
            texts: [
              'Bağış yapma ekranı.',
              widget.campaign.title,
              'Şu ana kadar toplanan tutar: ${widget.campaign.collectedAmount.toInt()} Türk Lirası.',
              'Hedef: ${widget.campaign.targetAmount.toInt()} Türk Lirası.',
              'Bağış miktarını yazarak veya sesli komutla girebilirsiniz.',
            ],
            tooltip: 'Sayfayı Sesli Anlat',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kampanya özeti
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: YanYanaColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: YanYanaShadows.soft,
              ),
              child: Column(
                children: [
                  const Icon(Icons.favorite,
                      color: YanYanaColors.sos, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    widget.campaign.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: YanYanaColors.textDark),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Desteğinizle birilerinin hayatına dokunuyorsunuz.',
                    style: TextStyle(
                        color: YanYanaColors.textMuted, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: widget.campaign.progressPercentage,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: YanYanaColors.surfaceSoft,
                    color: YanYanaColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.campaign.collectedAmount.toInt()} ₺',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: YanYanaColors.primary),
                      ),
                      Text(
                        'Hedef: ${widget.campaign.targetAmount.toInt()} ₺',
                        style: const TextStyle(color: YanYanaColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text('Bağış Miktarı (₺)',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: YanYanaColors.textDark)),
            const SizedBox(height: 12),

            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Miktar',
                hintText: 'Örn: 100',
                prefixIcon:
                    const Icon(Icons.payments, color: YanYanaColors.primary),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: VoiceMicButton(controller: _amountCtrl),
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
                  borderSide:
                      const BorderSide(color: YanYanaColors.primary, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Hızlı tutar seçici
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['50', '100', '200', '500']
                  .map((amt) => ActionChip(
                        label: Text('$amt ₺',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                        backgroundColor: YanYanaColors.primaryLight,
                        onPressed: () =>
                            setState(() => _amountCtrl.text = amt),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 40),

            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : GradientButton(
                    label: 'Bağışı Tamamla',
                    icon: Icons.check_circle_outline,
                    onPressed: _completeDonation,
                  ),
          ],
        ),
      ),
    );
  }
}
