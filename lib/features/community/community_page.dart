import 'package:flutter/material.dart';
import 'package:yanyana_p/features/community/widgets/community_content_manager.dart';
import 'package:yanyana_p/features/home/main_page.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/community_rooms/community_rooms_page.dart';
import 'package:yanyana_p/features/community_rooms/data/mock_community_rooms_data.dart';
import 'package:yanyana_p/features/community_rooms/room_detail_page.dart' as mock_rooms;
import 'package:yanyana_p/features/community_rooms/widgets/community_room_card.dart';
import 'package:yanyana_p/features/community/widgets/community_action_bar.dart';
import 'package:yanyana_p/features/community/widgets/community_board_section.dart';
import 'package:yanyana_p/features/community/widgets/community_feed_section.dart';
import 'package:yanyana_p/features/community/widgets/community_responsive_shell.dart';
import 'package:yanyana_p/features/community/widgets/community_room_form_sheet.dart';
import 'package:yanyana_p/features/community/widgets/community_room_manager.dart';
import 'package:yanyana_p/features/community/widgets/live_community_rooms_section.dart';
import 'package:yanyana_p/shared/models/community_room.dart';

enum _RoomListMode { mock, live }

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _selectedCategory = 'Tümü';
  _RoomListMode _roomListMode = _RoomListMode.mock;
  final Set<String> _joinedMockRoomIds = {};
  final Set<String> _deletingMockRoomIds = {};
  int _mockRoomsRevision = 0;

  Future<void> _showCreatePostSheet() async {
    await CommunityContentManager.createContent(context);
  }

  List<CommunityRoom> get _filteredMockRooms {
    // Read revision so list rebuilds after local add/edit/delete.
    _mockRoomsRevision;
    return MockCommunityRoomsData.filterByCategory(_selectedCategory);
  }

  void _refreshMockRooms() {
    setState(() => _mockRoomsRevision++);
  }

  void _openMockRoom(CommunityRoom room) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => mock_rooms.RoomDetailPage(
          room: room,
          initiallyJoined: _joinedMockRoomIds.contains(room.id),
          onJoinChanged: (joined) {
            setState(() {
              if (joined) {
                _joinedMockRoomIds.add(room.id);
              } else {
                _joinedMockRoomIds.remove(room.id);
              }
            });
          },
        ),
      ),
    );
  }

  void _joinMockRoom(CommunityRoom room) {
    setState(() => _joinedMockRoomIds.add(room.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${room.title} odasına katıldınız (yerel).')),
    );
  }

  Future<void> _onCreateRoomPressed() async {
    final initialType = _roomListMode == _RoomListMode.live
        ? CommunityRoomCreationType.live
        : CommunityRoomCreationType.mock;

    final created = await CommunityRoomManager.createRoom(
      context,
      onMockListChanged: _refreshMockRooms,
      initialType: initialType,
    );

    if (!mounted || !created) return;

    setState(() {
      _roomListMode = initialType == CommunityRoomCreationType.live
          ? _RoomListMode.live
          : _RoomListMode.mock;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanYanaColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 18,
            bottom: MainPage.bottomContentPadding,
          ),
          child: CommunityResponsiveShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Topluluk',
                  style: TextStyle(
                    color: YanYanaColors.textDark,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Paylaşımlar, odalar ve destekleyici topluluk alanları.',
                  style: TextStyle(
                    color: YanYanaColors.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                CommunityActionBar(
                  onCreatePost: _showCreatePostSheet,
                  onCreateRoom: _onCreateRoomPressed,
                ),
                const SizedBox(height: 22),
                const CommunityFeedSection(),
              const SizedBox(height: 36),
              const Text(
                'Topluluk Odaları',
                style: TextStyle(
                  color: YanYanaColors.textDark,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Destek, sohbet, paylaşım ve güvenli topluluk etkileşimi için erişilebilir alanlar.',
                style: TextStyle(
                  color: YanYanaColors.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Örnek topluluk odalarını göster',
                      button: true,
                      selected: _roomListMode == _RoomListMode.mock,
                      child: SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () {
                            setState(() => _roomListMode = _RoomListMode.mock);
                          },
                          icon: const Icon(Icons.chat_rounded, size: 22),
                          label: const Text(
                            'Odalar (Örnek)',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _roomListMode == _RoomListMode.mock
                                ? YanYanaColors.primary
                                : YanYanaColors.surfaceSoft,
                            foregroundColor: _roomListMode == _RoomListMode.mock
                                ? Colors.white
                                : YanYanaColors.textDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: _roomListMode == _RoomListMode.mock
                                    ? YanYanaColors.primary
                                    : YanYanaColors.border,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      label: 'Canlı topluluk odalarını göster',
                      button: true,
                      selected: _roomListMode == _RoomListMode.live,
                      child: SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: () {
                            setState(() => _roomListMode = _RoomListMode.live);
                          },
                          icon: const Icon(Icons.cloud_rounded, size: 22),
                          label: const Text(
                            'Odalar (Canlı)',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _roomListMode == _RoomListMode.live
                                ? YanYanaColors.secondary
                                : YanYanaColors.surfaceSoft,
                            foregroundColor: _roomListMode == _RoomListMode.live
                                ? Colors.white
                                : YanYanaColors.textDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: _roomListMode == _RoomListMode.live
                                    ? YanYanaColors.secondary
                                    : YanYanaColors.border,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_roomListMode == _RoomListMode.mock) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const CommunityRoomsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text(
                      'Tüm mock odalar',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _buildCategoryChips(),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _roomListMode == _RoomListMode.live
                          ? YanYanaColors.secondaryLight
                          : YanYanaColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _roomListMode == _RoomListMode.live
                          ? 'Canlı odalar'
                          : 'Örnek odalar',
                      style: TextStyle(
                        color: _roomListMode == _RoomListMode.live
                            ? YanYanaColors.secondary
                            : YanYanaColors.primaryDark,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _roomListMode == _RoomListMode.live
                          ? 'Firestore — gerçek zamanlı'
                          : 'Yerel veri — katılım ve sohbet denemesi',
                      style: const TextStyle(
                        color: YanYanaColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              ),
              const SizedBox(height: 18),
              if (_roomListMode == _RoomListMode.mock) ...[
                if (_filteredMockRooms.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: YanYanaColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: YanYanaColors.border),
                    ),
                    child: Text(
                      '“$_selectedCategory” için örnek oda bulunamadı.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: YanYanaColors.textMuted),
                    ),
                  )
                else
                  ..._filteredMockRooms.map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: CommunityRoomCard(
                        room: r,
                        joined: _joinedMockRoomIds.contains(r.id),
                        onOpen: () => _openMockRoom(r),
                        onJoin: () => _joinMockRoom(r),
                        canManage: CommunityRoomManager.canManageMockRoom(r),
                        onEdit: CommunityRoomManager.canManageMockRoom(r)
                            ? () => CommunityRoomManager.editMockRoom(
                                  context,
                                  r,
                                  _refreshMockRooms,
                                )
                            : null,
                        onDelete: CommunityRoomManager.canManageMockRoom(r)
                            ? () => CommunityRoomManager.deleteMockRoom(
                                  context,
                                  r,
                                  () {
                                    _joinedMockRoomIds.remove(r.id);
                                    _refreshMockRooms();
                                  },
                                  isDeleting: () =>
                                      _deletingMockRoomIds.contains(r.id),
                                  setDeleting: (v) {
                                    setState(() {
                                      if (v) {
                                        _deletingMockRoomIds.add(r.id);
                                      } else {
                                        _deletingMockRoomIds.remove(r.id);
                                      }
                                    });
                                  },
                                )
                            : null,
                      ),
                    ),
                  ),
              ] else
                LiveCommunityRoomsSection(selectedCategory: _selectedCategory),
              const SizedBox(height: 28),
                const CommunityBoardSection(previewLimit: 4),
              ],
            ),
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
        itemCount: MockCommunityRoomsData.categories.length,
        itemBuilder: (context, i) {
          final c = MockCommunityRoomsData.categories[i];
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

