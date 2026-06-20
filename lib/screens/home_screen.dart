import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note.dart';
import '../services/note_service.dart';
import '../widgets/note_card.dart';
import 'edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
    service.deleteNote(note.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${note.title}" deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            service.addNote(note.title, note.content);
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
        title: const Text('Notes'),
        centerTitle: false,
      ),
      body: service.noteCount == 0
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
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: service.noteCount,
      itemBuilder: (context, index) {
        final note = service.notes[index];
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
