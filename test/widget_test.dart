import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:note_pad/main.dart';
import 'package:note_pad/models/note.dart';
import 'package:note_pad/services/note_service.dart';

void main() {
  group('Note model', () {
    test('Note.create generates id and timestamps', () {
      final note = Note.create(title: 'Test', content: 'Hello');
      expect(note.id, isNotEmpty);
      expect(note.title, 'Test');
      expect(note.content, 'Hello');
      expect(note.createdAt, isNotNull);
      expect(note.updatedAt, isNotNull);
    });

    test('copyWith preserves id and createdAt', () {
      final original = Note.create(title: 'A', content: 'B');
      final copied = original.copyWith(title: 'C');
      expect(copied.id, original.id);
      expect(copied.createdAt, original.createdAt);
      expect(copied.title, 'C');
      expect(copied.content, 'B');
    });

    test('toJson/fromJson round-trip', () {
      final original = Note.create(title: 'Test', content: 'Content');
      final json = original.toJson();
      final restored = Note.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.content, original.content);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('equality is based on id', () {
      final a = Note.create(title: 'A', content: 'A');
      final b = Note.create(title: 'B', content: 'B');
      final c = a.copyWith(title: 'C');
      expect(a, isNot(equals(b)));
      expect(a, equals(c));
    });
  });

  group('NoteService', () {
    late NoteService service;

    setUp(() {
      service = NoteService();
    });

    test('starts empty', () {
      expect(service.noteCount, 0);
      expect(service.notes, isEmpty);
    });

    test('addNote inserts at front', () {
      service.addNote('First', 'Content1');
      service.addNote('Second', 'Content2');
      expect(service.noteCount, 2);
      expect(service.notes[0].title, 'Second');
      expect(service.notes[1].title, 'First');
    });

    test('updateNote modifies existing note', () {
      service.addNote('Original', 'Original content');
      final id = service.notes.first.id;
      service.updateNote(id, 'Updated', 'Updated content');
      expect(service.notes.first.title, 'Updated');
      expect(service.notes.first.content, 'Updated content');
    });

    test('updateNote on non-existent id does nothing', () {
      service.addNote('Test', 'Content');
      service.updateNote('non-existent-id', 'X', 'Y');
      expect(service.noteCount, 1);
      expect(service.notes.first.title, 'Test');
    });

    test('deleteNote removes note and returns index', () {
      service.addNote('A', 'a');
      service.addNote('B', 'b');
      final id = service.notes[1].id;
      final index = service.deleteNote(id);
      expect(index, 1);
      expect(service.noteCount, 1);
      expect(service.notes.first.title, 'B');
    });

    test('restoreNote inserts at original position', () {
      service.addNote('A', 'a');
      service.addNote('B', 'b');
      service.addNote('C', 'c');

      final deletedNote = service.notes[1]; // 'B'
      final deletedIndex = service.deleteNote(deletedNote.id);

      expect(service.noteCount, 2);
      expect(service.notes[0].title, 'C');
      expect(service.notes[1].title, 'A');

      service.restoreNote(deletedNote, deletedIndex);

      expect(service.noteCount, 3);
      expect(service.notes[0].title, 'C');
      expect(service.notes[1].title, 'B');
      expect(service.notes[2].title, 'A');
    });

    test('getById returns note or null', () {
      service.addNote('Test', 'Content');
      final id = service.notes.first.id;
      expect(service.getById(id), isNotNull);
      expect(service.getById('non-existent'), isNull);
    });
  });

  group('NotepadApp widget', () {
    testWidgets('renders home screen with empty state', (WidgetTester tester) async {
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

    testWidgets('search icon is present', (WidgetTester tester) async {
      await tester.pumpWidget(const NotepadApp());
      await tester.pump();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
