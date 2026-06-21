import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class NoteService extends ChangeNotifier {
  static const _storageKey = 'notes_data';

  final List<Note> _notes = [];
  bool _isLoaded = false;

  List<Note> get notes => List.unmodifiable(_notes);
  int get noteCount => _notes.length;
  bool get isLoaded => _isLoaded;

  Note? getById(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    return index == -1 ? null : _notes[index];
  }

  /// Load notes from persistent storage. Call once at app startup.
  Future<void> loadNotes() async {
    if (_isLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr);
        _notes.addAll(jsonList.map((e) => Note.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      debugPrint('Failed to load notes: $e');
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(_notes.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      debugPrint('Failed to save notes: $e');
    }
  }

  void addNote(String title, String content) {
    _notes.insert(0, Note.create(title: title, content: content));
    notifyListeners();
    _save();
  }

  /// Restore a previously deleted note at its original position.
  void restoreNote(Note note, int originalIndex) {
    if (originalIndex >= 0 && originalIndex <= _notes.length) {
      _notes.insert(originalIndex, note);
    } else {
      _notes.insert(0, note);
    }
    notifyListeners();
    _save();
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
    _save();
  }

  /// Returns the index of the deleted note so it can be restored.
  int deleteNote(String id) {
    final index = _notes.indexWhere((n) => n.id == id);
    if (index == -1) return -1;
    _notes.removeAt(index);
    notifyListeners();
    _save();
    return index;
  }
}
