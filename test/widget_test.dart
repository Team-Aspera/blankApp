import 'package:blank_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts blank and advances through screenshot pages', (
    tester,
  ) async {
    await tester.pumpWidget(const MainApp());

    expect(find.byType(Image), findsNothing);

    await tester.tap(find.byType(GestureDetector));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
  });
}
