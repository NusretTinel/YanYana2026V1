import 'package:flutter/material.dart';
import 'package:yanyana_p/core/constants/role_constants.dart';
import 'package:yanyana_p/core/services/auth_service.dart';
import 'package:yanyana_p/core/services/guide_service.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/shared/widgets/accessibility_widgets.dart';
import '../models/guide_model.dart';
import 'guide_detail_screen.dart';
import 'guide_create_screen.dart';

class GuideHomeScreen extends StatefulWidget {
  const GuideHomeScreen({super.key});

  @override
  State<GuideHomeScreen> createState() => _GuideHomeScreenState();
}

class _GuideHomeScreenState extends State<GuideHomeScreen> {
  String _searchQuery = '';
  GuideCategory? _selectedCategory;

  bool get _isStaff => AuthService.instance.currentUser?.isStaff ?? false;

  bool get _canModerate {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;
    return user.isStaff || user.userType == AppUserType.volunteer;
  }

  bool get _canCreate {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;
    return user.isStaff || 
           user.userType == AppUserType.volunteer || 
           user.userType == AppUserType.disabledUser;
  }

  /// Engelli kullanıcı: TTS erişilebilirlik butonu göster
  bool get _isDisabledUser {
    final user = AuthService.instance.currentUser;
    return user?.userType == AppUserType.disabledUser;
  }

  List<Guide> _filterGuides(List<Guide> guides) {
    return guides.where((guide) {
      final matchesSearch = _searchQuery.isEmpty ||
          guide.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          guide.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || guide.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> _buildTtsText(List<Guide> guides) {
    final buffer = <String>[];
    buffer.add('Rehber sayfası. ${guides.length} rehber bulunuyor.');
    for (final g in guides.take(5)) {
      buffer.add('${g.title}. ${g.description}. ${g.likes} beğeni.');
    }
    return buffer;
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // ── Moderatör / Gönüllü Bilgi Bandı ──
          if (_canModerate)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      'Yetkili / Gönüllü görünümü — Beklemedekiler dahil',
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

          // ── Arama Çubuğu ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rehber veya tarif ara...',
                hintStyle: const TextStyle(color: YanYanaColors.textLight),
                prefixIcon: const Icon(Icons.search,
                    size: 24, color: YanYanaColors.primary),
                filled: true,
                fillColor: YanYanaColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              style:
                  const TextStyle(fontSize: 16, color: YanYanaColors.textDark),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          const SizedBox(height: 12),

          // ── Kategori Filtreleri ──
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Tümü', null),
                const SizedBox(width: 8),
                _buildFilterChip('Günlük İşler', GuideCategory.dailyTasks),
                const SizedBox(width: 8),
                _buildFilterChip('Yemek Tarifleri', GuideCategory.recipes),
                const SizedBox(width: 8),
                _buildFilterChip('Sosyal Beceriler', GuideCategory.socialSkills),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Liste ──
          Expanded(
            child: StreamBuilder<List<Guide>>(
              stream: _canModerate
                  ? GuideService.instance.streamAllGuides()
                  : GuideService.instance.streamApprovedGuides(),
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
                          const Text(
                            'Veriler yüklenirken sorun oluştu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: YanYanaColors.textDark,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: YanYanaColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filtered = _filterGuides(snapshot.data ?? []);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.menu_book_outlined,
                            size: 60, color: YanYanaColors.textLight),
                        const SizedBox(height: 12),
                        const Text(
                          'Henüz rehber yok.\nİlk rehberi sen oluştur!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: YanYanaColors.textMuted),
                        ),
                        // Engelli kullanıcı için sesli uyarı
                        if (_isDisabledUser) ...[
                          const SizedBox(height: 16),
                          TtsReadButton(
                            texts: const [
                              'Henüz rehber bulunmuyor. Daha sonra tekrar kontrol edebilirsiniz.'
                            ],
                            tooltip: 'Sesli Oku',
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _buildGuideCard(filtered[index]),
                    ),
                    // Engelli kullanıcı için sayfayı sesli oku butonu
                    if (_isDisabledUser)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: AccessibilityFab(
                          textsToRead: _buildTtsText(filtered),
                          readLabel: 'Rehberleri Sesli Oku',
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
              heroTag: 'guide_create_fab',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const GuideCreateScreen()),
              ),
              backgroundColor: YanYanaColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Yeni Rehber',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, GuideCategory? category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? YanYanaColors.primary : YanYanaColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: YanYanaColors.border),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : YanYanaColors.textDark,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideCard(Guide guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: YanYanaColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: YanYanaShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GuideDetailScreen(guide: guide)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (guide.coverImageUrl != null)
              Image.network(
                guide.coverImageUrl!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderImage(),
              )
            else
              _placeholderImage(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: YanYanaColors.secondaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(guide.category.label,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: YanYanaColors.secondary,
                                fontSize: 12)),
                      ),
                      const Spacer(),
                      if (!guide.isApproved)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: YanYanaColors.warning,
                              borderRadius: BorderRadius.circular(8)),
                          child: const Text('Beklemede',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11)),
                        ),
                      // Her kartta TTS butonu
                      TtsReadButton(
                        texts: ['${guide.title}. ${guide.description}'],
                        iconSize: 22,
                        tooltip: 'Sesli Oku',
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(guide.title,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: YanYanaColors.textDark)),
                  const SizedBox(height: 4),
                  Text(guide.description,
                      style: const TextStyle(
                          fontSize: 14,
                          color: YanYanaColors.textMuted,
                          height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.thumb_up_alt_rounded,
                              size: 16, color: YanYanaColors.accentBlue),
                          const SizedBox(width: 4),
                          Text('${guide.likes} Beğeni',
                              style: const TextStyle(
                                  color: YanYanaColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.person_outline,
                              size: 14, color: YanYanaColors.textLight),
                          const SizedBox(width: 4),
                          Text(guide.authorName,
                              style: const TextStyle(
                                  color: YanYanaColors.textLight, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 140,
      width: double.infinity,
      color: YanYanaColors.primaryLight,
      child: const Icon(Icons.menu_book, size: 50, color: YanYanaColors.primary),
    );
  }
}
