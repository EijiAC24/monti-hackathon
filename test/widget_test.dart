import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:monti/app/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: MontiApp()));
    await tester.pumpAndSettle();

    expect(find.text('モンティに\nおしえてね！'), findsOneWidget);
  });
}
