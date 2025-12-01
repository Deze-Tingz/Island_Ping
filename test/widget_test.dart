// Basic Flutter widget test for Island_Ping

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island_ping/app.dart';

void main() {
  testWidgets('Island Ping app loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: IslandPingApp(),
      ),
    );

    // Verify that the app title is displayed
    expect(find.text('Island Ping'), findsOneWidget);
  });
}
