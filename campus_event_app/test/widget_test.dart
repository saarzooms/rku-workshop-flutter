import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campus_event_app/app.dart';

void main() {
  testWidgets('CampusEventApp boots with ProviderScope and theme', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: CampusEventApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Campus Event App - Sprint 1 Setup Complete!'), findsOneWidget);
  });
}
