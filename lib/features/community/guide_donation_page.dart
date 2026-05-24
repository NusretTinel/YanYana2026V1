import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/data/mock_data.dart';
import 'package:yanyana_p/features/guide/screens/guide_home_screen.dart';
import 'package:yanyana_p/features/donation/screens/donation_home_screen.dart';
class GuideDonationPage extends StatefulWidget {
  const GuideDonationPage({super.key});

  @override
  State<GuideDonationPage> createState() => _GuideDonationPageState();
}

class _GuideDonationPageState extends State<GuideDonationPage> {
  String _supportType = MockData.donationSupportTypes.first;
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: YanYanaColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rehber ve Bağış',
                      style: TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 52,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: YanYanaColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: YanYanaColors.border),
                      ),
                      child: TabBar(
                        indicator: BoxDecoration(
                          gradient: supportGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: YanYanaShadows.soft,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: YanYanaColors.textMuted,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Rehber'),
                          Tab(text: 'Bağış'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  children: [
                    const GuideHomeScreen(),
                    const DonationHomeScreen(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rehber ve Destek Kartları',
            style: TextStyle(
              color: YanYanaColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bu bölüm, kullanıcıların ihtiyaçlarını hızlı anlatabilmesi için destek kartları oluşturma fikrini prototip olarak gösterir.',
            style: TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ...MockData.guideCards.map(_GuideCardItem.new),
          const SizedBox(height: 16),
          _sectionCard(
            title: 'Kart oluşturma ilerlemesi',
            icon: Icons.insights_rounded,
            color: YanYanaColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '3 kart örneğinden 1’i tamamlandı (prototip).',
                  style: TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: 0.34,
                    minHeight: 10,
                    backgroundColor: YanYanaColors.surfaceSoft,
                    valueColor: const AlwaysStoppedAnimation(YanYanaColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: 'Rozetler ve Puanlar',
            icon: Icons.military_tech_rounded,
            color: YanYanaColors.accentPink,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _Pill(label: 'Rehber Başlangıç Rozeti', color: YanYanaColors.accentPink),
                _Pill(label: 'Destek Kartı Puanı: +20', color: YanYanaColors.secondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bağış ve Destek',
            style: TextStyle(
              color: YanYanaColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Bu prototipte gerçek ödeme yoktur. Seçim ve not alanı sadece MVP akışını göstermek içindir.',
            style: TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 13.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: 'Destek Türleri',
            icon: Icons.favorite_rounded,
            color: YanYanaColors.secondary,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: MockData.donationSupportTypes
                  .map((t) => _Pill(label: t, color: YanYanaColors.primary))
                  .toList(),
            ),
          ),
          const SizedBox(height: 14),
          _sectionCard(
            title: 'Destek niyeti formu',
            icon: Icons.edit_note_rounded,
            color: YanYanaColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _supportType,
                  items: MockData.donationSupportTypes
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _supportType = v ?? _supportType),
                  decoration: InputDecoration(
                    labelText: 'Destek türü',
                    filled: true,
                    fillColor: YanYanaColors.surfaceSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: YanYanaColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: YanYanaColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Not',
                    hintText: 'Kısa bir açıklama ekleyin',
                    filled: true,
                    fillColor: YanYanaColors.surfaceSoft,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: YanYanaColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: YanYanaColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'Gönder',
                    icon: Icons.check_circle_rounded,
                    gradient: supportGradient,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Teşekkürler. Gerçek ödeme işlemi yapılmadı; '
                            'niyetiniz yalnızca bu cihazda not olarak kaydedildi.',
                          ),
                        ),
                      );
                      _noteCtrl.clear();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: YanYanaColors.sosLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: YanYanaColors.sosLight),
                  ),
                  child: const Text(
                    'Gerçek ödeme ve resmi bağış entegrasyonu bu prototip kapsamında değildir.',
                    style: TextStyle(
                      color: YanYanaColors.textDark,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: YanYanaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: YanYanaColors.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _GuideCardItem extends StatelessWidget {
  final Map<String, String> data;
  const _GuideCardItem(this.data);

  @override
  Widget build(BuildContext context) {
    final badge = data['badge'] ?? 'Prototype';
    final color = badge == 'MVP'
        ? YanYanaColors.success
        : badge == 'Future Integration'
            ? YanYanaColors.warning
            : YanYanaColors.accentBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: YanYanaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: YanYanaColors.textDark,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, color: YanYanaColors.textLight),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            data['title'] ?? '',
            style: const TextStyle(
              color: YanYanaColors.textDark,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data['desc'] ?? '',
            style: const TextStyle(
              color: YanYanaColors.textMuted,
              fontSize: 12.8,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: YanYanaColors.textDark,
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

