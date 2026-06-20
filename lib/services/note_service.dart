import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/note.dart';

class NoteService extends ChangeNotifier {
  final List<Note> _notes = [];
  final Uuid _uuid = const Uuid();

  List<Note> get notes => List.unmodifiable(_notes);
  int get noteCount => _notes.length;

  Note? getById(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    return index == -1 ? null : _notes[index];
  }

  void addNote(String title, String content) {
    _notes.insert(
      0,
      Note(
        id: _uuid.v4(),
        title: title,
        content: content,
        updatedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void updateNote(String id, String title, String content) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notes[index] = _notes[index].copyWith(
      title: title,
      content: content,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }
}
