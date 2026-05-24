import 'package:flutter/material.dart';
import 'package:yanyana_p/core/theme/theme.dart';
import 'package:yanyana_p/features/home/home_palette.dart';
import 'package:yanyana_p/features/community/community_page.dart';
import 'package:yanyana_p/features/community/guide_donation_page.dart';
import 'package:yanyana_p/features/emergency/accessibility_page.dart';
import 'package:yanyana_p/features/home/home_page.dart';
import 'package:yanyana_p/features/map/map_page.dart';
import 'package:yanyana_p/features/profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  /// Bottom padding for scrollable tab content so it clears the nav bar.
  static const double bottomContentPadding = 100;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final _mapPageKey = GlobalKey<MapPageState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(onTabSelected: _onTabSelected),
      MapPage(key: _mapPageKey),
      const CommunityPage(),
      const GuideDonationPage(),
      const AccessibilityPage(),
      const ProfilePage(),
    ];
  }

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
    if (index == 1) {
      _mapPageKey.currentState?.refreshEmergencyMarkers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HomePalette.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: YanYanaColors.surface,
          boxShadow: YanYanaShadows.nav,
        ),
        child: SafeArea(
          top: false,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: 62,
              backgroundColor: Colors.transparent,
              indicatorColor: HomePalette.lavender,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected
                      ? HomePalette.primary
                      : HomePalette.textMuted,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: 22,
                  color: selected
                      ? HomePalette.primary
                      : HomePalette.textMuted,
                );
              }),
            ),
            child: NavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Ana Sayfa',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map_rounded),
                  label: 'Harita',
                ),
                NavigationDestination(
                  icon: Icon(Icons.groups_outlined),
                  selectedIcon: Icon(Icons.groups_rounded),
                  label: 'Topluluk',
                ),
                NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(Icons.menu_book_rounded),
                  label: 'Rehber',
                ),
                NavigationDestination(
                  icon: Icon(Icons.accessibility_new_outlined),
                  selectedIcon: Icon(Icons.accessibility_new_rounded),
                  label: 'Erişim',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
