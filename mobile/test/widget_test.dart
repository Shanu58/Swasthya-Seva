import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:swasthya_seva/app.dart';

void main() {
  testWidgets(
    'Swasthya Seva app launches',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: SwasthyaSevaApp(),
        ),
      );

      expect(
        find.text('Swasthya Seva'),
        findsOneWidget,
      );
    },
  );
}
