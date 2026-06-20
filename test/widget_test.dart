import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:note_pad/main.dart';

void main() {
  testWidgets('App renders home screen with empty state', (WidgetTester tester) async {
    await tester.pumpWidget(const NotepadApp());
    await tester.pump();

    // App bar title should be present
    expect(find.text('Notes'), findsOneWidget);

    // Empty state should appear
    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Tap + to create your first note'), findsOneWidget);

    // FAB should be present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
