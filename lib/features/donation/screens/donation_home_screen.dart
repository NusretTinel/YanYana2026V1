import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/donation_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/widgets/accessibility_widgets.dart';
import '../models/donation_model.dart';
import 'sponsor_list_screen.dart';
import 'donation_payment_screen.dart';
import 'donation_create_screen.dart';

class DonationHomeScreen extends StatelessWidget {
  const DonationHomeScreen({super.key});

  bool get _isStaff => AuthService.instance.currentUser?.isStaff ?? false;

  bool get _isDisabledUser =>
      AuthService.instance.currentUser?.userType == AppUserType.disabledUser;

  bool get _canCreate {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;
    return user.isStaff || user.userType == AppUserType.volunteer;
  }

  List<String> _buildTtsTexts(List<DonationCampaign> campaigns) {
    final buffer = <String>[
      'Bağış sayfası. ${campaigns.length} kampanya bulunuyor.',
    ];
    for (final c in campaigns.take(5)) {
      buffer.add(
          '${c.title}. Hedef: ${c.targetAmount.toInt()} Türk Lirası. Toplanan: ${c.collectedAmount.toInt()} Türk Lirası.');
    }
    return buffer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Moderatör bandı
          if (_isStaff)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: YanYanaColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: YanYanaColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded,
                      color: YanYanaColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${AuthService.instance.currentUser?.authRoleLabel ?? 'Yetkili'} görünümü — Beklemedekiler dahil',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: YanYanaColors.warning),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Sponsorlar kartı
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SponsorListScreen())),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: supportGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: YanYanaShadows.soft,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.diversity_1, color: Colors.white, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Destekçilerimiz',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          Text('Bize güç katan sponsorlarımızı görün',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Güncel Kampanyalar',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: YanYanaColors.textDark)),
            ),
          ),
          const SizedBox(height: 8),

          // Kampanya listesi
          Expanded(
            child: StreamBuilder<List<DonationCampaign>>(
              stream: _isStaff
                  ? DonationService.instance.streamAllCampaigns()
                  : DonationService.instance.streamPublicCampaigns(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded,
                              size: 48, color: YanYanaColors.textLight),
                          const SizedBox(height: 12),
                          const Text('Veriler yüklenirken sorun oluştu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: YanYanaColors.textDark,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: YanYanaColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }

                final campaigns = snapshot.data ?? [];

                if (campaigns.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volunteer_activism_outlined,
                            size: 60, color: YanYanaColors.textLight),
                        SizedBox(height: 12),
                        Text('Henüz aktif kampanya yok.',
                            style: TextStyle(color: YanYanaColors.textMuted)),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: campaigns.length,
                      itemBuilder: (context, index) =>
                          _buildCampaignCard(context, campaigns[index]),
                    ),
                    // Engelli kullanıcı için tüm kampanyaları sesli oku
                    if (_isDisabledUser)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: AccessibilityFab(
                          textsToRead: _buildTtsTexts(campaigns),
                          readLabel: 'Kampanyaları Sesli Oku',
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _canCreate
          ? FloatingActionButton.extended(
              heroTag: 'donation_create_fab',
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DonationCreateScreen())),
              backgroundColor: YanYanaColors.secondary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Yeni Kampanya',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildCampaignCard(
      BuildContext context, DonationCampaign campaign) {
    final bool isPending = campaign.status == CampaignStatus.pending;
    final bool isRejected = campaign.status == CampaignStatus.rejected;
    final bool isCompleted = campaign.status == CampaignStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: YanYanaShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kapak
          if (campaign.coverImageUrl != null)
            Image.network(campaign.coverImageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    height: 140, color: YanYanaColors.secondaryLight,
                    child: const Icon(Icons.volunteer_activism,
                        size: 50, color: YanYanaColors.secondary)))
          else
            Container(
              height: 140,
              color: YanYanaColors.secondaryLight,
              child: const Icon(Icons.volunteer_activism,
                  size: 50, color: YanYanaColors.secondary),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Durum badge
                if (isPending)
                  _statusBadge('Moderatör Onayı Bekliyor', YanYanaColors.warning)
                else if (isRejected)
                  _statusBadge('Reddedildi', YanYanaColors.sos)
                else if (isCompleted)
                  _statusBadge('Hedefe Ulaşıldı! 🎉', YanYanaColors.success),

                Row(
                  children: [
                    Expanded(
                      child: Text(campaign.title,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: YanYanaColors.textDark)),
                    ),
                    // TTS butonu her kartta
                    TtsReadButton(
                      texts: [
                        '${campaign.title}. ${campaign.description}. '
                            'Hedef: ${campaign.targetAmount.toInt()} Türk Lirası. '
                            'Toplanan: ${campaign.collectedAmount.toInt()} Türk Lirası.'
                      ],
                      iconSize: 22,
                      tooltip: 'Sesli Oku',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(campaign.description,
                    style: const TextStyle(
                        fontSize: 14,
                        color: YanYanaColors.textMuted,
                        height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 16),

                LinearProgressIndicator(
                  value: campaign.progressPercentage,
                  minHeight: 8,
                  backgroundColor: YanYanaColors.surfaceSoft,
                  color: isCompleted
                      ? YanYanaColors.success
                      : YanYanaColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${campaign.collectedAmount.toInt()} ₺ toplandı',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: YanYanaColors.textDark,
                            fontSize: 13)),
                    Text('Hedef: ${campaign.targetAmount.toInt()} ₺',
                        style: const TextStyle(
                            color: YanYanaColors.textMuted, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),

                if (isPending && _isStaff)
                  _ApproveRejectButtons(campaignId: campaign.id)
                else if (!isCompleted && !isRejected && !isPending)
                  GradientButton(
                    label: 'Şimdi Bağış Yap',
                    icon: Icons.favorite,
                    gradient: primaryGradient,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              DonationPaymentScreen(campaign: campaign)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(bottom: 10),
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _ApproveRejectButtons extends StatefulWidget {
  final String campaignId;
  const _ApproveRejectButtons({required this.campaignId});

  @override
  State<_ApproveRejectButtons> createState() => _ApproveRejectButtonsState();
}

class _ApproveRejectButtonsState extends State<_ApproveRejectButtons> {
  bool _loading = false;

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      await DonationService.instance.approveCampaign(widget.campaignId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Kampanya onaylandı ve yayına alındı!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _loading = true);
    try {
      await DonationService.instance.rejectCampaign(widget.campaignId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kampanya reddedildi.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            label: 'Onayla',
            icon: Icons.check_rounded,
            gradient: const LinearGradient(
                colors: [YanYanaColors.success, Color(0xFF16A34A)]),
            onPressed: _approve,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GradientButton(
            label: 'Reddet',
            icon: Icons.close_rounded,
            gradient: const LinearGradient(
                colors: [YanYanaColors.sos, Colors.redAccent]),
            onPressed: _reject,
          ),
        ),
      ],
    );
  }
}
