import 'package:flutter/material.dart';
import 'features/guide/screens/guide_home_screen.dart';
import 'features/donation/screens/donation_home_screen.dart';

class TemporaryDashboard extends StatefulWidget {
  const TemporaryDashboard({super.key});

  @override
  State<TemporaryDashboard> createState() => _TemporaryDashboardState();
}

class _TemporaryDashboardState extends State<TemporaryDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const GuideHomeScreen(),
    const DonationHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: "Rehberler",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Bağış & Destek",
          ),
        ],
      ),
    );
  }
}
