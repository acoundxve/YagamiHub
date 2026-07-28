import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:yagamihub_app/main.dart';

void main() {
  testWidgets('App arranca y muestra la pantalla de login', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: YagamiHubApp()));
    await tester.pumpAndSettle();

    expect(find.text('YagamiHub'), findsOneWidget);
  });
}
