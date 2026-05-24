import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community/community_page.dart';
import 'package:yanyana_p/features/home/home_palette.dart';
import 'package:yanyana_p/features/home/main_page.dart';
import 'package:yanyana_p/features/home/success_stories_page.dart';
import 'package:yanyana_p/features/home/trusted_contacts_page.dart';
import 'package:yanyana_p/features/notifications/notifications_module.dart';
import 'package:yanyana_p/shared/models/app_user.dart';
import 'package:yanyana_p/shared/models/community_post.dart';
import 'package:yanyana_p/shared/models/notification_model.dart';
import 'package:yanyana_p/shared/models/success_story.dart';
import 'package:yanyana_p/shared/models/trusted_contact.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onTabSelected});

  final void Function(int index)? onTabSelected;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _backend = BackendOrchestrator.instance;

  bool _sosBusy = false;
  bool _loading = true;
  List<CommunityPost> _communityPosts = const [];
  List<SuccessStory> _successStories = const [];
  List<NotificationModel> _notifications = const [];
  bool _hasPlaces = false;
  AppUser? _user;
  StreamSubscription<List<CommunityPost>>? _postsSub;
  StreamSubscription<List<SuccessStory>>? _storiesSub;

  static const double _navClearance = MainPage.bottomContentPadding;

  @override
  void initState() {
    super.initState();
    _postsSub = _backend.streamCommunityPosts().listen(
      (posts) {
        if (!mounted) return;
        setState(() => _communityPosts = posts);
      },
      onError: (_) => _loadCommunityPostsOnce(),
    );
    _storiesSub = _backend.streamSuccessStories().listen(
      (stories) {
        if (!mounted) return;
        setState(() => _successStories = stories);
      },
      onError: (_) => _loadSuccessStoriesOnce(),
    );
    _loadDashboard();
  }

  @override
  void dispose() {
    _postsSub?.cancel();
    _storiesSub?.cancel();
    super.dispose();
  }

  Future<void> _loadCommunityPostsOnce() async {
    try {
      final posts = await _backend.getCommunityPosts();
      if (!mounted) return;
      setState(() => _communityPosts = posts);
    } catch (_) {}
  }

  Future<void> _loadSuccessStoriesOnce() async {
    try {
      final stories = await _backend.getSuccessStories();
      if (!mounted) return;
      setState(() => _successStories = stories);
    } catch (_) {}
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    List<NotificationModel> notifications = const [];
    var hasPlaces = false;

    try {
      notifications = await _backend.getNotifications();
    } catch (_) {}

    try {
      final places = await _backend.getAccessiblePlaces();
      hasPlaces = places.isNotEmpty;
    } catch (_) {}

    await _loadCommunityPostsOnce();
    await _loadSuccessStoriesOnce();

    if (!mounted) return;
    setState(() {
      _notifications = notifications;
      _hasPlaces = hasPlaces;
      _user = _backend.currentUser;
      _loading = false;
    });
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? HomePalette.softCoral : HomePalette.textDark,
      ),
    );
  }

  String _firstName(AppUser? u) {
    if (u == null || u.name.trim().isEmpty) return '';
    return u.name.trim().split(RegExp(r'\s+')).first;
  }

  double _profileCompletion(AppUser user) {
    var filled = 0;
    const total = 7;
    if (user.name.trim().isNotEmpty) filled++;
    if (user.about.trim().isNotEmpty) filled++;
    if (user.voiceIntro.trim().isNotEmpty) filled++;
    if (user.interests.isNotEmpty) filled++;
    if (user.communicationPreferences.isNotEmpty ||
        user.communicationPreference.isNotEmpty) {
      filled++;
    }
    if (user.accessibilityNeeds.isNotEmpty) filled++;
    if (user.hasEmergencyContact) filled++;
    return filled / total;
  }

  void _goTab(int index) => widget.onTabSelected?.call(index);

  void _goCommunity() {
    if (widget.onTabSelected != null) {
      widget.onTabSelected!(2);
    } else {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(builder: (_) => const CommunityPage()),
      );
    }
  }

  void _goSuccessStories({bool openShare = false}) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => SuccessStoriesPage(openShareOnStart: openShare),
      ),
    ).then((_) => _loadDashboard());
  }

  void _openNotifications() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const NotificationsModulePage(),
      ),
    ).then((_) => _loadDashboard());
  }

  Future<void> _onSosTap() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SOS isteği gönderilsin mi?'),
        content: const Text(
          'Acil destek isteğin güvenilir kişine iletilmek üzere kaydedilecek.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: HomePalette.softCoral),
            child: const Text('Gönder'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _sosBusy = true);
    try {
      await _backend.triggerSOS(source: 'home');
      if (!mounted) return;
      _snack('SOS isteği başarıyla oluşturuldu.');
      await _loadDashboard();
    } catch (e) {
      if (!mounted) return;
      final msg = e is StateError
          ? e.message
          : 'SOS isteği gönderilemedi. Lütfen tekrar deneyin.';
      _snack(msg, error: true);
    } finally {
      if (mounted) setState(() => _sosBusy = false);
    }
  }

  Future<void> _onSafeCallTap() async {
    List<TrustedContact> contacts = const [];
    try {
      contacts = await _backend.getTrustedContacts();
    } catch (_) {}

    if (!mounted) return;

    String? selectedId;

    final contactId = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Güvenli Arama'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Güvenli arama, güvendiğin bir kişiye hızlıca ulaşman için tasarlanmıştır.',
                    ),
                    const SizedBox(height: 16),
                    if (contacts.isEmpty)
                      const Text(
                        'Henüz güvenilir kişi eklenmedi.',
                        style: TextStyle(
                          color: HomePalette.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      ...contacts.map(
                        (c) => RadioListTile<String>(
                          value: c.id,
                          groupValue: selectedId,
                          onChanged: (v) => setDialogState(() => selectedId = v),
                          title: Text(c.name),
                          subtitle: Text('${c.relationship} · ${c.phoneNumber}'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('İptal'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const TrustedContactsPage(),
                      ),
                    );
                  },
                  child: const Text('Kişi Ekle'),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedId == null) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Lütfen önce güvenilir bir kişi seç.'),
                        ),
                      );
                      return;
                    }
                    Navigator.pop(ctx, selectedId);
                  },
                  child: const Text('Başlat'),
                ),
              ],
            );
          },
        );
      },
    );

    if (contactId == null) {
      if (contacts.isEmpty) {
        _snack('Güvenli arama için önce acil kişi eklemelisin.');
      }
      return;
    }

    try {
      await _backend.startSafeCall(trustedContactId: contactId);
      if (!mounted) return;
      _snack('Güvenli arama isteği başlatıldı.');
      await _loadDashboard();
    } catch (_) {
      if (!mounted) return;
      _snack('Güvenli arama başlatılamadı.', error: true);
    }
  }

  List<_RecommendedAction> _recommendedActions(AppUser? user) {
    final list = <_RecommendedAction>[];

    if (user != null && _profileCompletion(user) < 0.85) {
      list.add(
        _RecommendedAction(
          title: 'Profilini tamamla',
          description: 'Tercihlerini ekleyerek desteği kişiselleştir.',
          icon: Icons.person_rounded,
          iconColor: HomePalette.primary,
          background: HomePalette.lavender,
          onTap: () => _goTab(5),
        ),
      );
    }

    if (user != null && !user.hasEmergencyContact) {
      list.add(
        _RecommendedAction(
          title: 'Acil kişi ekle',
          description: 'SOS ve güvenli arama için gerekli.',
          icon: Icons.contact_emergency_rounded,
          iconColor: HomePalette.softCoral,
          background: HomePalette.softPink,
          onTap: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const TrustedContactsPage(),
              ),
            ).then((_) => _loadDashboard());
          },
        ),
      );
    }

    list.add(
      _RecommendedAction(
        title: 'Erişilebilir mekan keşfet',
        description: 'Haritada erişilebilir yerleri incele.',
        icon: Icons.map_rounded,
        iconColor: const Color(0xFF3B82F6),
        background: HomePalette.softBlue,
        onTap: () => _goTab(1),
      ),
    );

    if (_communityPosts.isEmpty) {
      list.add(
        _RecommendedAction(
          title: 'Topluluğa katıl',
          description: 'Paylaşımları oku veya ilk gönderiyi sen yap.',
          icon: Icons.groups_rounded,
          iconColor: const Color(0xFF14B8A6),
          background: HomePalette.softMint,
          onTap: _goCommunity,
        ),
      );
    }

    if (!_hasPlaces) {
      list.add(
        _RecommendedAction(
          title: 'İlk mekanı ekle',
          description: 'Bildiğin erişilebilir bir yeri haritaya ekle.',
          icon: Icons.add_location_alt_rounded,
          iconColor: HomePalette.primary,
          background: HomePalette.softYellow,
          onTap: () => _goTab(1),
        ),
      );
    }

    return list.take(5).toList();
  }

  String _relativeTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes.clamp(1, 999)} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    return '${diff.inDays} gün önce';
  }

  @override
  Widget build(BuildContext context) {
    final user = _user ?? _backend.currentUser;
    final firstName = _firstName(user);
    final recommended = _recommendedActions(user);
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: HomePalette.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: HomePalette.primary,
          onRefresh: _loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 10, 18, _navClearance),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(unreadCount),
                const SizedBox(height: 14),
                _GreetingCard(
                  firstName: firstName,
                  user: user,
                  profileComplete: user != null && _profileCompletion(user) >= 0.85,
                  hasEmergency: user?.hasEmergencyContact ?? false,
                  communityActive: _communityPosts.isNotEmpty,
                ),
                const SizedBox(height: 16),
                _EmergencyCard(
                  sosBusy: _sosBusy,
                  onSafeCall: _onSafeCallTap,
                  onSos: _onSosTap,
                ),
                const SizedBox(height: 22),
                _SectionTitle(
                  title: 'Bugün için önerilenler',
                  subtitle: 'Sana uygun adımlar',
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  ...recommended.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _RecommendedCard(action: a),
                    ),
                  ),
                const SizedBox(height: 22),
                _SectionTitle(
                  title: 'Son aktiviteler',
                  subtitle: 'Bildirimler ve güncellemeler',
                ),
                const SizedBox(height: 12),
                if (_loading)
                  const SizedBox.shrink()
                else if (_notifications.isEmpty)
                  _PastelEmptyCard(
                    background: HomePalette.lavender,
                    icon: Icons.history_rounded,
                    iconColor: HomePalette.primary,
                    title: 'Henüz aktivite yok',
                    subtitle: 'Uygulamayı kullandıkça burada görünecek.',
                  )
                else
                  ..._notifications.take(3).map(
                        (n) => _ActivityTile(
                          notification: n,
                          timeLabel: _relativeTime(n.createdAt),
                        ),
                      ),
                const SizedBox(height: 22),
                _SectionHeader(title: 'Topluluk', onSeeAll: _goCommunity),
                const SizedBox(height: 10),
                if (_loading)
                  const SizedBox.shrink()
                else if (_communityPosts.isEmpty)
                  _PastelEmptyCard(
                    background: HomePalette.softMint,
                    icon: Icons.forum_rounded,
                    iconColor: const Color(0xFF14B8A6),
                    title: 'Toplulukta henüz gönderi yok.',
                    subtitle: 'İlk paylaşımı sen başlatabilirsin.',
                    buttonLabel: 'Topluluğa Git',
                    onPressed: _goCommunity,
                  )
                else
                  ..._communityPosts.take(2).map(
                        (p) => _CommunityPreviewCard(
                          post: p,
                          timeLabel: _relativeTime(p.createdAt),
                          onTap: _goCommunity,
                        ),
                      ),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: 'Başarı hikayeleri',
                  onSeeAll: () => _goSuccessStories(),
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const SizedBox.shrink()
                else if (_successStories.isEmpty)
                  _PastelEmptyCard(
                    background: HomePalette.softYellow,
                    icon: Icons.auto_awesome_rounded,
                    iconColor: const Color(0xFFF59E0B),
                    title: 'Henüz başarı hikayesi paylaşılmadı.',
                    subtitle: 'İlk hikayeyi sen paylaşabilirsin.',
                    buttonLabel: 'Hikaye Paylaş',
                    onPressed: () => _goSuccessStories(openShare: true),
                  )
                else
                  ..._successStories.take(2).map(
                        (s) => _StoryPreviewCard(
                          story: s,
                          onTap: () => _goSuccessStories(),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(int unreadCount) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: HomePalette.greetingGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: YanYanaShadows.soft,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: HomePalette.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'YanYana',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: HomePalette.textDark,
            ),
          ),
        ),
        Material(
          color: HomePalette.lavender,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _openNotifications,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: Badge(
                  isLabelVisible: unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: HomePalette.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendedAction {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final VoidCallback onTap;

  const _RecommendedAction({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.onTap,
  });
}

class _GreetingCard extends StatelessWidget {
  final String firstName;
  final AppUser? user;
  final bool profileComplete;
  final bool hasEmergency;
  final bool communityActive;

  const _GreetingCard({
    required this.firstName,
    required this.user,
    required this.profileComplete,
    required this.hasEmergency,
    required this.communityActive,
  });

  @override
  Widget build(BuildContext context) {
    final greeting = firstName.isEmpty
        ? 'Merhaba 👋'
        : 'Merhaba, $firstName 👋';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        gradient: HomePalette.greetingGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: YanYanaShadows.card,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -8,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: HomePalette.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -16,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: HomePalette.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Bugün nasıl destek almak istersin?',
                style: TextStyle(
                  fontSize: 15,
                  color: HomePalette.textMuted,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _StatusChip(
                    icon: hasEmergency
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    label: hasEmergency ? 'Acil kişi kayıtlı' : 'Acil kişi eksik',
                    color: hasEmergency
                        ? HomePalette.softMint
                        : HomePalette.softPink,
                    iconColor: hasEmergency
                        ? const Color(0xFF14B8A6)
                        : HomePalette.softCoral,
                  ),
                  if (!profileComplete)
                    const _StatusChip(
                      icon: Icons.edit_note_rounded,
                      label: 'Profilini tamamla',
                      color: HomePalette.softYellow,
                      iconColor: Color(0xFFF59E0B),
                    ),
                  _StatusChip(
                    icon: communityActive
                        ? Icons.groups_rounded
                        : Icons.groups_outlined,
                    label: communityActive ? 'Topluluk hazır' : 'Topluluğa katıl',
                    color: HomePalette.softBlue,
                    iconColor: Color(0xFF3B82F6),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: HomePalette.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmergencyCard extends StatelessWidget {
  final bool sosBusy;
  final VoidCallback onSafeCall;
  final VoidCallback onSos;

  const _EmergencyCard({
    required this.sosBusy,
    required this.onSafeCall,
    required this.onSos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: HomePalette.emergencyGradient,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: HomePalette.softPink.withValues(alpha: 0.8)),
        boxShadow: YanYanaShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: HomePalette.softCoral,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acil Destek',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: HomePalette.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Güvenilir kişine hızlıca haber ver.',
                      style: TextStyle(
                        color: HomePalette.textMuted,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onSafeCall,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                      foregroundColor: HomePalette.textDark,
                      side: const BorderSide(color: Color(0xFFFFD6DE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.call_rounded, size: 20),
                    label: const Text(
                      'Güvenli Arama',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'SOS',
                  child: SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: sosBusy ? null : onSos,
                      style: FilledButton.styleFrom(
                        backgroundColor: HomePalette.softCoral,
                        disabledBackgroundColor: HomePalette.textMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: sosBusy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'SOS',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  final _RecommendedAction action;

  const _RecommendedCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: action.onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: action.background,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
            boxShadow: YanYanaShadows.soft,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(action.icon, color: action.iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: HomePalette.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      action.description,
                      style: const TextStyle(
                        color: HomePalette.textMuted,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: action.iconColor.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final NotificationModel notification;
  final String timeLabel;

  const _ActivityTile({
    required this.notification,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HomePalette.lavender),
          boxShadow: YanYanaShadows.soft,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HomePalette.softBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.notifications_rounded,
                color: HomePalette.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: HomePalette.textDark,
                    ),
                  ),
                  Text(
                    notification.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: HomePalette.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              timeLabel,
              style: const TextStyle(
                color: HomePalette.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: HomePalette.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: HomePalette.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: HomePalette.textDark,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text(
            'Tümünü Gör',
            style: TextStyle(
              color: HomePalette.primary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _PastelEmptyCard extends StatelessWidget {
  final Color background;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  const _PastelEmptyCard({
    required this.background,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
        boxShadow: YanYanaShadows.soft,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: HomePalette.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: HomePalette.textMuted,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          if (buttonLabel != null && onPressed != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: HomePalette.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(buttonLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CommunityPreviewCard extends StatelessWidget {
  final CommunityPost post;
  final String timeLabel;
  final VoidCallback onTap;

  const _CommunityPreviewCard({
    required this.post,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HomePalette.softMint,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              boxShadow: YanYanaShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: HomePalette.textDark,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomePalette.textMuted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${post.authorName} · $timeLabel',
                  style: const TextStyle(
                    color: HomePalette.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryPreviewCard extends StatelessWidget {
  final SuccessStory story;
  final VoidCallback onTap;

  const _StoryPreviewCard({required this.story, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HomePalette.softYellow,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
              boxShadow: YanYanaShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFF59E0B),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        story.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: HomePalette.textDark,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  story.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: HomePalette.textMuted,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  story.authorName,
                  style: const TextStyle(
                    color: HomePalette.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
