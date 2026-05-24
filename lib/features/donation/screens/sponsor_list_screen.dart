import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/donation_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/widgets/accessibility_widgets.dart';
import '../models/donation_model.dart';

class SponsorListScreen extends StatefulWidget {
  const SponsorListScreen({super.key});

  @override
  State<SponsorListScreen> createState() => _SponsorListScreenState();
}

class _SponsorListScreenState extends State<SponsorListScreen> {
  bool get _isDisabledUser =>
      AuthService.instance.currentUser?.userType == AppUserType.disabledUser;

  List<TopDonor> _topDonors = [];
  bool _donorsLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopDonors();
  }

  Future<void> _loadTopDonors() async {
    try {
      final donors = await DonationService.instance.getTopDonors();
      if (mounted) {
        setState(() {
          _topDonors = donors;
          _donorsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _donorsLoading = false);
      }
    }
  }

  List<String> _buildTtsTexts(List<Sponsor> sponsors) {
    final buffer = <String>['Destekçilerimiz ve Bağışçılarımız.'];
    
    buffer.add('Kurumsal Sponsorlarımız:');
    if (sponsors.isEmpty) {
      buffer.add('Şu an listelenecek sponsor bulunmuyor.');
    } else {
      for (var s in sponsors) {
        final tierName = s.tier == 1
            ? 'Platin'
            : s.tier == 2
                ? 'Altın'
                : 'Gümüş';
        buffer.add('$tierName sponsor: ${s.name}.');
      }
    }

    buffer.add('Bireysel Destekçilerimiz:');
    if (_topDonors.isEmpty) {
      buffer.add('Şu an listelenecek bireysel bağışçı bulunmuyor.');
    } else {
      for (var i = 0; i < _topDonors.length; i++) {
        final d = _topDonors[i];
        buffer.add('${i + 1}. sırada ${d.disabilityFriendlyTitle} unvanıyla ${d.userName}. Toplam bağışı: ${d.totalAmount.toInt()} Türk Lirası.');
      }
    }
    return buffer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      appBar: AppBar(
        backgroundColor: YanYanaColors.surface,
        title: const Text('Destekçilerimiz',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: YanYanaColors.textDark,
                fontSize: 18)),
        iconTheme: const IconThemeData(color: YanYanaColors.textDark),
        elevation: 0,
      ),
      body: StreamBuilder<List<Sponsor>>(
        stream: DonationService.instance.streamSponsors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _donorsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final sponsors = snapshot.data ?? [];

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kurumsal Sponsorlar
                    const Row(
                      children: [
                        Icon(Icons.business, color: YanYanaColors.primary),
                        SizedBox(width: 8),
                        Text('Kurumsal Sponsorlar',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: YanYanaColors.textDark)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (sponsors.isEmpty)
                      const Text('Henüz sponsor bulunmuyor.',
                          style: TextStyle(color: YanYanaColors.textMuted))
                    else
                      ...sponsors.map((s) => _buildSponsorCard(s)),

                    const SizedBox(height: 32),
                    
                    // Bireysel Bağışçılar
                    const Row(
                      children: [
                        Icon(Icons.volunteer_activism, color: YanYanaColors.sos),
                        SizedBox(width: 8),
                        Text('Bireysel Destekçilerimiz',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: YanYanaColors.textDark)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Topluluğumuza en çok katkı sağlayan iyilik melekleri',
                        style: TextStyle(color: YanYanaColors.textMuted, fontSize: 13)),
                    const SizedBox(height: 16),

                    if (_donorsLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_topDonors.isEmpty)
                      const Text('Henüz bağışçı bulunmuyor.',
                          style: TextStyle(color: YanYanaColors.textMuted))
                    else
                      ..._topDonors.asMap().entries.map((e) => _buildDonorCard(e.value, e.key + 1)),
                  ],
                ),
              ),
              
              if (_isDisabledUser)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: AccessibilityFab(
                    textsToRead: _buildTtsTexts(sponsors),
                    readLabel: 'Tüm Listeyi Sesli Oku',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSponsorCard(Sponsor sponsor) {
    final isPlatin = sponsor.tier == 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: isPlatin
            ? Border.all(color: YanYanaColors.primary, width: 2)
            : null,
        boxShadow: YanYanaShadows.soft,
      ),
      child: Row(
        children: [
          if (sponsor.logoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(sponsor.logoUrl!,
                  width: 60, height: 60, fit: BoxFit.cover),
            )
          else
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: YanYanaColors.primaryLight,
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.business,
                  color: YanYanaColors.primary),
            ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sponsor.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: YanYanaColors.textDark)),
                const SizedBox(height: 4),
                Text(
                  isPlatin
                      ? 'Platin Sponsor'
                      : sponsor.tier == 2
                          ? 'Altın Sponsor'
                          : 'Gümüş Sponsor',
                  style: TextStyle(
                      fontSize: 13,
                      color: isPlatin
                          ? YanYanaColors.primary
                          : YanYanaColors.textMuted,
                      fontWeight: isPlatin
                          ? FontWeight.bold
                          : FontWeight.normal),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonorCard(TopDonor donor, int rank) {
    // İlk 3'e özel madalya renkleri
    Color rankColor;
    if (rank == 1) rankColor = const Color(0xFFFFD700); // Altın
    else if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Gümüş
    else if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronz
    else rankColor = YanYanaColors.primaryLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: rank <= 3 ? LinearGradient(
          colors: [rankColor.withValues(alpha: 0.1), YanYanaColors.surface],
        ) : null,
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: rank <= 3 ? Border.all(color: rankColor, width: 1.5) : Border.all(color: YanYanaColors.border),
        boxShadow: YanYanaShadows.soft,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rankColor,
            radius: 20,
            child: Text(
              '$rank',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: rank <= 3 ? Colors.black87 : YanYanaColors.primaryDark),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(donor.userName,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: YanYanaColors.textDark)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 14, color: YanYanaColors.sos),
                    const SizedBox(width: 4),
                    Text(
                      donor.disabilityFriendlyTitle,
                      style: const TextStyle(
                          fontSize: 13,
                          color: YanYanaColors.sos,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Toplam Destek', style: TextStyle(fontSize: 10, color: YanYanaColors.textLight)),
              Text(
                '${donor.totalAmount.toInt()} ₺',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: YanYanaColors.primary),
              ),
            ],
          )
        ],
      ),
    );
  }
}
