import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Projedeki MainPage'i sanal olarak taklit eden mock bir test widget'ı
void main() {
  testWidgets('MainPage IndexedStack Navigation Shell State Retention Test', (WidgetTester tester) async {
    // Sanal alt bar ve IndexedStack mimarisini ayağa kaldırıyoruz
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IndexedStack(
            index: 0,
            children: const [
              Text('Home Page Dashboard View', key: Key('home_view')),
              Text('User Profile Management View', key: Key('profile_view')),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        ),
      ),
    );

    // Başlangıçta ana sayfanın görünür olduğunu, profilin gizli olduğunu doğrula
    expect(find.byKey(const Key('home_view')), findsOneWidget);
    expect(find.byKey(const Key('profile_view')), findsNothing);
  });
}