import 'package:flutter/material.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/note_add_edit.dart';
import 'package:notes_app/screens/note_view.dart';
import 'package:notes_app/screens/delete_note_dialog.dart';
import 'package:notes_app/services/storage_service.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _notes = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final loadedNotes = await StorageService.loadNotes();
    setState(() {
      _notes = loadedNotes;
      _isLoading = false;
    });
  }

  Future<void> _saveAndRefresh() async {
    await StorageService.saveNotes(_notes);
    setState(() {});
  }

  void _addOrUpdateNote({Note? existingNote}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteAddEditScreen(note: existingNote),
      ),
    );

    if (result != null && result is Note) {
      setState(() {
        if (existingNote == null) {
          _notes.insert(0, result);
        } else {
          final index = _notes.indexWhere((n) => n.id == result.id);
          if (index != -1) _notes[index] = result;
        }
      });
      await _saveAndRefresh();
    }
  }

  void _confirmDelete(Note note) {
    showDialog<bool>(
      context: context,
      builder: (context) => const DeleteNoteDialog(),
    ).then((confirmed) {
      if (confirmed != true) return;
      setState(() => _notes.removeWhere((n) => n.id == note.id));
      _saveAndRefresh();
    });
  }

  Future<void> _viewNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteViewScreen(note: note)),
    );

    if (result is Note) {
      final index = _notes.indexWhere((item) => item.id == result.id);
      if (index != -1) {
        setState(() => _notes[index] = result);
        await _saveAndRefresh();
      }
    } else if (result == true) {
      setState(() => _notes.removeWhere((item) => item.id == note.id));
      await _saveAndRefresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _notes.where((note) {
      final query = _searchQuery.toLowerCase();
      return note.title.toLowerCase().contains(query) ||
          note.body.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search notes...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Expanded(
                  child: filteredNotes.isEmpty
                      ? const Center(child: Text('No notes found.'))
                      : ListView.builder(
                          itemCount: filteredNotes.length,
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            return Dismissible(
                              key: Key(note.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                _confirmDelete(note);
                                return false; // Handled manually by dialog
                              },
                              child: ListTile(
                                title: Text(
                                  note.title.isEmpty ? 'Untitled' : note.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  note.body,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: Text(
                                  '${note.date.month}/${note.date.day}/${note.date.year}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                onTap: () => _viewNote(note),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrUpdateNote(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
