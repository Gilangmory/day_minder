import 'package:get/get.dart';
import '../../database_manager.dart';
import './note_model.dart';

class NotesService extends GetxController {
  final RxList<Note> notes =
      <Note>[].obs; // Contoh RxList untuk menyimpan catatan

  // Fungsi untuk menambah catatan
  Future<void> addNote(Note note) async {
    final db = await DatabaseManager().database;
    await db.insert('notes', note.toMap());
    await getNotes(); // Memperbarui daftar catatan setelah penambahan
  }

  // Fungsi untuk mendapatkan semua catatan
  Future<void> getNotes() async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query('notes');

    notes.value = List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  // Fungsi untuk mendapatkan catatan berdasarkan ID
  Future<Note?> getNoteById(int id) async {
    final db = await DatabaseManager().database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Fungsi untuk memperbarui catatan
  Future<void> updateNote(Note note) async {
    final db = await DatabaseManager().database;
    await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    await getNotes();
  }

  // Fungsi untuk menghapus catatan
  Future<void> deleteNote(int id) async {
    final db = await DatabaseManager().database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    await getNotes();
  }

  Future<void> updateStatusToOff(int id) async {
    final db = await DatabaseManager().database;
    await db.update(
      'notes',
      {'status': Note.STATUS_OFF},
      where: 'id = ?',
      whereArgs: [id],
    );
    await getNotes();
  }
}
