import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';
import '../theme/theme_manager.dart';
import '../theme/app_theme.dart';

class NotesPage extends StatefulWidget {
  final String userId;
  const NotesPage({super.key, required this.userId});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _db = FirebaseDatabase.instance.ref();
  final TextEditingController _searchController = TextEditingController();
  Map<String, NoteItem> _notes = {};
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  Future<void> _loadNotes() async {
    final snap = await _db.child('users/${widget.userId}/notes').get();
    if (snap.exists) {
      final data = snap.value as Map;
      final Map<String, NoteItem> notes = {};
      data.forEach((key, value) {
        final item = value as Map;
        notes[key.toString()] = NoteItem(
          id: key.toString(),
          title: item['title'] ?? '',
          content: item['content'] ?? '',
          color: Color(item['color'] ?? 0xFFEF3124),
          updatedAt: DateTime.tryParse(item['updatedAt'] ?? '') ?? DateTime.now(),
        );
      });
      setState(() => _notes = notes);
    }
  }

  void _addOrEditNote({NoteItem? note}) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    Color selectedColor = note?.color ?? const Color(0xFFEF3124);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 24,
              right: 24,
              top: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    note == null ? 'Новая заметка' : 'Редактирование заметки',
                    style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Заголовок',
                      labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      labelText: 'Содержимое',
                      labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Цвет:', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      ...[
                        const Color(0xFFEF3124),
                        Colors.blue,
                        Colors.green,
                        Colors.purple,
                        Colors.orange,
                      ].map((color) => GestureDetector(
                        onTap: () => setModalState(() => selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: selectedColor == color
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                          ),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty || contentController.text.isNotEmpty) {
                        final id = note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
                        _db.child('users/${widget.userId}/notes/$id').set({
                          'title': titleController.text,
                          'content': contentController.text,
                          'color': selectedColor.value,
                          'updatedAt': DateTime.now().toIso8601String(),
                        });
                        _loadNotes();
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF3124),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      note == null ? 'Создать' : 'Сохранить',
                      style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _deleteNote(String id) {
    _db.child('users/${widget.userId}/notes/$id').remove();
    _loadNotes();
  }

  List<NoteItem> get _filteredNotes {
    final notes = _notes.values.toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    if (_searchQuery.isEmpty) {
      return notes;
    }
    return notes
        .where((note) =>
            note.title.toLowerCase().contains(_searchQuery) ||
            note.content.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeManager>().currentTheme;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(theme),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.getPrimaryColor(theme)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Заметки',
          style: GoogleFonts.nunito(
            color: AppTheme.getPrimaryColor(theme),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск заметок...',
                hintStyle: GoogleFonts.nunito(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredNotes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.note_alt, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Нет заметок'
                              : 'Ничего не найдено по запросу',
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (ctx, i) => _buildNoteCard(_filteredNotes[i], theme),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        backgroundColor: AppTheme.getPrimaryColor(theme),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(NoteItem note, SeasonTheme theme) {
    return GestureDetector(
      onTap: () => _addOrEditNote(note: note),
      child: Dismissible(
        key: Key(note.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          _deleteNote(note.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${note.title} удалена', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              backgroundColor: Colors.red,
            ),
          );
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: note.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: note.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title.isEmpty ? 'Без названия' : note.title,
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  note.content.isEmpty ? 'Нет контента' : note.content,
                  style: GoogleFonts.nunito(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 14, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(note.updatedAt),
                    style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}

class NoteItem {
  final String id;
  final String title;
  final String content;
  final Color color;
  final DateTime updatedAt;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.updatedAt,
  });
}
