import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yanyana_p/core/services/backend_orchestrator.dart';
import 'package:yanyana_p/features/home/main_page.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/rooms/room_detail_page.dart';
import 'package:yanyana_p/features/rooms/rooms_module.dart';
import 'package:yanyana_p/shared/models/community_post.dart';
import 'package:yanyana_p/shared/models/community_room.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _orchestrator = BackendOrchestrator.instance;

  List<CommunityPost> _posts = const [];
  List<CommunityRoom> _rooms = const [];
  bool _postsLoading = true;

  String _selectedCategory = 'Tümü';
  StreamSubscription<List<CommunityRoom>>? _roomsSub;
  StreamSubscription<List<CommunityPost>>? _postsSub;

  @override
  void initState() {
    super.initState();
    _postsSub = _orchestrator.streamCommunityPosts().listen(
      (posts) {
        if (!mounted) return;
        setState(() {
          _posts = posts;
          _postsLoading = false;
        });
      },
      onError: (_) => _reloadPostsFallback(),
    );
    _roomsSub = _orchestrator.streamCommunityRooms().listen((rooms) {
      if (!mounted) return;
      setState(() => _rooms = rooms);
    });
  }

  @override
  void dispose() {
    _postsSub?.cancel();
    _roomsSub?.cancel();
    super.dispose();
  }

  Future<void> _reloadPostsFallback() async {
    try {
      final posts = await _orchestrator.getCommunityPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _postsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _postsLoading = false);
    }
  }

  Future<void> _showCreatePostSheet() async {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
          child: Container(
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: YanYanaShadows.card,
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Gönderi Paylaş',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: YanYanaColors.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(labelText: 'Başlık'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: bodyCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'İçerik'),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  label: 'Paylaş',
                  icon: Icons.send_rounded,
                  onPressed: () => Navigator.pop(ctx, true),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (ok != true || !mounted) {
      titleCtrl.dispose();
      bodyCtrl.dispose();
      return;
    }

    if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık ve içerik zorunludur.')),
      );
      titleCtrl.dispose();
      bodyCtrl.dispose();
      return;
    }

    try {
      await _orchestrator.addCommunityPost(
        title: titleCtrl.text,
        content: bodyCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gönderin başarıyla paylaşıldı.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gönderi paylaşılamadı. Lütfen tekrar deneyin.')),
      );
    } finally {
      titleCtrl.dispose();
      bodyCtrl.dispose();
    }
  }

  final _categories = const [
    'Tümü',
    'Destek',
    'Eğitim',
    'Sağlık',
    'Sosyal',
    'Mentorluk',
  ];

  List<CommunityRoom> get _filteredRooms {
    if (_selectedCategory == 'Tümü') return _rooms;
    return _rooms.where((r) => r.category == _selectedCategory).toList();
  }

  Future<void> _openRoom(CommunityRoom room) async {
    final joined = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => RoomDetailPage(room: room),
      ),
    );
    if (joined == true) setState(() {});
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Prototip Bilgilendirmesi'),
        content: const Text(
          'Bu oda prototip olarak açıldı. Gerçek zamanlı mesajlaşma ve sesli konuşma future integration olarak planlanmıştır.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showCreateRoomSheet() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = 'Destek';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: YanYanaShadows.card,
            ),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: YanYanaColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.add_comment_rounded,
                            color: YanYanaColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Oda Oluştur',
                            style: TextStyle(
                              color: YanYanaColors.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: 'Oda Adı',
                        hintText: 'Örn: Sessiz Sohbet',
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
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
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
                      items: _categories
                          .where((c) => c != 'Tümü')
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setModalState(() => category = v ?? 'Destek'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Açıklama',
                        hintText: 'Bu odanın amacı nedir?',
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
                        label: 'Oluştur',
                        icon: Icons.check_rounded,
                        onPressed: () async {
                          if (nameCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(content: Text('Oda adı zorunludur.')),
                            );
                            return;
                          }
                          try {
                            await _orchestrator.createCommunityRoom(
                              title: nameCtrl.text,
                              category: category,
                              description: descCtrl.text,
                            );
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(content: Text('Oda oluşturuldu.')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                );
              },
            ),
          ),
        );
      },
    ).whenComplete(() {
      nameCtrl.dispose();
      descCtrl.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'post',
            onPressed: _showCreatePostSheet,
            backgroundColor: YanYanaColors.secondary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.post_add_rounded),
            label: const Text('Gönderi', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'room',
            onPressed: _showCreateRoomSheet,
            backgroundColor: YanYanaColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Oda', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            18,
            20,
            MainPage.bottomContentPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Topluluk Akışı',
                style: TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (_postsLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_posts.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: YanYanaColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: YanYanaColors.border),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Henüz topluluk gönderisi yok.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: YanYanaColors.textDark,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'İlk gönderiyi paylaşarak topluluğu başlatabilirsin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: YanYanaColors.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ..._posts.map(
                  (p) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: YanYanaColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: YanYanaShadows.soft,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: YanYanaColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.body,
                          style: const TextStyle(
                            color: YanYanaColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.authorName,
                          style: const TextStyle(
                            color: YanYanaColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const RoomsModulePage(),
                    ),
                  );
                },
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Topluluk Odaları',
                      style: TextStyle(
                        color: YanYanaColors.textDark,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Destek, sohbet ve paylaşım için güvenli alanlar.',
                      style: TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildCategoryChips(),
              const SizedBox(height: 14),
              if (_filteredRooms.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: YanYanaColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: YanYanaColors.border),
                  ),
                  child: const Text(
                    'Henüz topluluk odası yok. İlk odayı sen oluşturabilirsin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: YanYanaColors.textMuted),
                  ),
                )
              else
                ..._filteredRooms.map((r) => _RoomCard(room: r, onOpen: () => _openRoom(r))),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final c = _categories[i];
          final selected = c == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: selected ? YanYanaColors.primary : YanYanaColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? YanYanaColors.primary : YanYanaColors.border,
                ),
                boxShadow: selected ? YanYanaShadows.soft : null,
              ),
              child: Text(
                c,
                style: TextStyle(
                  color: selected ? Colors.white : YanYanaColors.textMuted,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final CommunityRoom room;
  final VoidCallback onOpen;

  const _RoomCard({required this.room, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final backend = BackendOrchestrator.instance;

    return FutureBuilder<bool>(
      future: backend.isRoomJoined(room.id),
      builder: (context, snap) {
        final joined = snap.data == true;
        return _roomCardContent(context, joined);
      },
    );
  }

  Widget _roomCardContent(BuildContext context, bool joined) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onOpen,
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: YanYanaColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: YanYanaShadows.card,
              border: joined
                  ? Border.all(color: YanYanaColors.primary, width: 1.5)
                  : null,
            ),
            child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: YanYanaColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  color: YanYanaColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      style: const TextStyle(
                        color: YanYanaColors.textDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.description,
                      style: const TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(
                label: room.category,
                color: YanYanaColors.secondary,
              ),
              _pill(
                label: '${room.memberCount} üye',
                color: YanYanaColors.accentBlue,
              ),
              if (joined)
                _pill(label: 'Katıldın', color: YanYanaColors.primary),
              if (room.isAuthorizedRoom)
                _pill(
                  label: 'Yetkili oda',
                  color: YanYanaColors.warning,
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpen,
              icon: Icon(joined ? Icons.check_rounded : Icons.login_rounded),
              label: Text(
                joined ? 'Detay / Katıldın' : 'Odayı Aç',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: YanYanaColors.primary,
                side: const BorderSide(color: YanYanaColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  static Widget _pill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: YanYanaColors.textDark,
          fontWeight: FontWeight.w800,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

