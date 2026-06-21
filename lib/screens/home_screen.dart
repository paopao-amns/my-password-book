import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/note_card.dart';
import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _filterNotes(List<Note> notes) {
    if (_searchQuery.isEmpty) return notes;
    final query = _searchQuery.toLowerCase();
    return notes.where((n) {
      return n.title.toLowerCase().contains(query) ||
          n.content.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _navigateToEdit(BuildContext context, {Note? note}) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditScreen(note: note),
      ),
    );
  }

  Future<bool> _confirmDismiss(BuildContext context, Note note) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete note?'),
            content: Text('"${note.title}" will be permanently deleted.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _deleteNote(BuildContext context, NoteService service, Note note) {
    final deletedIndex = service.deleteNote(note.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${note.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            service.restoreNote(note, deletedIndex);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<NoteService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('Notes'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? 'Close search' : 'Search',
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: !service.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : service.noteCount == 0
              ? _buildEmptyState(theme)
              : _buildNoteList(context, service, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEdit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.note_add_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first note',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteList(
      BuildContext context, NoteService service, ThemeData theme) {
    final filteredNotes = _filterNotes(service.notes);

    if (filteredNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No matching notes',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredNotes.length,
      itemBuilder: (context, index) {
        final note = filteredNotes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Dismissible(
            key: ValueKey(note.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            confirmDismiss: (_) => _confirmDismiss(context, note),
            onDismissed: (_) => _deleteNote(context, service, note),
            child: NoteCard(
              note: note,
              onTap: () => _navigateToEdit(context, note: note),
            ),
          ),
        );
      },
    );
  }
}
