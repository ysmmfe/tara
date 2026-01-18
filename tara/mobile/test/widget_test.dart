import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tara/tara_app.dart';

void main() {
  testWidgets('Tara app builds', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: TaraApp()));
    expect(find.text('Tara'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Cardápio'), findsOneWidget);
  });
}
