// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:fquery/fquery.dart';
import 'package:fquery_core/fquery_core.dart';

import 'package:flutter_starter/main.dart';

void main() {
  testWidgets('App renders home page', (WidgetTester tester) async {
    await tester.pumpWidget(
      CacheProvider(
        cache: QueryCache(),
        child: const MyApp(),
      ),
    );
    expect(find.text('Flutter Starter'), findsOneWidget);
    expect(find.text('Tech Stack Demos'), findsOneWidget);
  });
}
