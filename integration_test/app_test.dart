import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:iman_flow/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify profile navigation and social features',
        (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Verify Home Screen loads
      expect(find.text('Iman Flow'), findsOneWidget);
      
      // 2. Locate and Tap Profile Icon in AppBar
      // The profile icon is Icons.account_circle_outlined
      final profileIcon = find.byIcon(Icons.account_circle_outlined);
      expect(profileIcon, findsOneWidget);
      
      await tester.tap(profileIcon);
      await tester.pumpAndSettle();

      // 3. Verify Profile Screen (Guest Mode)
      expect(find.text('Join the Community'), findsOneWidget);
      expect(find.text('Sign In / Sign Up'), findsOneWidget);

      // 4. Navigate back
      final backButton = find.byType(BackButton); // Or Icons.arrow_back
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // 5. Verify back on Home
      expect(find.text('Iman Flow'), findsOneWidget);
    });
  });
}
