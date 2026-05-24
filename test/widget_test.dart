import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yanyana_p/features/auth/login_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginPage()),
    );
    await tester.pumpAndSettle();

    expect(find.text('YanYana'), findsOneWidget);
    expect(find.text('Giriş Yap'), findsWidgets);
  });
}
